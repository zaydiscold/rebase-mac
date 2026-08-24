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

The newest day sits at the top. A date row is the handle for that day's drawer:
click it and the three lanes open below the date rather than pushing the clicked
row downward. Empty dates start compact. Explicit day and month disclosure
choices survive quit and relaunch.

Collapsed dates communicate their state without turning into a dashboard:
filled lane pips and an open count mean unresolved entries exist, a check means
the day has entries but none remain open, and a faint hollow pip means the day
is empty.

## Make it yours

Open Settings with `Command-,` or the gear beside the capture field. You can:

- Choose light, dark, or system appearance.
- Pick orange, violet, lilac, or ice as the accent.
- Change the reading size.
- Resize the Ideas, Life, and Work lanes.
- Check for updates automatically or manually.
- Export or import Markdown.

The accent appears on the active lane, the compact bottom switcher, date drawers,
settings controls, and timeline rules. Light mode uses the same `#F1E9D2`
parchment as zayd.wtf.

## Update checks

The Settings update row compares the packaged version and embedded Git commit
with the latest GitHub release and the current `main` commit. It can report:

- The installed build is current.
- A newer packaged release is available.
- New source exists on `main` but has not been released yet.
- No release has been published.
- The network check failed.

The action opens the relevant GitHub release or commit in the browser. Rebase
does not replace its own app bundle yet. Signed and notarized distribution is
tracked separately in issue #23.

Update checks never read, write, migrate, replace, or delete anything under
`~/Documents/Rebase`. Automatic checks can be disabled in Settings, and ordinary
capture remains completely local.

## Your files

Rebase keeps its data in Documents:

```text
~/Documents/Rebase/days.json       source of truth
~/Documents/Rebase/rebase.md       generated Markdown sidecar
~/Documents/Rebase/settings.json   appearance, layout, and update preference
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
