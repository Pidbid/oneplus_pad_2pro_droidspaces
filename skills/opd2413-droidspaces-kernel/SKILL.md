---
name: opd2413-droidspaces-kernel
description: Build, rebuild, inspect, verify, document, or release firmware-matched DroidSpaces kernel and official GKI rollback AnyKernel packages for OnePlus Pad 2 Pro OPD2413/erhai. Use when working with OPD2413 boot/Image files, Android CI GKI artifacts, ColorOS 16 kernel updates, KernelSU Next root preservation, DroidSpaces namespace requirements, vendor-module ABI/certificate failures, Wi-Fi/Bluetooth regressions, MIDAS container-start reboots, or the four community-validated 16.0.8.300 and 16.0.9.400 packages.
---

# OPD2413 DroidSpaces Kernel

Build only from an exact firmware/kernel match. Treat a package as incompatible when any of device, ColorOS build, Android version, security patch, kernel release, GKI build number, page size, KMI symbols/CRCs, or module-trust certificate differs.

## Route the task

1. Read `references/version-matrix.md` for a known version or artifact.
2. Read `references/build-workflow.md` before fetching or compiling.
3. Read `references/incident-findings.md` before diagnosing Wi-Fi, Bluetooth, reboots, Root, or X11.
4. Read `references/release-checklist.md` before handing off or publishing a flashable ZIP.
5. Use `references/artifacts.json` as the machine-readable source of known filenames and hashes.

Choose one workflow:

- Official GKI rollback: fetch the exact Android CI `Image`, verify its embedded release, then package it without changing ramdisk or vendor partitions.
- DroidSpaces patched kernel: rebuild the exact ACK commit with the stock configuration, KMI, CRCs, certificate, and release string; make only the smallest proven compatibility change.
- Diagnosis: determine whether the failure occurs before userspace, in a vendor module, in DroidSpaces, or only in X11/XFCE. Do not assume every black screen is a kernel failure.

## Build an official GKI rollback

Extract the build number from the stock release suffix `-ab<build>-4k` and the source commit from `-g<sha>-ab`. Fetch through the Android CI landing page because its artifact link is JavaScript-provided:

```bash
bash scripts/fetch_android_ci_image.sh \
  14519050 ./Image \
  '6.6.89-android15-8-g97a9aaefab9a-ab14519050-4k' \
  0674085ec0088200aab83ec716598f438c685b4b8a5fe26ce13b614a3ffd10ed
```

Prepare AnyKernel3 at the pinned revision recorded in the version matrix, then build:

```bash
bash scripts/build_rollback_from_template.sh \
  --template-dir ./AnyKernel3 \
  --image ./Image \
  --output ./rollback.zip \
  --firmware 'OPD2413_16.0.8.300(CN01B60P01)' \
  --kernel-release '6.6.89-android15-8-g97a9aaefab9a-ab14519050-4k' \
  --build-id 14519050 \
  --source-commit 97a9aaefab9a856b42a688b28e26d50e10e95cc0 \
  --security-patch 2026-06-01
```

Verify the resulting package:

```bash
bash scripts/verify_anykernel_package.sh \
  ./rollback.zip \
  '6.6.89-android15-8-g97a9aaefab9a-ab14519050-4k' \
  0674085ec0088200aab83ec716598f438c685b4b8a5fe26ce13b614a3ffd10ed
```

## Build a DroidSpaces kernel

Follow `references/build-workflow.md` exactly. Preserve the stock release string, page size, config, KMI symbol names, module CRC table, and module-trust certificate. Enable only the required IPC/PID/User namespace options and the matching Android SYSVIPC kABI compatibility patch.

Apply `references/patches/opd2413-midas-pidns-guard.patch` only to the 16.0.9.400/6.6.118 source after pstore proves the same `oplus_bsp_midas` null-task crash signature. Do not generalize it to another firmware or caller.

Package only the kernel `Image` into AnyKernel3. Preserve the active-slot boot ramdisk. Never modify `init_boot`, `vendor_boot`, `dtbo`, or `vbmeta` in these packages.

## Enforce release safety

- Require the exact stock boot backup for the active firmware and slot before flashing.
- Reject packages built from another monthly GKI even when the major/minor version matches.
- Keep rollback and patched packages together, with SHA-256 values.
- Label static verification separately from real-device verification.
- Test after reboot in this order: boot duration, Wi-Fi, Bluetooth, Root behavior, DroidSpaces kernel checks, container start/stop, then X11 desktop.
- Stop after the first Wi-Fi/Bluetooth failure or kernel reboot; collect pstore before another attempt.
- Never claim Root is guaranteed after an official GKI rollback. AnyKernel preserves the ramdisk, but Root built into the replaced `Image` disappears.

## Publish

Commit scripts, patches, documentation, manifests, and checksums to source control. Publish the large flashable ZIPs as release assets instead of adding them to Git history. Include the precise firmware, kernel release, CI build, source commit, package hash, Image hash, verification level, and recovery instructions in every release.
