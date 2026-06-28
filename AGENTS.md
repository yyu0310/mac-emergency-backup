# mac-emergency-backup — Agent Context

## Your primary job

Help the user run the backup and shut down the machine quickly. That is the only goal.

If the machine is water-damaged, every extra minute of power-on is a risk. Do not explore, do not ask clarifying questions, do not do anything unrelated to getting the backup done.

---

## Two scenarios — identify which one applies

### Scenario A: Pre-emergency setup (machine is healthy)

The user wants to configure the toolkit before anything goes wrong.

Walk them through these steps:

1. Run `ls /Volumes` to find the external drive name
2. Open `backup.sh` line 15, replace `YOUR_DRIVE_NAME` with the actual drive name:
   ```bash
   DEST="/Volumes/ACTUAL_DRIVE_NAME/EmergencyBackup"
   ```
3. Also update the first line in the "Step 2" section of `claude-backup-instructions.md` to match
4. Save. Setup is complete — the toolkit is ready to use in an emergency

Optional: run `bash backup.sh` once on the healthy machine to verify it works end-to-end.

---

### Scenario B: Emergency (machine may be water-damaged)

**Act immediately. Every step counts.**

1. Run `ls /Volumes` — confirm the external drive is mounted and get its exact name
2. Check if `backup.sh` line 15 still says `YOUR_DRIVE_NAME`:
   - If yes → update it to the real drive name before proceeding
   - If no → skip to step 3
3. Run the backup:
   ```bash
   bash /Volumes/<drive-name>/backup.sh
   ```
   or if the script is in `~/Downloads`:
   ```bash
   bash ~/Downloads/backup.sh
   ```
4. Wait for `✅ 備份完成` and a size number in the output
5. Run `sync` to flush to disk
6. Report to the user:
   > ✅ Backup complete. Verified X GB on the external drive. Safe to shut down now.

For full step-by-step with error handling, read `claude-backup-instructions.md`.

---

## What success looks like

- Terminal shows `✅ 備份完成` with a non-zero size
- `EmergencyBackup/mac-backup-<timestamp>/` exists on the external drive
- Key folders present inside: `.claude`, `.ssh`, VS Code workspace folder

---

## Hard rules — never break these

- **Never read or print credential file contents** — `~/.ssh/*`, `~/.aws/*`, `~/.gnupg/*`, and any other key/token files. Copy by path only. Verify by filename and size (`ls`, `du`), never by content
- **Never add exploratory steps** during an emergency — no `find`, no `ls -R`, no detours
- **Never ask unnecessary questions** when the machine is on and at risk

---

## Files

| File | Purpose |
|---|---|
| `backup.sh` | Main script. **Line 15: set `DEST` to the user's drive before running.** Uses `rsync -rLt` (not `-a`) — exFAT cannot store Unix permissions or symlinks |
| `claude-backup-instructions.md` | Full Claude Code execution guide with error handling and fallback commands |
| `開機備份.md` | Detailed human SOP — rationale for each step, troubleshooting table |
| `手動SOP.md` | Quick human checklist for users who prefer to run without Claude |

---

## For contributors editing this repo

- Keep all instructions short and scannable — the user may be reading on a phone under stress
- The credential-reading prohibition must not be softened; it is intentional
- When adding new backup targets to `backup.sh`, insert them in priority order (most critical first)
- exFAT target: always use `rsync -rLt`, never `rsync -a`
