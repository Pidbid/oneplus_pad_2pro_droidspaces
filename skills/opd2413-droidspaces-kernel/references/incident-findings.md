# Findings from OPD2413 testing

## Wi-Fi and Bluetooth failures

On 16.0.9.400, a rebuilt kernel with a build-time temporary module certificate booted and still authorized Root, but Wi-Fi and Bluetooth could not start. This was a module-trust/ABI compatibility failure, not proof that the radio firmware was damaged.

The v6 rebuild restored the OTA stock public X.509 certificate and matched the exported symbol/CRC tables. Wi-Fi, Bluetooth, and Root then worked. Therefore:

- boot success and Root success do not prove vendor modules are compatible
- preserve module certificate, KMI symbols, and CRCs
- restore the exact official GKI immediately when Wi-Fi or Bluetooth fails

## DroidSpaces container-start reboot

With v6, the device was stable until DroidSpaces started a PID namespace. Pstore showed `oplus_bsp_midas` receiving a missing task from a PID-namespace lookup and later dereferencing it in an interrupt path. The v7 workaround supplies a permanent sentinel only when the failed `find_task_by_vpid()` call originates from module `oplus_bsp_midas`; all other callers retain stock behavior.

Apply the bundled MIDAS patch only when the same firmware and pstore signature are present. It is a targeted vendor-module compatibility workaround, not a generic namespace patch.

## KernelSU Next behavior

The 6.6.89 package has KernelSU Next built into `Image`. The 6.6.118 v7 package deliberately does not; AnyKernel preserves the current active-slot boot ramdisk. An official GKI rollback removes any Root implementation built into the replaced Image, but ramdisk/LKM-based Root may survive. Test Root separately and never use it as the only success signal.

## X11 black screen after v7

After v7, DroidSpaces started and the XFCE service was active. Process inspection showed duplicate XFCE sessions, panels, and D-Bus sessions on display `:5`, with xscreensaver already running. A black Termux:X11 window with an X cursor was therefore userspace session duplication, not a kernel, Wi-Fi, or MIDAS failure.

Diagnose in order:

1. confirm container and X11 socket/display
2. check `xfce-autostart.service`
3. list duplicate `xfce4-session`, `xfwm4`, `xfdesktop`, panels, D-Bus, and xscreensaver processes
4. terminate stale session processes and start one clean session

Do not rebuild or reflash the kernel for this symptom unless pstore or dmesg shows a new kernel failure.
