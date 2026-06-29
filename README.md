# mac-emergency-backup

> Emergency backup toolkit for water-damaged MacBooks: one script and a Claude Code instruction file to get all your important data onto an external drive before the machine dies.

English | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md)

---

## Why this exists

MacBook got water damaged. The M3 MacBook Air has the SSD soldered directly to the motherboard with hardware encryption. **The only way to get data out is to boot the original machine.** You cannot remove the drive and read it externally.

Built this toolkit with Claude Code, booted the water-damaged machine, and ran the entire backup from a phone via Claude's remote control. Under 10 minutes later, everything was safely on the external drive.

This is that toolkit, with personal details removed. I hope you never need it. But if you do, it should help you stay calm and move fast.

---

## What it includes

- **One-command backup script** (`backup.sh`): covers your project workspace, Claude Code settings, SSH keys, dotfiles, developer credentials, VS Code settings, launchd agents, and Documents/Desktop/Downloads
- **Claude Code instruction file** (`claude-backup-instructions.md`): lets Claude drive the backup, verify results, and report back. Designed for phone-based remote control so you minimize physical contact with a wet keyboard
- **Manual SOP checklist** (`手動SOP.md`): step-by-step checklist if you prefer to run everything yourself
- **Detailed guide** (`開機備份.md`): background, rationale for each step, and notes on restoring from exFAT

---

## Why Claude Code remote control

On a water-damaged machine, you want to minimize keyboard use to avoid short circuits. Claude Code supports `/remote-control`, letting you send commands from your phone's Claude app to Claude Code running on the laptop. No typing required.

The flow:
1. Plug in a fast external drive
2. Open Terminal, navigate to the external drive folder, run `claude`
3. On your phone, type: "Read claude-backup-instructions.md and run the backup for me"
4. Approve the permission prompts from your phone
5. Wait for "safe to shut down now"

---

## Quick start

### Prepare now (while your machine is healthy)

1. Clone this repo or download it, and put it on your external drive
2. Open `backup.sh` and update line 15 with your drive name:
   ```bash
   DEST="/Volumes/YOUR_DRIVE_NAME/EmergencyBackup"
   ```
3. Confirm Claude Code is installed: `claude --version`

### During an emergency

```bash
# Option A: Claude Code remote control (recommended)
cd /Volumes/YOUR_DRIVE_NAME
claude
# On your phone: "Read claude-backup-instructions.md and run the backup for me"

# Option B: Run the script directly (no Claude needed)
bash /Volumes/YOUR_DRIVE_NAME/backup.sh
```

When you see `✅ 備份完成` (Backup complete) with a size number, shut down immediately.

---

## What gets backed up

| Priority | Items |
|---|---|
| Highest | VS Code workspace folder (your main project directory) |
| High | `~/.claude/`, `~/.claude.json` (Claude Code settings, skills, memory) |
| High | `~/.ssh/`, `~/.config/`, `~/.gitconfig`, shell rc files |
| High | `~/.aws`, `~/.gnupg`, `~/.kube`, `~/.docker`, `~/.npmrc`, `~/.netrc` |
| Medium | VS Code settings, launchd agents and their referenced scripts |
| Medium | `~/bin`, `~/.local/bin`, `~/scripts` |
| Lower | `~/Documents`, `~/Desktop`, `~/Downloads` |
| Inventory | Homebrew packages, App list, npm/pip packages, tool versions |

---

## Requirements

- macOS (tested on M3 MacBook Air)
- External drive (exFAT format works; Thunderbolt 4 recommended for speed)
- Claude Code installed (for Option A only)

---

## Limitations

- The script targets macOS paths. It will not work on Linux or Windows.
- The default destination is an exFAT drive, which **does not preserve Unix permissions**. After restoring SSH keys and GPG keys, fix permissions manually:
  ```bash
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
  chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/*
  ```
- Backup size depends on your data. Expect 10 GB to 50 GB.
- If the machine smells, feels hot, or smokes: shut it down immediately. Data is replaceable, your safety is not.

---

## License

MIT License. See [LICENSE](LICENSE).
