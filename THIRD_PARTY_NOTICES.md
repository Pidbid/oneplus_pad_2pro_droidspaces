# Third-party notices

The repository-authored documentation and helper scripts are licensed under this repository's MIT License. Release packages contain or derive from third-party projects under their own licenses:

- Linux kernel / Android Common Kernel: GPL-2.0-only with the Linux syscall exception. Exact source commits:
  - [97a9aaefab9a856b42a688b28e26d50e10e95cc0](https://android.googlesource.com/kernel/common/+/97a9aaefab9a856b42a688b28e26d50e10e95cc0)
  - [2e6b9c3812c54b4704bf9dd557ac29e9d7d4ca4e](https://android.googlesource.com/kernel/common/+/2e6b9c3812c54b4704bf9dd557ac29e9d7d4ca4e)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next): kernel code GPL-2.0-only; other components GPL-3.0-or-later. The 6.6.89 patched package records commit `3b18216f71df189ab3d1b1ce0bdb21be1268e771`.
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3): its included license and binary-license notices remain inside every release ZIP. Packaging baseline commit: `1c9a500dd4aa8081952523126e97eb155aed941b`.

Official rollback `Image` files are downloaded from Android CI builds [14519050](https://ci.android.com/builds/submitted/14519050/kernel_aarch64/latest) and [15114928](https://ci.android.com/builds/submitted/15114928/kernel_aarch64/latest).

No private signing key is included. The 16.0.9.400 patched Image embeds only the public X.509 certificate required to preserve compatibility with already signed system modules.
