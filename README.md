# OnePlus Pad 2 Pro DroidSpaces Kernel

[English](README_EN.md)

面向一加平板 2 Pro（`OPD2413` / `erhai`）的 DroidSpaces 兼容内核、官方 GKI 回退包、可复现构建 Skill 和实机故障结论。

> [!CAUTION]
> 这些包只适用于表格中**完全相同**的 ColorOS 版本、Android 安全补丁和内核字符串。刷错版本可能导致无法开机、Wi‑Fi/蓝牙无法开启或数据丢失。刷入前必须把当前固件、当前槽位的 `boot`、`init_boot`、`vendor_boot`、`dtbo` 和校验值备份到平板之外。

## 下载

刷机包作为 [GitHub Releases](https://github.com/Pidbid/oneplus_pad_2pro_droidspaces/releases) 附件发布，不加入 Git 历史。每个固件版本同时提供 DroidSpaces 修补包和官方 GKI 回退包。

| 固件 | 原厂内核 | DroidSpaces 修补包 | 官方 GKI 回退包 |
|---|---|---|---|
| `OPD2413_16.0.8.300(CN01B60P01)` | `6.6.89…ab14519050-4k` | `OPD2413-B60P01-6.6.89-DroidSpaces-KernelSUNext.zip` | `OPD2413-16.0.8.300-B60P01-6.6.89-Official-GKI-Rollback-AnyKernel3.zip` |
| `OPD2413_16.0.9.400(CN01B60P01)` | `6.6.118…ab15114928-4k` | `OPD2413-16.0.9.400-B60P01-6.6.118-DroidSpaces-MIDASFix-v7-AnyKernel3.zip` | `OPD2413-16.0.9.400-B60P01-6.6.118-Official-GKI-Rollback-AnyKernel3.zip` |

完整 SHA-256 见 [SHA256SUMS](SHA256SUMS) 和 [artifacts.json](artifacts.json)。

验证状态：

- 16.0.8.300 修补包：升级前实机验证启动、Wi‑Fi、蓝牙、Root 和 DroidSpaces。
- 16.0.8.300 回退包：由 Google Android CI build 14519050 的完全匹配官方 `Image` 新补齐；来源、内核字符串、结构、脚本和哈希已验证，仍需一次该版本实机回退测试后才能标记为 device-verified。
- 16.0.9.400 v7 修补包：实机验证启动、Wi‑Fi、蓝牙、Root 授权和 DroidSpaces 容器启动。
- 16.0.9.400 回退包：静态核验，并在排障过程中作为官方恢复路径使用。

## 最重要的结论

1. `B60P01` 不是唯一版本标识。16.0.8.300 和 16.0.9.400 都显示它，但 GKI 分别是 6.6.89 和 6.6.118，绝对不能混刷。
2. 能开机、能授权 Root，不代表内核与原厂模块兼容。临时模块证书会使受保护的 Wi‑Fi/蓝牙模块失去信任。
3. 16.0.9.400 v6 已修复模块证书/KMI/CRC，Wi‑Fi、蓝牙和 Root 正常；启动 DroidSpaces 仍会因 `oplus_bsp_midas` 的 PID namespace 空任务路径触发内核崩溃。
4. v7 只对来自 `oplus_bsp_midas` 的失败 PID 查询提供定向哨兵任务，保留其他调用者的原厂行为；实机验证容器可以正常启动。
5. v7 后 Termux:X11 黑屏、只有 X 光标的问题来自重复 XFCE/D-Bus/xscreensaver 会话，是容器桌面用户态问题，不是内核问题。
6. 官方 GKI 回退只替换活动槽 `boot` 中的内核并保留 ramdisk。Root 是否保留取决于 KernelSU Next 的安装方式，不能作为回退成功的唯一判断。

详细证据见 [incident-findings.md](skills/opd2413-droidspaces-kernel/references/incident-findings.md)。

## 构建与复现

项目内置可直接给 Codex/ChatGPT 使用的 [`opd2413-droidspaces-kernel` Skill](skills/opd2413-droidspaces-kernel/SKILL.md)，包括：

- 从 Android CI 的 JavaScript 重定向页面解析真实 GKI 下载地址；
- 核验内核字符串、构建号、源码提交、Image/ZIP SHA-256；
- 从固定 AnyKernel3 模板生成只替换活动槽内核的官方回退包；
- 验证 ZIP 结构，拒绝混入 `init_boot`、`vendor_boot`、`dtbo`、`vbmeta`；
- 保存两个固件版本的版本矩阵、故障结论、实机检查表和 v7 MIDAS 补丁。

快速复现官方 GKI：

```bash
bash skills/opd2413-droidspaces-kernel/scripts/fetch_android_ci_image.sh \
  14519050 ./Image \
  '6.6.89-android15-8-g97a9aaefab9a-ab14519050-4k' \
  0674085ec0088200aab83ec716598f438c685b4b8a5fe26ce13b614a3ffd10ed
```

完整过程见 [build-workflow.md](skills/opd2413-droidspaces-kernel/references/build-workflow.md)。

## 刷入原则

1. 停止 DroidSpaces，确认当前活动槽和完整备份。
2. 在 KernelSU Next 中选择 **刷入 AnyKernel (.zip)**，不要选“直接安装”或普通镜像选择。
3. 安装器显示 `Done` / 成功后才重启。
4. 重启后按顺序测试：启动时间 → Wi‑Fi → 蓝牙 → Root → DroidSpaces 检查 → 容器启动/停止 → X11。
5. Wi‑Fi/蓝牙异常或发生内核重启时立即停止测试，刷回同一固件的官方 GKI，并先保存 pstore。

完整清单见 [release-checklist.md](skills/opd2413-droidspaces-kernel/references/release-checklist.md)。

## 项目结构

```text
.
├── artifacts.json
├── SHA256SUMS
├── release-notes/
└── skills/opd2413-droidspaces-kernel/
    ├── SKILL.md
    ├── scripts/
    └── references/
```

## 许可与免责声明

仓库原创脚本和文档采用 [MIT License](LICENSE)。Linux/Android GKI、KernelSU Next、AnyKernel3 及其二进制工具遵循各自上游许可，见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。刷机始终有风险；本项目不提供任何可用性或数据安全保证。
