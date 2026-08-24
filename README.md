# Rebase

> I made this for me because my notes app lags and I need to do organized brain

Rebase is a local Mac to-do list with three lanes: Ideas, Life, and Work. All
three live on one timeline, so a date line stays aligned across the whole
window. Nothing needs an account, server, or subscription.

## Run it

Build, package, and open the app:

```bash
./Scripts/package_app.sh release
./Scripts/launch.sh
```

Rebase requires macOS 15 or later.

## Use it

Write in the field at the bottom, choose Ideas, Life, or Work, optionally toggle
the asterisk for an important task, and press Return. The compact lane switcher
stays out of the way, and the same lanes are available through `Command-1`,
`Command-2`, and `Command-3`.

Every entry is a task with a checkbox. Important tasks use a bright red
asterisk; normal tasks use a quiet slate asterisk. Completed tasks use a thin
strike and one line of text. Double-click the task text to change its completion
state without making an accidental single click destructive.

The newest day sits at the top. Click a date to collapse it. A collapsed day
only shows lane pips for unfinished work. Empty and fully completed old days do
not keep three meaningless dots on screen.

## Make it yours

Open Settings with `Command-,` or the gear beside the capture field. You can:

- Choose light, dark, or system appearance.
- Pick orange, violet, lilac, or ice as the accent.
- Change the reading size.
- Resize the Ideas, Life, and Work lanes.
- Export or import Markdown.

The accent appears on the active lane, the compact bottom switcher, and the
horizontal and vertical timeline rules. Light mode uses the same `#F1E9D2`
parchment as zayd.wtf.

## Your files

Rebase keeps its data in Documents:

```text
~/Documents/Rebase/days.json       source of truth
~/Documents/Rebase/rebase.md       Markdown copy
~/Documents/Rebase/settings.json   appearance and layout
```

`rebase.md` keeps each day as a heading and each lane as a section. Every entry
uses a Markdown checkbox. A leading `*` records the important flag. Import and
export live in Settings.

No tags, folders, streaks, projects, analytics, AI dependency, or automatic
midnight carry-forward.
