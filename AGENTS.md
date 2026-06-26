# mac-emergency-backup — Agent Context

This repo contains an emergency backup toolkit for water-damaged MacBooks (M3/M4 with soldered SSD).

## Files

| File | Purpose |
|---|---|
| `backup.sh` | Main backup script. Line 15 sets `DEST` — must match the user's drive name. Uses `rsync -rLt` (not `-a`) to handle exFAT targets. |
| `claude-backup-instructions.md` | Claude Code instruction file. Designed to be read by Claude when the user says "back me up". All paths use `YOUR_DRIVE_NAME` as placeholder. |
| `開機備份.md` | Detailed human SOP. Explains each step and the reasoning behind it. |
| `手動SOP.md` | Quick checklist version of the SOP for the user to follow manually. |

## Key constraints

- Target filesystem is typically exFAT: no Unix permissions, no symlinks preserved. Use `rsync -rLt`, not `rsync -a`.
- Power-on time must be minimized: the machine may be water-damaged. Do not add exploratory steps.
- Never read or print the contents of credential files (`~/.ssh`, `~/.aws`, etc.). Only copy them and verify by size.
- `YOUR_DRIVE_NAME` is a placeholder throughout. The user must replace it with their actual drive name before use.

## Editing guidelines

- Keep instructions short and scannable. The user may be reading on a phone under stress.
- Security rule must not be softened: the prohibition on reading credential contents is intentional.
- If adding new backup targets to `backup.sh`, add them in priority order (most critical first).
