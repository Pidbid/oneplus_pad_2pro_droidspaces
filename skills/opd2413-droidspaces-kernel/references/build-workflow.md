# Reproducible build workflow

## 1. Record the immutable target

Capture before any build:

- device/product/codename: OPD2413 / OP615EL1 / erhai
- full ColorOS version, not only `B60P01`
- Android version and security patch
- complete `uname -r`
- active slot
- SHA-256 of `boot`, `init_boot`, `vendor_boot`, and `dtbo` backups

Stop if these values do not match a known row. Never infer compatibility from `6.6`, `B60P01`, or the device marketing name alone.

## 2. Obtain the official GKI

The `abNNNN` suffix in the stock release is the Android CI build ID. The `g<sha>` portion identifies the ACK commit. Download:

`https://ci.android.com/builds/submitted/<build>/kernel_aarch64/latest/Image`

The response is an HTML landing page containing `var JSVariables`; parse its `artifactUrl`, then download the signed storage URL. Use `scripts/fetch_android_ci_image.sh`.

Verify:

- file is a large ARM64 kernel Image, not the small HTML landing page
- embedded `Linux version` exactly equals stock `uname -r`
- page-size suffix is `-4k`
- SHA-256 is recorded
- source commit resolves in `android.googlesource.com/kernel/common`

## 3. Build the rollback package

Use pinned AnyKernel3. Bundle only a top-level `Image`; keep its tools, updater files, and license. Configure:

- OPD2413/opd2413/erhai device checks
- Android 16 check
- exact current kernel release preflight
- exact security-patch preflight when the property is available
- active-slot `/dev/block/by-name/boot`
- `split_boot` then `flash_boot`
- no vbmeta patch and no other partition image

AnyKernel repacks the active boot and preserves its ramdisk. It does not make an old boot backup compatible with a new OTA.

## 4. Rebuild a patched GKI

Sync the exact ACK commit and manifest matching the stock build. Use the toolchain named in the stock `Linux version`; both known versions use Android Clang r510928 / clang 18.

Start from the stock extracted config. Preserve:

- `CONFIG_LOCALVERSION_AUTO=n` and the exact stock release string
- ARM64 4K page size
- module versions and the complete KMI export set
- symbol CRC values used by vendor/system GKI modules
- `CONFIG_MODULE_SIG_PROTECT`
- the public X.509 certificate matching the OTA system modules

Enable only DroidSpaces requirements:

- `CONFIG_SYSVIPC=y`
- `CONFIG_POSIX_MQUEUE=y`
- `CONFIG_IPC_NS=y`
- `CONFIG_PID_NS=y`
- `CONFIG_USER_NS=y`
- the matching Android pre-6.12 SYSVIPC kABI compatibility change

Do not casually change Wi-Fi, Bluetooth, netfilter, devtmpfs, scheduler, or vendor-driver configuration.

## 5. Validate ABI and module trust

Before flashing, compare custom against the known-good stock/rebuilt baseline:

- exact exported symbol-name set
- regular and GPL CRC tables
- extracted config
- stock certificate bytes and SHA-256
- certificate serial against a signed module such as `bluetooth.ko`
- `uname -r` string embedded in Image

For the validated 6.6.118 v7 build, the v6/v7 symbol set was 9007 names, with 3397 regular CRCs and 5610 GPL CRCs; the full CRC table was byte-identical. The stock certificate SHA-256 was `3d46262092ddcf253f9cf266d16be0bbd44f81bdc888c4d66dd26e388374e01a`.

## 6. Package and test

Package only `Image`, document both Image and ZIP SHA-256, and run `scripts/verify_anykernel_package.sh`. Then follow `release-checklist.md`.
