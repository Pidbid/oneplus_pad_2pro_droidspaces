# Contributing

For a new firmware version, open an issue or pull request with:

- full ColorOS build and security patch
- complete `uname -r`
- device/codename and active slot
- SHA-256 values for exact-current-firmware boot backups
- Android CI build and ACK commit
- package and Image SHA-256 values
- separate results for boot, Wi-Fi, Bluetooth, Root, DroidSpaces, and X11

When reporting a reboot, attach pstore/ramoops and the relevant DroidSpaces log after removing account names, tokens, network addresses, and unrelated personal data. Do not publish complete device dumps without reviewing them.

Do not submit packages built from a nearby monthly GKI or with an unverified module certificate/KMI table.
