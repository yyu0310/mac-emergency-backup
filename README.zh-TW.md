# mac-emergency-backup

> MacBook 進水緊急備份工具包：一個腳本 + 一份 Claude Code 指令書，讓你在最短通電時間內把所有重要資料救到外接硬碟。

[English](README.md) | 繁體中文 | [简体中文](README.zh-CN.md)

---

## 為什麼有這個工具

天氣預報說傍晚降雨率 30%，放鬆警覺出門，從百貨停車場出來直接遇到暴雨，背包套了背包套還是全濕，MacBook 泡水，螢幕出現塊狀色斑，機殼縫縫持續流水。

M3 MacBook Air 的 SSD 焊死在主機板且硬體加密，**資料只能靠原機開機取出**，沒辦法拆硬碟外接。上一次備份已經是 3 個月前，裡面有所有的 AI 設定、自定義 Skill、程式專案、工作日誌。

決定賭一把：用 Claude Code 寫了這份緊急備份工具包，接著開機，全程透過手機的 Claude app 遠端操控進水的筆電執行備份，不到 10 分鐘所有重要資料都進了外接硬碟。

這份工具包就是當時用的那套，脫敏後開源。希望你永遠用不到，但萬一用到，能讓你在最緊張的時刻少一點慌亂。

---

## 功能

- **一鍵備份腳本** (`backup.sh`)：涵蓋 VS Project、Claude Code 設定、SSH 金鑰、dotfile、開發者憑證、VS Code 設定、launchd agents、Documents/Desktop/Downloads
- **Claude Code 指令書** (`claude-backup-instructions.md`)：讓 Claude 自動執行、驗證、回報，適合透過手機遠端操控
- **手動 SOP** (`手動SOP.md`)：不想用 Claude 也沒關係，對照清單自己跑
- **詳細版說明** (`開機備份.md`)：進水背景、每一步的原因、exFAT 還原注意事項

---

## 為什麼需要 Claude Code 遠端控制

在進水狀態下，你會希望盡量少碰鍵盤，避免水短路。Claude Code 支援 `/remote-control`，可以用手機的 Claude app 對筆電上的 Claude Code 下指令，全程不需要打字。

流程：
1. 插上高速外接硬碟
2. 開終端機，切到外接硬碟資料夾，執行 `claude`
3. 在手機 Claude app 輸入：「讀 claude-backup-instructions.md，照著幫我備份」
4. 授權 Claude 執行指令（手機上按同意）
5. 等到回報「可以安全關機了」

---

## 快速開始

### 事前準備（趁機器還健康時做）

1. 把這個 repo clone 或下載，放進你的外接硬碟
2. 打開 `backup.sh`，把第 15 行的 `YOUR_DRIVE_NAME` 改成你的外接硬碟名稱：
   ```bash
   DEST="/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"
   ```
3. 確認 Claude Code 有安裝（`claude --version`）

### 緊急備份時

```bash
# 方案 A：用 Claude Code 遠端操控（推薦）
cd /Volumes/YOUR_DRIVE_NAME
claude
# → 在手機 Claude app 輸入：「讀 claude-backup-instructions.md，照著幫我備份」

# 方案 B：直接跑腳本（不需要 Claude）
bash /Volumes/YOUR_DRIVE_NAME/backup.sh
```

看到 `✅ 備份完成` 和大小數字就可以關機。

---

## 備份內容

| 優先順序 | 項目 |
|---|---|
| 最高 | 桌面/VS Project（或你的主要專案資料夾）|
| 高 | `~/.claude/`、`~/.claude.json`（Claude Code 設定、skills、memory）|
| 高 | `~/.ssh/`、`~/.config/`、`~/.gitconfig`、shell rc 檔案 |
| 高 | `~/.aws`、`~/.gnupg`、`~/.kube`、`~/.docker`、`~/.npmrc`、`~/.netrc` |
| 中 | VS Code 設定、launchd agents 及其指向的腳本 |
| 中 | `~/bin`、`~/.local/bin`、`~/scripts` |
| 次要 | `~/Documents`、`~/Desktop`、`~/Downloads` |
| 附錄 | Homebrew 套件清單、App 清單、npm/pip 套件、工具版本（供重灌還原用）|

---

## 注意事項

- 腳本預設備份到 `exFAT` 格式的外接硬碟，**不保存 Unix 權限**，還原後需手動修：
  ```bash
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
  chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/*
  ```
- 備份大小取決於你的工作資料量，通常 10 GB ~ 50 GB 不等
- 出現異味、發燙、冒煙 → 立刻關機拔電，資料次要，人身安全第一

---

## 授權

MIT License — 詳見 [LICENSE](LICENSE)
