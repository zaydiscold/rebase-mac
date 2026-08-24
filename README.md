# Rebase

> I made this for me because my notes app lags and I need to do organized brain

Rebase is a local Mac to-do list with three lanes: Ideas, Life, and Work. All
three live on one timeline, so a date line stays aligned across the whole
window. Nothing needs an account, server, or subscription.

See the [public product and engineering plan](docs/REBASE_MASTER_PLAN.md) for the
stable interaction contract, current implementation, and issue-driven roadmap.

## Run it

Rebase requires macOS 15 or later.

Build, package, and open the app for the current Mac:

```bash
./Scripts/package_app.sh release
./Scripts/launch.sh
```

Build one universal app for both Apple silicon and Intel Macs:

```bash
./Scripts/compile_and_run.sh --release-universal
lipo -archs Rebase.app/Contents/MacOS/Rebase
```

The architecture check should list both `arm64` and `x86_64`. A universal Mac
binary is still a macOS app. It does not run on Windows.

## Use it

Write in the field at the bottom, choose Ideas, Life, or Work, optionally toggle
the asterisk for an important task, and press Return. The compact lane switcher
stays out of the way, and the same lanes are available through `Command-1`,
`Command-2`, and `Command-3`.

Every entry is a task with a checkbox. Important tasks use a bright red
asterisk; normal tasks use a quiet slate asterisk. Completed tasks use a thin
strike and one line of text. Double-click the task text to change its completion
state without making an accidental single click destructive.

The newest day sits at the top. Each full-width date rule closes the shared day
row above it. Click a date to collapse that day. A collapsed day only shows lane
pips for unfinished work. Empty and fully completed old days do not keep three
meaningless dots on screen.

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
~/Documents/Rebase/rebase.md       generated Markdown sidecar
~/Documents/Rebase/settings.json   appearance and layout
```

`rebase.md` keeps each day as a heading and each lane as a section. Every entry
uses a Markdown checkbox. A leading `*` records the important flag. The app
regenerates this sidecar whenever durable data changes, so manual edits can be
overwritten. Use the explicit Import action when a Markdown edit should replace
app data.

## Import semantics

Normal Rebase Markdown uses conventional checkbox meaning:

```text
- [ ] active normal entry
- [ ] * active important entry
- [x] resolved normal entry
- [x] * resolved important entry
```

The importer is strict and reports a source line for invalid dates, missing or
unknown lane headings, malformed checkboxes, and unrecognized nonempty content.
It fails before changing app state.

A legacy Apple Notes list may use `[x]` as an importance marker instead of
completion. Do not import that source through the normal Markdown action. A
lossless dedicated legacy mode is tracked in issue #5.

## Data and privacy

This repository is public. Never copy a real Rebase store, work notes, backups,
or exports into the checkout. The ignore file blocks the standard filenames as
a last line of defense, but the durable data belongs in `~/Documents/Rebase`,
not in Git.

Personal and employer data should use separate stores. Rebase has no network or
AI dependency for ordinary capture and retrieval.

The current public tree no longer embeds the original private planning
transcript. Removing an already published blob from historical Git objects is a
separate repository-history operation tracked in issue #12.

## Verification

Pull requests run the Swift regression suite, a release build, and a package job
that validates the real universal app bundle:

```bash
swift test --parallel
swift build -c release
SIGNING_MODE=adhoc ARCHES="arm64 x86_64" ./Scripts/package_app.sh release
```

CI requires both `arm64` and `x86_64`, strict code-signature verification, and
bundle metadata that matches `version.env`.

No tags, folders, streaks, projects, analytics, AI dependency, or automatic
midnight carry-forward.
