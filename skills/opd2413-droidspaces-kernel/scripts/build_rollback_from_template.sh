#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  build_rollback_from_template.sh \
    (--template-dir DIR | --template-zip ZIP) \
    --image IMAGE --output ZIP --firmware BUILD \
    --kernel-release RELEASE --build-id NUMBER \
    --source-commit SHA --security-patch YYYY-MM-DD
EOF
  exit 2
}

template_dir=
template_zip=
image=
output=
firmware=
kernel_release=
build_id=
source_commit=
security_patch=

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template-dir) template_dir=${2:-}; shift 2 ;;
    --template-zip) template_zip=${2:-}; shift 2 ;;
    --image) image=${2:-}; shift 2 ;;
    --output) output=${2:-}; shift 2 ;;
    --firmware) firmware=${2:-}; shift 2 ;;
    --kernel-release) kernel_release=${2:-}; shift 2 ;;
    --build-id) build_id=${2:-}; shift 2 ;;
    --source-commit) source_commit=${2:-}; shift 2 ;;
    --security-patch) security_patch=${2:-}; shift 2 ;;
    *) usage ;;
  esac
done

[[ -n $template_dir || -n $template_zip ]] || usage
[[ -z $template_dir || -z $template_zip ]] || usage
[[ -f $image && -n $output && -n $firmware && -n $kernel_release ]] || usage
[[ $build_id =~ ^[0-9]+$ ]] || usage
[[ $source_commit =~ ^[0-9a-f]{40}$ ]] || usage
[[ $security_patch =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage
[[ $firmware =~ ^OPD2413_[A-Za-z0-9._()]+$ ]] || { echo "Unsafe firmware value" >&2; exit 2; }
[[ $kernel_release =~ ^[A-Za-z0-9._+-]+$ ]] || { echo "Unsafe kernel release" >&2; exit 2; }
[[ $output != / && $output != "." ]] || { echo "Unsafe output path" >&2; exit 2; }

for tool in zip unzip strings sha256sum awk grep realpath; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }
done

grep -aFq "Linux version $kernel_release" "$image" || {
  echo "Image does not contain expected release: $kernel_release" >&2
  exit 1
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
package="$work/package"
mkdir -p "$package"
output=$(realpath -m "$output")

if [[ -n $template_dir ]]; then
  [[ -d $template_dir ]] || { echo "Template directory not found" >&2; exit 2; }
  cp -a "$template_dir"/. "$package"/
  rm -rf "$package/.git"
else
  [[ -f $template_zip ]] || { echo "Template ZIP not found" >&2; exit 2; }
  unzip -q "$template_zip" -d "$package"
fi

[[ -f $package/tools/ak3-core.sh ]] || { echo "Not an AnyKernel3 template" >&2; exit 1; }
rm -f "$package/Image" "$package/BUILD-INFO.txt" "$package/BUILD_INFO.txt"
rm -f "$package/README-CN.txt" "$package/README-OPD2413.txt" "$package/version"
cp "$image" "$package/Image"

image_sha256=$(sha256sum "$image" | awk '{print $1}')
firmware_short=${firmware#OPD2413_}
firmware_short=${firmware_short%%(*}
kernel_short=${kernel_release%%-*}

cat >"$package/BUILD-INFO.txt" <<EOF
Device: OnePlus Pad 2 Pro
Model: OPD2413
Codename: erhai
Firmware: $firmware
Android: 16
Security patch: $security_patch

Official GKI:
$kernel_release
Build: $build_id
Source commit: $source_commit
Artifact: https://ci.android.com/builds/submitted/$build_id/kernel_aarch64/latest/Image
ARM64 / 4K pages
Image SHA-256: $image_sha256

Installer:
AnyKernel3, active-slot boot kernel only
Existing boot ramdisk preserved
No init_boot, vendor_boot, dtbo or vbmeta changes
EOF

cat >"$package/README-CN.txt" <<EOF
OPD2413 $firmware_short 官方 GKI 回退包

只适用于 $firmware。
目标内核：$kernel_release
Android CI build：$build_id
Image SHA-256：$image_sha256

本包只替换当前活动槽 boot 中的内核并保留现有 ramdisk。
不修改 init_boot、vendor_boot、dtbo 或 vbmeta。
刷入前必须备份当前固件、当前槽位的 boot 相关分区。
KernelSU 是否保留取决于其是否由保留的 ramdisk/LKM 独立提供。
EOF

cat >"$package/anykernel.sh" <<EOF
### AnyKernel3 Ramdisk Mod Script
## Target: OnePlus Pad 2 Pro / OPD2413 / erhai

properties() { '
kernel.string=OPD2413 $firmware_short Official GKI $kernel_short Rollback
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=OPD2413
device.name2=opd2413
device.name3=erhai
supported.versions=16
supported.patchlevels=
supported.vendorpatchlevels=
'; }

BLOCK=/dev/block/by-name/boot;
IS_SLOT_DEVICE=1;
SLOT_SELECT=active;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_MAGISK_CHECK=1;
NO_VBMETA_PARTITION_PATCH=1;

. tools/ak3-core.sh;

expected_release="$kernel_release";
current_release="\$(uname -r 2>/dev/null)";
if [ "\$current_release" != "\$expected_release" ]; then
  abort "Wrong base kernel: \$current_release";
fi;

current_patch="\$(getprop ro.build.version.security_patch 2>/dev/null)";
if [ -n "\$current_patch" ] && [ "\$current_patch" != "$security_patch" ]; then
  abort "Wrong security patch: \$current_patch";
fi;

ui_print "Target firmware: $firmware";
ui_print "Restoring official GKI build $build_id; preserving the active boot ramdisk.";
split_boot;
flash_boot;
ui_print "Official GKI restored. Reboot only after Done / success.";
EOF

printf '%s\n' "OPD2413-$firmware_short-$kernel_short-Official-GKI-Rollback" >"$package/version"
chmod 0755 "$package/anykernel.sh"
mkdir -p "$(dirname "$output")"

(
  cd "$package"
  zip -q -r9 -X "$output" .
)

echo "Output: $output"
echo "Image SHA-256: $image_sha256"
echo "Package SHA-256: $(sha256sum "$output" | awk '{print $1}')"
