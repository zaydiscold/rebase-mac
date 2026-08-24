# rebase

Private native Mac notepad. One shared timeline. Three lanes: Ideas, Life, Work.

**Capture everything. Face only today.**

The name is the verb. Unfinished work does not auto-copy into tomorrow. At midnight a clean day appears. Older items stay where they were captured. Command-R (later) rebases one old task at a time onto today, or leaves it, or closes it. That move is the product. The git pun is accidental.

This is a just-for-me app. Local only. No account, no server, no analytics, no AI in the capture path.

## run

```bash
cd ~/Desktop/Projects/rebase-mac
./Scripts/compile_and_run.sh
```

Cmd-comma opens settings. Cmd-1 / Cmd-2 / Cmd-3 pick Ideas / Life / Work. Return (or the up-arrow) adds. Ideas use a bullet. Life and Work use a checkbox. The red asterisk on any row marks it important for the day. Done tasks get a thin strikethrough and collapse to one line.

Days stack inside months. Current month plus the two previous months start open. Three months back and older start collapsed. No year grouping.

## notes live outside the app

```
~/Documents/Rebase/days.json
~/Documents/Rebase/settings.json
```

Rebuilding, pulling from GitHub, or deleting `Rebase.app` does not touch that folder. First launch migrates any older file from `~/Library/Application Support/Rebase/`.

## surface

zayd.wtf archive tokens, not Typora Night.

| token | dark | light |
|---|---|---|
| paper | `#1F1D18` | `#F1E9D2` parchment |
| ink | `#F1E9D2` | `#333333` |
| orange | `#FF8040` | Ideas/Life rule, selected pill |
| purple | `#9B7DFF` | Life/Work rule |

Fine grain overlay. Not fiber, not cement.

Motion follows the zayd.wtf anime.js bar: easeOutQuad, 220ms, opacity and offset only, gated on reduced-motion. Native SwiftUI, not a JS runtime.

## layout

One shared vertical scroll of day-sized rows, grouped by month. Row height is the max of the three lanes. Shorter lanes keep blank paper. A date rule (`8 · 23 · 26`) spans the window under the row. Newest day at the top. Default column shares 37 / 37 / 26, adjustable in settings.

## docs

- `docs/REBASE_MASTER_PLAN.md` product contract
- `docs/REBASE_GPT_PROJECT_INSTRUCTIONS.md` Notes dump triage
- `docs/DESIGN.md` tokens
- `docs/ARCHITECTURE_DECISIONS.md`

## not this

Not Notion. Not a markdown editor. Not a kanban. No tags, folders, priorities, streaks, or midnight carry-forward in v1.
