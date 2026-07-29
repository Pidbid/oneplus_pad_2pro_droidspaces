# Release and device checklist

## Static checks

- [ ] Full firmware, security patch, stock release, ACK commit, CI build, and 4K page size agree.
- [ ] `unzip -t` passes.
- [ ] Exactly one top-level `Image` exists.
- [ ] No `boot.img`, `init_boot.img`, `vendor_boot.img`, `dtbo.img`, or `vbmeta.img` is bundled.
- [ ] Embedded kernel release is exact.
- [ ] Image and package SHA-256 values are recorded.
- [ ] Installer checks OPD2413/erhai, Android 16, exact kernel release, and security patch when available.
- [ ] Installer targets only the active `boot` slot and preserves ramdisk.
- [ ] Patch release records config, exports, CRCs, certificate, compiler, and source commit.
- [ ] Rollback package is available beside the patch package.

## Before device flash

- [ ] Bootloader is unlocked.
- [ ] Current active slot is known.
- [ ] Exact-current-firmware `boot`, `init_boot`, `vendor_boot`, and `dtbo` plus checksums exist off-device.
- [ ] DroidSpaces containers are stopped.
- [ ] Battery is sufficient and the user knows the bootloader recovery path.

## Device test order

1. Flash through KernelSU Next **AnyKernel (.zip)**, not direct install or image selection.
2. Reboot only after `Done`/success.
3. Allow up to five minutes for first boot; do not loop reboots.
4. Confirm kernel release and normal boot.
5. Test Wi-Fi enable, connection, and reconnect.
6. Test Bluetooth enable and discovery.
7. Test KernelSU Root behavior separately.
8. Run DroidSpaces kernel requirements.
9. Start the existing container with hardware/GPU passthrough disabled.
10. Stop and start the container once.
11. Test X11 only after the container is stable.

## Verification labels

- `static-verified`: source, release string, hashes, layout, and installer checks pass.
- `boot-verified`: device boots the exact target firmware.
- `radio-verified`: Wi-Fi and Bluetooth pass.
- `root-observed`: record whether Root remains; do not treat as an invariant.
- `droidspaces-verified`: container starts/stops without reboot.
- `desktop-verified`: a single X11 desktop session renders.
