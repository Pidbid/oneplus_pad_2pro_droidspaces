# OPD2413 firmware and artifact matrix

Never cross-flash rows. `B60P01` alone is not a unique firmware identifier.

| Firmware | Security patch | Exact stock kernel | ACK commit | CI build |
|---|---|---|---|---:|
| `OPD2413_16.0.8.300(CN01B60P01)` | 2026-06-01 | `6.6.89-android15-8-g97a9aaefab9a-ab14519050-4k` | `97a9aaefab9a856b42a688b28e26d50e10e95cc0` | 14519050 |
| `OPD2413_16.0.9.400(CN01B60P01)` | 2026-07-01 | `6.6.118-android15-8-g2e6b9c3812c5-ab15114928-4k` | `2e6b9c3812c54b4704bf9dd557ac29e9d7d4ca4e` | 15114928 |

Pinned packaging baseline: AnyKernel3 commit `1c9a500dd4aa8081952523126e97eb155aed941b`.

## Four community artifacts

### 16.0.8.300 patched

- File: `OPD2413-B60P01-6.6.89-DroidSpaces-KernelSUNext.zip`
- Package SHA-256: `78adf15cced48fd345a05a9c5d0db87b7cfb50af0ea5383fe4c8f2227b605591`
- Image SHA-256: `dce6e8c76ac85306fd235facd6be8313e6db19bb4aef5b42d4fb2865a2cac50d`
- Profile: DroidSpaces namespace/cgroup/seccomp/network requirements plus `CONFIG_USER_NS`; KernelSU Next v3.3.0 built in.
- Verification: user verified the original firmware, boot, Root, and DroidSpaces use before the OTA update.

### 16.0.8.300 official rollback

- File: `OPD2413-16.0.8.300-B60P01-6.6.89-Official-GKI-Rollback-AnyKernel3.zip`
- Package SHA-256: `be9c7185adf341921aeb0552faa331af33b7df172f31ebbbc43d30ac9e6a65b6`
- Image SHA-256: `0674085ec0088200aab83ec716598f438c685b4b8a5fe26ce13b614a3ffd10ed`
- Source: Android CI build 14519050, `kernel_aarch64/Image`.
- Verification: exact CI source, embedded kernel release, package layout, shell syntax, ZIP integrity, and hashes verified. This newly completed rollback still requires an OPD2413 real-device flash test before being labeled device-verified.

### 16.0.9.400 patched

- File: `OPD2413-16.0.9.400-B60P01-6.6.118-DroidSpaces-MIDASFix-v7-AnyKernel3.zip`
- Package SHA-256: `9b18951a9978c7d1a23c794bbb9be23f06236741497599842c99b33f4e8d9177`
- Image SHA-256: `a7cd358940526ea953d4182fa09124fb46b1bc85a43e7281be408b728224147a`
- Profile: stock ABI/trust, DroidSpaces namespaces, targeted `oplus_bsp_midas` PID-namespace null-task guard; preserves current boot ramdisk and does not embed KernelSU.
- Verification: user verified boot, Wi-Fi, Bluetooth, Root authorization, and DroidSpaces container startup.

### 16.0.9.400 official rollback

- File: `OPD2413-16.0.9.400-B60P01-6.6.118-Official-GKI-Rollback-AnyKernel3.zip`
- Package SHA-256: `6d69a99f5afe43b48a8c7dd101be47b13eeb29998afdb7303bb6c8425d9b7baa`
- Image SHA-256: `d4d2cbf9cf97e522b2e4a4ba8cee6b1ef205eaa5b04d632a25b0e21c8c817bf5`
- Source: Android CI build 15114928, `kernel_aarch64/Image`.
- Verification: package/source statically verified and used as the recovery path during device testing.
