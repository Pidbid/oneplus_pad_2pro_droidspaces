#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 PACKAGE.zip EXPECTED_RELEASE [EXPECTED_IMAGE_SHA256]" >&2
  exit 2
fi

package=$1
expected_release=$2
expected_image_sha256=${3:-}

[[ -f $package ]] || { echo "Package not found: $package" >&2; exit 2; }
for tool in unzip strings sha256sum grep awk stat; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }
done

unzip -tq "$package" >/dev/null
entries=$(unzip -Z1 "$package")
[[ $(grep -xc 'Image' <<<"$entries") -eq 1 ]] || {
  echo "Package must contain exactly one top-level Image" >&2
  exit 1
}
grep -qx 'anykernel.sh' <<<"$entries" || { echo "Missing top-level anykernel.sh" >&2; exit 1; }
grep -qx 'tools/ak3-core.sh' <<<"$entries" || { echo "Missing AnyKernel3 core" >&2; exit 1; }

if grep -Eq '(^|/)(boot|init_boot|vendor_boot|dtbo|vbmeta)(_[ab])?\.img$' <<<"$entries"; then
  echo "Unexpected partition image bundled in kernel-only package" >&2
  exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
unzip -p "$package" Image >"$work/Image"
unzip -p "$package" anykernel.sh >"$work/anykernel.sh"

size=$(stat -c '%s' "$work/Image")
(( size > 20 * 1024 * 1024 )) || { echo "Image is too small: $size bytes" >&2; exit 1; }
grep -aFq "Linux version $expected_release" "$work/Image" || {
  echo "Embedded release mismatch" >&2
  exit 1
}
grep -Fq "$expected_release" "$work/anykernel.sh" || {
  echo "Installer does not enforce the expected release" >&2
  exit 1
}
grep -Fq 'split_boot;' "$work/anykernel.sh" || { echo "Installer does not split boot" >&2; exit 1; }
grep -Fq 'flash_boot;' "$work/anykernel.sh" || { echo "Installer does not flash boot" >&2; exit 1; }

image_sha256=$(sha256sum "$work/Image" | awk '{print $1}')
if [[ -n $expected_image_sha256 && $image_sha256 != "$expected_image_sha256" ]]; then
  echo "Image SHA-256 mismatch: expected $expected_image_sha256, got $image_sha256" >&2
  exit 1
fi

echo "Package: $package"
echo "Package SHA-256: $(sha256sum "$package" | awk '{print $1}')"
echo "Image bytes: $size"
echo "Image SHA-256: $image_sha256"
echo "Kernel release: $expected_release"
echo "Verification: PASS"
