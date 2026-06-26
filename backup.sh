#!/bin/bash
# 進水筆電緊急備份腳本（M3 MacBook Air）
# 用法：開機後打開「終端機」，執行：  bash ~/Downloads/backup.sh
# 目的：在通電時間最短的情況下，把最重要的資料先救出來。

set -uo pipefail

# ============================================================
# 第 1 步：選一個備份目的地（二選一，把要用的那行解開註解）
# ============================================================

# 方案 A（最推薦）：外接 USB 隨身碟 / 行動硬碟
#   插上後通常掛載在 /Volumes/你的隨身碟名稱
#   先執行  ls /Volumes  看名字，再把下面改成正確名稱
# ⚠️ 把 YOUR_DRIVE_NAME 改成你的外接硬碟名稱（執行 ls /Volumes 確認）
DEST="/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"

# 方案 B：iCloud Drive（注意！複製完不能馬上關機，要等上傳完成）
# DEST="$HOME/Library/Mobile Documents/com~apple~CloudDocs/EmergencyBackup"

# ============================================================
# 以下不用改
# ============================================================
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$DEST/mac-backup-$STAMP"

if ! mkdir -p "$OUT" 2>/dev/null; then
  echo "❌ 無法建立 $OUT"
  echo "   請確認：隨身碟已插上？DEST 名稱正確？(執行 ls /Volumes 看名字)"
  exit 1
fi

echo "=============================================="
echo "備份目的地：$OUT"
echo "開始時間：  $(date)"
echo "=============================================="

backup() {
  local src="$1"
  if [ -e "$src" ]; then
    echo "→ 備份 $src"
    # -rLt：遞迴、跟隨 symlink 複製真實內容、保留時間戳。
    # 不用 -a，因為目的地是 exFAT，無法保存權限/symlink，會噴錯且漏檔。
    rsync -rLt --info=progress2 "$src" "$OUT/" 2>>"$OUT/errors.log"
  else
    echo "  略過（不存在）：$src"
  fi
}

# ---- 第一優先：最重要、最小、最快（Claude / 設定 / 金鑰 / 專案）----
backup "$HOME/Desktop/VS Project"
backup "$HOME/.claude"
backup "$HOME/.claude.json"
backup "$HOME/.config"
backup "$HOME/.ssh"
backup "$HOME/.gitconfig"
backup "$HOME/.gitignore_global"
backup "$HOME/.zshrc"
backup "$HOME/.zprofile"
backup "$HOME/.zshenv"
backup "$HOME/.bashrc"
backup "$HOME/.bash_profile"
backup "$HOME/.profile"
backup "$HOME/.p10k.zsh"
backup "$HOME/.vimrc"
backup "$HOME/.tool-versions"

# ---- 開發者憑證 / 設定（小但重要，常藏 token / 金鑰）----
backup "$HOME/.aws"
backup "$HOME/.gnupg"
backup "$HOME/.kube"
backup "$HOME/.docker"
backup "$HOME/.npmrc"
backup "$HOME/.yarnrc"
backup "$HOME/.netrc"
backup "$HOME/.terraform.d"

# ---- VS Code 使用者設定（settings / keybindings / snippets）----
backup "$HOME/Library/Application Support/Code/User"

# ---- 環境清單：轉成純文字記錄，供日後重灌還原（不佔空間）----
command -v brew >/dev/null 2>&1 && brew leaves > "$OUT/brew-leaves.txt" 2>/dev/null
command -v brew >/dev/null 2>&1 && brew list --cask > "$OUT/brew-casks.txt" 2>/dev/null
ls /Applications > "$OUT/applications.txt" 2>/dev/null
command -v code >/dev/null 2>&1 && code --list-extensions > "$OUT/vscode-extensions.txt" 2>/dev/null
command -v npm  >/dev/null 2>&1 && npm ls -g --depth=0 > "$OUT/npm-global.txt" 2>/dev/null
command -v pip3 >/dev/null 2>&1 && pip3 list > "$OUT/pip-list.txt" 2>/dev/null
{ echo "node:   $(node -v 2>/dev/null)";
  echo "npm:    $(npm -v 2>/dev/null)";
  echo "python: $(python3 -V 2>&1)";
  echo "git:    $(git --version 2>/dev/null)"; } > "$OUT/tool-versions.txt" 2>/dev/null
crontab -l > "$OUT/crontab.txt" 2>/dev/null

# ---- launchd：設定檔 + 它們指向的腳本 ----
LA="$HOME/Library/LaunchAgents"
if [ -d "$LA" ]; then
  echo "→ 備份 launchd 設定 $LA"
  backup "$LA"
  # 記錄目前載入中的服務
  launchctl list > "$OUT/launchctl-list.txt" 2>/dev/null
  # 解析每個 plist 指向的路徑，記錄下來
  grep -hoE '<string>[^<]+</string>' "$LA"/*.plist 2>/dev/null \
    | sed -E 's#</?string>##g' \
    | grep -E '^/' | sort -u > "$OUT/launchd-referenced-paths.txt"
  # 把其中位於家目錄底下的腳本/程式一起備份（保留完整路徑結構）
  mkdir -p "$OUT/launchd-programs"
  while IFS= read -r p; do
    case "$p" in
      "$HOME"/*) [ -e "$p" ] && rsync -rLtR "$p" "$OUT/launchd-programs/" 2>>"$OUT/errors.log" ;;
    esac
  done < "$OUT/launchd-referenced-paths.txt"
fi

# ---- 自訂腳本常見存放位置 ----
backup "$HOME/bin"
backup "$HOME/.local/bin"
backup "$HOME/scripts"

# ---- 第二優先：工作資料（不需要的可在前面加 # 註解掉）----
backup "$HOME/Documents"
backup "$HOME/Desktop"
backup "$HOME/Downloads"
# backup "$HOME/Projects"

# 把資料真正寫進磁碟（外接碟尤其重要）
sync

echo ""
echo "=============================================="
echo "✅ 備份完成：$(date)"
echo "備份大小："
du -sh "$OUT" 2>/dev/null
echo ""
echo "如有錯誤，請看：$OUT/errors.log"
echo "=============================================="
echo ""
echo "【關機前確認】"
echo " - 用外接碟：上面顯示大小正常 → 可以安心關機"
echo " - 用 iCloud：先在 Finder 左側看 iCloud 上傳是否跑完，跑完才關機"
