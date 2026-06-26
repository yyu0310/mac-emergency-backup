# mac-emergency-backup

> MacBook 进水紧急备份工具包：一个脚本 + 一份 Claude Code 指令书，让你在最短通电时间内把所有重要资料救到外接硬盘。

[English](README.md) | [繁體中文](README.zh-TW.md) | 简体中文

---

## 为什么有这个工具

MacBook 进水了。M3 MacBook Air 的 SSD 焊死在主板且硬件加密，**资料只能靠原机开机取出**，没办法拆硬盘外接。

用 Claude Code 写了这份紧急备份工具包，通过手机的 Claude app 远程操控进水的笔电，不到 10 分钟所有重要资料都进了外接硬盘。

这份工具包就是当时用的那套，脱敏后开源。希望你永远用不到，但万一用到，能让你在最紧张的时刻少一点慌乱。

---

## 功能

- **一键备份脚本** (`backup.sh`)：涵盖 VS Project、Claude Code 配置、SSH 密钥、dotfile、开发者凭证、VS Code 配置、launchd agents、Documents/Desktop/Downloads
- **Claude Code 指令书** (`BACKUP-请照做.md`)：让 Claude 自动执行、验证、回报，适合通过手机远程操控
- **手动 SOP** (`手动SOP.md`)：不想用 Claude 也没关系，对照清单自己跑
- **详细说明** (`开机备份.md`)：进水背景、每一步的原因、exFAT 还原注意事项

---

## 为什么需要 Claude Code 远程控制

在进水状态下，你会希望尽量少碰键盘，避免水短路。Claude Code 支持 `/remote-control`，可以用手机的 Claude app 对笔电上的 Claude Code 下指令，全程不需要打字。

流程：
1. 插上高速外接硬盘
2. 开终端，切到外接硬盘目录，运行 `claude`
3. 在手机 Claude app 输入：「读 BACKUP-请照做.md，照着帮我备份」
4. 授权 Claude 运行指令（手机上点同意）
5. 等到回报「可以安全关机了」

---

## 快速开始

### 事前准备（趁机器还健康时做）

1. 把这个 repo clone 或下载，放进你的外接硬盘
2. 打开 `backup.sh`，把第 15 行的 `YOUR_DRIVE_NAME` 改成你的外接硬盘名称：
   ```bash
   DEST="/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"
   ```
3. 确认 Claude Code 已安装（`claude --version`）

### 紧急备份时

```bash
# 方案 A：用 Claude Code 远程操控（推荐）
cd /Volumes/YOUR_DRIVE_NAME
claude
# 在手机 Claude app 输入：「读 BACKUP-请照做.md，照着帮我备份」

# 方案 B：直接跑脚本（不需要 Claude）
bash /Volumes/YOUR_DRIVE_NAME/backup.sh
```

看到 `✅ 备份完成` 和大小数字就可以关机。

---

## 备份内容

| 优先级 | 项目 |
|---|---|
| 最高 | 桌面/VS Project（或你的主要项目文件夹）|
| 高 | `~/.claude/`、`~/.claude.json`（Claude Code 配置、skills、memory）|
| 高 | `~/.ssh/`、`~/.config/`、`~/.gitconfig`、shell rc 文件 |
| 高 | `~/.aws`、`~/.gnupg`、`~/.kube`、`~/.docker`、`~/.npmrc`、`~/.netrc` |
| 中 | VS Code 配置、launchd agents 及其指向的脚本 |
| 中 | `~/bin`、`~/.local/bin`、`~/scripts` |
| 次要 | `~/Documents`、`~/Desktop`、`~/Downloads` |
| 附录 | Homebrew 包列表、App 列表、npm/pip 包、工具版本（供重装还原用）|

---

## 注意事项

- 脚本默认备份到 `exFAT` 格式的外接硬盘，**不保存 Unix 权限**，还原后需手动修：
  ```bash
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
  chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/*
  ```
- 备份大小取决于你的工作资料量，通常 10 GB ~ 50 GB 不等
- 出现异味、发烫、冒烟 → 立刻关机拔电，资料次要，人身安全第一

---

## 授权

MIT License，详见 [LICENSE](LICENSE)
