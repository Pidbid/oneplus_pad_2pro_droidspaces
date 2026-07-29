# OnePlus Pad 2 Pro DroidSpaces Kernel

Reproducible DroidSpaces-compatible kernels, exact official GKI rollback packages, a reusable build Skill, and device-tested findings for OnePlus Pad 2 Pro (`OPD2413` / `erhai`).

> [!CAUTION]
> Flash only on the exact ColorOS build, security patch, and kernel release listed in the matrix. A mismatch can cause boot failure, unavailable Wi-Fi/Bluetooth, or data loss. Keep exact-current-firmware `boot`, `init_boot`, `vendor_boot`, and `dtbo` backups off-device.

Flashable packages are published as [GitHub Release assets](https://github.com/Pidbid/oneplus_pad_2pro_droidspaces/releases). See [SHA256SUMS](SHA256SUMS), [artifacts.json](artifacts.json), and the Chinese [README](README.md) for the complete compatibility and verification matrix.

Key findings:

- `B60P01` is not unique: 16.0.8.300 uses GKI 6.6.89, while 16.0.9.400 uses 6.6.118.
- Boot and Root success do not prove vendor-module compatibility. A wrong module certificate caused Wi-Fi and Bluetooth failures.
- The 16.0.9.400 container-start reboot was traced through pstore to an `oplus_bsp_midas` PID-namespace null-task path.
- v7 preserves the stock ABI/trust profile and applies only a caller-specific MIDAS guard; boot, radios, Root authorization, and DroidSpaces startup were verified.
- The later Termux:X11 black screen was caused by duplicate XFCE userspace sessions, not the kernel.

The reusable [`opd2413-droidspaces-kernel` Skill](skills/opd2413-droidspaces-kernel/SKILL.md) downloads exact Android CI artifacts, builds rollback ZIPs, validates package safety, and carries the version matrix, incident findings, release checklist, and v7 patch.

Repository-authored scripts and documentation are MIT licensed. Bundled release components retain their upstream licenses; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Flash at your own risk.
