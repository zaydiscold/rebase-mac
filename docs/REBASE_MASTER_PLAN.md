# Rebase

## Public product and engineering plan

**Platform:** macOS 15 or later  
**Architecture:** native SwiftUI and AppKit  
**Product line:** **Capture everything. Face only today.**

This document is safe for a public repository. It describes the product contract,
current implementation, engineering boundaries, and roadmap without embedding
private notes, employer content, or the original personal planning transcript.

---

## 1. Product decision

Rebase is a local-first capture and triage application with exactly three
permanent lanes:

1. **Ideas**
2. **Life**
3. **Work**

The main screen is one synchronized chronological surface, not three unrelated
documents. Each calendar day is a horizontal row containing all three lanes.
The row grows to the height of its tallest lane, shorter lanes keep intentional
blank paper, and one date rule spans the full window below the row.

The app is not intended to become another project-management system, personal
wiki, calendar, reminder database, or Notion replacement. Its job is narrower:

> Make capture nearly frictionless, preserve chronology and context, separate
> unlike material, and stop the complete historical backlog from occupying the
> current working surface.

---

## 2. Problem model

A single running note tends to flatten unlike material into one visual state:

- Immediate obligations
- Personal tasks
- Work tasks
- Business and technical ideas
- Long-range plans
- Principles and observations
- Decisions that require research
- References and links

A checkbox list then makes every capture look like overdue executable work. The
result is not merely disorganization. It is a storage surface that continually
competes with execution.

Rebase separates **where an entry belongs** from **what eventually happens to
it**. The visible interface stays simple, while the durable model can later
support active, resolved, closed, archived, and recoverable-deleted states.

---

## 3. Stable product rules

### 3.1 Three lanes, no fourth lane

Ideas, Life, and Work are permanent. Archive, Trash, History, Search, Review,
and Now are views or states, not additional lanes.

### 3.2 Capture requires two decisions

Ordinary capture asks only:

- What is the text?
- Does it belong to Ideas, Life, or Work?

Importance is optional. No folder, project, tag, due date, estimate, icon,
priority matrix, or account is required.

### 3.3 Chronology is the native organization

The day is assigned automatically using `America/Los_Angeles`. Newest days sit
at the top. Entries are atomic records rather than one giant rich-text document.

### 3.4 Rebase moves, never copies

An unfinished entry does not duplicate itself at midnight. A future Rebase
review can intentionally move an entry to Today while preserving its original
capture date and event history.

### 3.5 Importance is not completion

Importance and status are independent. A capture can be active and important,
active and normal, resolved and important, or resolved and normal.

### 3.6 Repetition is a signal, not proof

Exact repeated captures may later collapse into one visible row with an echo
count while retaining each capture event. Repetition means the thought returned;
it does not automatically make the underlying action correct.

### 3.7 Local-first is a hard boundary

Ordinary capture and retrieval require:

- No account
- No server
- No analytics
- No network request
- No AI dependency

Employer data should remain in a separate work store and should not be sent to
an external service without explicit permission.

---

## 4. Current implementation

The working application currently includes:

- Native SwiftUI application shell with targeted AppKit bridges
- One shared vertical timeline
- Three parallel lanes inside every day row
- Custom maximum-height lane layout
- Full-width date divider below each day
- Newest date at the top
- Collapsible days and older months
- Bottom capture bar with lane selector and importance toggle
- `Command-1`, `Command-2`, and `Command-3` lane shortcuts
- Local JSON persistence in `~/Documents/Rebase/days.json`
- Generated Markdown sidecar in `~/Documents/Rebase/rebase.md`
- Appearance, accent, type-size, and column-width settings
- Strict normal Rebase Markdown import with line-aware errors
- Settings migration for invalid values from older builds
- Regression tests and macOS release builds in GitHub Actions
- Universal app packaging verified for `arm64` and `x86_64`

The current source of truth remains JSON. Markdown is an inspectable sidecar and
explicit import/export format, not the primary database.

---

## 5. Current interaction contract

### Capture

- Choose Ideas, Life, or Work.
- Optionally mark the entry important.
- Enter text and press Return.
- The new entry appears at the top of today's selected lane.
- The selected lane persists for rapid consecutive capture.

### Timeline

- All lanes share one scroll position.
- The tallest lane determines the day-row height.
- Blank space in shorter lanes is intentional.
- The date rule closes the day row above it.
- Empty historical days may be collapsed.

### Entries

- Every lane currently uses a checkbox.
- Important entries use a bright red asterisk.
- Completed entries use a thin strike and one line.
- Inline editing, moving, resolve-and-hide, Undo, History, and Trash remain
  planned.

### Settings

- Appearance: System, Dark, or Light
- Accent: Orange, Violet, Lilac, or Ice
- Body type size within a bounded range
- Resizable Ideas and Life shares with a guaranteed minimum Work width
- Markdown import/export and Finder access to the local store

---

## 6. Data files and safety

Current files:

```text
~/Documents/Rebase/days.json       source of truth
~/Documents/Rebase/rebase.md       generated Markdown sidecar
~/Documents/Rebase/settings.json   appearance and layout
```

The repository ignore rules defensively block these standard names, backups,
exports, and SQLite sidecars. Real stores must never be copied into the public
checkout.

The next data-safety milestone is larger than ordinary cleanup. It must add:

- Explicit load states: loaded, missing, recovered, or failed
- Visible Saved, Saving, and Save failed states
- Rotating validated backups
- Recovery from the newest valid snapshot
- Versioned, backward-compatible decoding
- Separate reporting for source-of-truth and Markdown-sidecar failures

Tracked in [issue #4](https://github.com/zaydiscold/rebase-mac/issues/4).

---

## 7. Markdown boundaries

### 7.1 Normal Rebase Markdown

The normal format uses conventional semantics:

```text
- [ ] active normal entry
- [ ] * active important entry
- [x] resolved normal entry
- [x] * resolved important entry
```

Import is strict:

- Dates must be valid `YYYY-MM-DD` headings.
- Every entry must appear under an explicit Ideas, Life, or Work heading.
- Unknown lanes, malformed checkboxes, and unrecognized nonempty lines fail with
  a source line number.
- Parse failure occurs before app state is mutated.
- Reserved leading asterisks and backslashes round-trip without changing
  importance.

### 7.2 Legacy Apple Notes material

A legacy source list may use checked boxes as a homemade **importance marker**,
not as completion. That source must not be fed directly into the normal Rebase
Markdown importer.

The dedicated legacy mode must interpret:

```text
[x] -> active + important
[ ] -> active + normal
```

It must preserve source wording, URLs, indentation, order, line numbers, and a
raw immutable copy before applying changes. This is tracked in
[issue #5](https://github.com/zaydiscold/rebase-mac/issues/5).

---

## 8. Backlog-control features

Three lanes alone are not enough. Each lane can eventually become another
infinite list. Rebase therefore needs two focused control surfaces.

### 8.1 Rebase review

`Command-R` should show one unresolved historical entry at a time with exactly
three actions:

1. **Today**: move the active date to today while preserving origin history
2. **Leave**: keep it on its historical date
3. **Close**: remove it from active attention without claiming completion

A session ends after ten decisions or whenever the user exits. Backlog zero is
never required.

### 8.2 Now mode

Now mode should show exactly one chosen entry and hide the inventory behind it.
Its actions are Complete, Continue, and Return. An optional elapsed timer may be
shown, but there are no streaks, scores, or guilt mechanics.

Both surfaces are tracked in
[issue #13](https://github.com/zaydiscold/rebase-mac/issues/13).

---

## 9. Near-term engineering roadmap

### P0: Trust and migration

1. Make storage observable, recoverable, and schema-safe: [#4](https://github.com/zaydiscold/rebase-mac/issues/4)
2. Add the lossless Legacy Apple Notes importer: [#5](https://github.com/zaydiscold/rebase-mac/issues/5)
3. Remove private planning material from historical Git objects if the repository remains public: [#12](https://github.com/zaydiscold/rebase-mac/issues/12)

### P1: Daily usability

1. Edit, move, resolve, undo, and recover entries: [#6](https://github.com/zaydiscold/rebase-mac/issues/6)
2. Multiline capture, draft recovery, and bulk paste: [#7](https://github.com/zaydiscold/rebase-mac/issues/7)
3. Accurate clickable backlog indicators and measured scaling: [#9](https://github.com/zaydiscold/rebase-mac/issues/9)
4. Rebase review and Now mode: [#13](https://github.com/zaydiscold/rebase-mac/issues/13)

### P2: Expansion

1. Preserve repeated captures as echo events: [#10](https://github.com/zaydiscold/rebase-mac/issues/10)
2. Define a portable schema and separate Rebase Work client: [#11](https://github.com/zaydiscold/rebase-mac/issues/11)
3. Publish Developer ID signed and notarized universal releases: [#23](https://github.com/zaydiscold/rebase-mac/issues/23)
4. Move durable storage to SQLite only after the interaction and migration
   contracts are proven
5. Add full-text search after the durable schema stabilizes

---

## 10. Windows and work-device direction

A universal Mac binary supports Apple silicon and Intel-based Macs. It does not
run on Windows.

The intended cross-platform direction is:

```text
rebase-mac       native SwiftUI/AppKit personal Mac client
rebase-windows   separate local-only work client
shared schema    versioned fixtures and behavioral contract
```

Personal and employer stores remain separate. There is no automatic sync until
identity, conflict, policy, and data-ownership behavior have been explicitly
defined and tested.

---

## 11. Performance contract

The current timeline uses an eager stack and geometry-derived backlog counts.
Changing it blindly to a lazy stack would make off-screen counts less reliable.
The correct order is:

1. Derive backlog counts from model position rather than rendered geometry.
2. Make indicators include collapsed days and months.
3. Add direct jump behavior.
4. Generate 10,000 and 100,000-entry fixtures.
5. Measure launch time, memory, capture latency, mutation latency, and scroll.
6. Introduce virtualization or pagination based on measurements.

Tracked in [issue #9](https://github.com/zaydiscold/rebase-mac/issues/9).

---

## 12. Visual direction

- Warm `#F1E9D2` parchment in light mode
- Quiet slate rather than blue-black in dark mode
- One selected accent for active lane, controls, and structural rules
- Serif reading text and system control text
- Monospaced date stamps and counters
- Low chrome
- No detached-card explosion
- No colorful priority matrix
- Motion only to communicate location or state change
- Typora-inspired direct writing, implemented clean-room without copied code,
  themes, assets, or binary internals

---

## 13. Deliberate non-features

Do not add these before the trust and execution layers are complete:

- Accounts
- Cloud sync
- AI classification in the capture path
- Folders
- Tags
- Project trees
- Mandatory due dates
- Time estimates
- Streaks
- Productivity scores
- Calendar dashboard
- Automatic midnight carry-forward
- Three independently scrolling lanes
- Typora reverse engineering as a build dependency

---

## 14. Verification contract

Every pull request must run:

```bash
swift test --parallel
swift build -c release
```

CI also packages the real application with both architecture slices and checks:

- `arm64` present
- `x86_64` present
- no unexpected third slice
- strict code-signature verification
- bundle identifier matches `version.env`
- minimum macOS version matches `version.env`

A future tagged release will additionally require Developer ID signing,
notarization, stapling, and downloaded-artifact Gatekeeper assessment.

---

## 15. Definition of product success

Rebase succeeds when this sequence is dependable:

1. Open the app and see today without being forced to face all history.
2. Press a lane shortcut, capture a thought, and press Return.
3. Capture a work obligation in the same aligned day row.
4. Close and reopen the application without losing either entry.
5. Correct mistakes, move entries, and resolve them without destroying history.
6. Review a bounded set of old material without being required to clear it all.
7. Enter Now mode and give one chosen commitment the foreground.
8. Trust that corruption, import errors, crashes, and upgrades will not silently
   erase the external memory being built.

Everything else is secondary.
