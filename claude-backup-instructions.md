# claude-backup-instructions.md — 進水筆電緊急備份任務

> 給 Claude Code 的指示書。這台 MacBook Air M3 進水了，現在開機的唯一目的是
> **把重要資料備份到外接硬碟，然後盡快關機**。
> 請嚴格照下面執行，不要做任何與備份無關的事。

## 啟動方式（重要）

- 使用者就在電腦旁開機，但會**透過手機遠端操控**對你下指令，所以：
  - 一被叫到（例如「開始備份」「照 claude-backup-instructions.md 備份」）→ **直接從步驟 1 開工**，不用反問確認。
  - **回報要簡短**，方便手機螢幕閱讀；長輸出只回報關鍵結果（成功/失敗、大小、錯誤）。
  - 需要使用者授權執行指令時，明確說「請在手機上按同意」。

---

## 你的任務（唯一目標）

把使用者最重要的資料，用最短的通電時間，安全複製到外接硬碟，
驗證成功後，明確告訴使用者「可以關機了」。

## 鐵則

1. **動作要快、要專注**：機器進水中，每多開機一分鐘都有風險。不要探索檔案系統、不要分析程式碼、不要做任何額外的事。
2. **每一步先說你要做什麼，再做**，並把指令輸出回報給使用者。
3. **備份用現成腳本，不要自己重寫複製邏輯**（除非找不到腳本，見下方備援）。
4. **完成前必須驗證**（檔案有複製進去、大小合理），才可宣告成功。
5. **提醒使用者實體警訊**：如果機器發燙、有異味、冒煙 → 請使用者立刻關機拔電，中止任務。
6. **絕對不要讀取或印出機密內容**：禁止 `cat`、`head`、`open`、`grep` 任何金鑰/憑證檔案
   （`~/.ssh`、`~/.aws`、`~/.gnupg`、`~/.npmrc`、`~/.netrc`、`~/.kube`、`~/.docker` 等）。
   這些檔案只能用 `rsync`/`cp` **搬移**，驗證時只看**檔名與大小**（`ls`、`du`），
   絕不查看內容。如需 debug 也不要印出機密檔案本體。

---

## 執行步驟

### 步驟 1：確認外接硬碟已掛載

```
ls /Volumes
```

- 清單裡要有你的外接硬碟名稱（預設腳本使用 `YOUR_DRIVE_NAME`，請確認並調整）。
- 若不存在 → 請使用者插上外接硬碟，再重試。

### 步驟 2：找到備份腳本

依序檢查這兩個位置，用第一個存在的：

```
ls -l /Volumes/YOUR_DRIVE_NAME/backup.sh ~/Downloads/backup.sh 2>/dev/null
```

- 找到 → 進入步驟 3。
- 兩個都沒有 → 跳到下方「備援方案」。

### 步驟 3：執行備份

用步驟 2 找到的路徑執行（範例為放在外接碟上）：

```
bash /Volumes/YOUR_DRIVE_NAME/backup.sh
```

- 過程會逐行顯示正在備份的項目。
- 等到出現 `✅ 備份完成` 與大小數字。

### 步驟 4：驗證

備份會放在 `/Volumes/YOUR_DRIVE_NAME/EmergencyBackup/mac-backup-時間戳/`：

```
ls -lh "/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"/mac-backup-*/
du -sh "/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"/mac-backup-*/
```

確認：
- 有 `VS Project`、`.claude` 等資料夾存在。
- 總大小是合理的數字（不是 0）。
- 若有 `errors.log`，打開看是否有嚴重錯誤：
  `cat "/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"/mac-backup-*/errors.log`

### 步驟 5：回報

把資料真正寫入磁碟後回報：

```
sync
```

明確告訴使用者一句話，例如：
> ✅ 備份完成，已驗證外接碟裡有 VS Project、.claude 等資料，總大小 X GB。**現在可以安全關機了。**

---

## 備份內容（腳本會自動處理，由最重要到次要）

1. **桌面 / VS Project** — 專案，最優先
2. `~/.claude/` ＋ `~/.claude.json` — Claude Code 設定、skills、memory、歷史
3. **金鑰/設定**：`~/.ssh/`、`~/.config/`、`~/.gitconfig`、shell rc（`.zshrc`/`.bashrc`/`.zshenv`/`.p10k.zsh` 等）
4. **開發者憑證**：`~/.aws`、`~/.gnupg`、`~/.kube`、`~/.docker`、`~/.npmrc`、`~/.netrc`、`~/.terraform.d`
5. **VS Code 設定**：`~/Library/Application Support/Code/User`
6. **launchd**：`~/Library/LaunchAgents/` ＋ plist 指向的腳本 ＋ `launchctl list`
7. 自訂腳本：`~/bin`、`~/.local/bin`、`~/scripts`
8. `~/Documents`、`~/Desktop`、`~/Downloads` — 工作資料
9. **環境清單(純文字)**：Homebrew、App、VS Code 擴充、npm/pip 套件、工具版本、crontab

---

## 備援方案（只有在找不到 backup.sh 時才用）

直接執行下列指令完成最重要的備份：

```
OUT="/Volumes/YOUR_DRIVE_NAME/EmergencyBackup/mac-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"
rsync -a "$HOME/Desktop/VS Project" "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.claude"            "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.claude.json"       "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.ssh"               "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.config"            "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.gitconfig"         "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.zshrc"             "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/Library/LaunchAgents" "$OUT/" 2>>"$OUT/errors.log"
launchctl list > "$OUT/launchctl-list.txt" 2>/dev/null
rsync -a "$HOME/bin"                "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/.local/bin"         "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/scripts"            "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/Documents"          "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/Desktop"            "$OUT/" 2>>"$OUT/errors.log"
rsync -a "$HOME/Downloads"          "$OUT/" 2>>"$OUT/errors.log"
sync
du -sh "$OUT"
```

> 注意：備援方案不會自動解析 launchd plist 指向的腳本。若時間允許，請查看
> `~/Library/LaunchAgents/*.plist` 內容，把它們指向、且不在上面清單裡的腳本補備份。

完成後同樣執行步驟 4 驗證、步驟 5 回報。

---

## 背景（供你理解，不需處理）

- M3 MacBook 的 SSD 焊死且加密，資料只能靠原機開機取出，無法拆硬碟。
- 備份完關機，之後送修換螢幕。
