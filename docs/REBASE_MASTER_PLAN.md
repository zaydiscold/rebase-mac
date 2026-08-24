# REBASE

## Master Product and Build Plan

**Owner:** Zayd  
**Plan date:** August 23, 2026  
**Platform:** macOS  
**Product status:** Plan first, then one narrow vertical slice  
**Working line:** **Capture everything. Face only today.**


## Current implementation status

The working Mac app uses SwiftUI and AppKit, one shared timeline, three
checkbox lanes, a compact bottom lane switcher, local JSON persistence, and a
Markdown sidecar. SQLite, search, Rebase review, and JSONL import remain later
work.

---

## 1. The decision

Build **Rebase** as a native, local-first Mac application with exactly three permanent lanes:

1. **Ideas**
2. **Life**
3. **Work**

The main screen is not three unrelated documents. It is one synchronized chronological surface. Every calendar day is a horizontal row containing all three lanes. The row grows to the height of whichever lane has the most content, and one date divider spans the full window underneath it.

That single structural decision is the heart of the app. It gives Zayd the visual model he described while avoiding fragile synchronized scroll logic.

Rebase is not another Markdown editor, project manager, calendar, reminder system, personal wiki, or Notion replacement. It is a pressure-release valve for a brain that captures more than it can act on at once.

---

## 2. The actual problem

The current problem is not merely that one Apple Note became large. Four different kinds of information are being forced into one undifferentiated stream:

- Immediate work obligations
- Personal and life obligations
- Business, technical, and creative ideas
- Maxims, identity statements, long-range plans, and thoughts worth preserving

Those things have different meanings, but a long note gives every line the same visual weight. A task for tomorrow sits beside a five-year ambition. An idea worth keeping indefinitely looks like an overdue chore. Old items stay physically present and continue competing for attention. The list becomes both a storage system and an accusation.

The correct product goal is therefore not "organize everything." That would create another system to maintain. The goal is:

> Make capture nearly frictionless, preserve chronology and context, separate unlike material, and prevent the full historical backlog from occupying today's working memory.

---

## 3. Product principles

### 3.1 Capture first, organize minimally

Every entry requires only two decisions:

- What is the text?
- Does it belong to Ideas, Life, or Work?

No title, folder, project, tag, priority, deadline, estimate, icon, color, or database property is required.

### 3.2 Entries are atomic

Each thought or task is stored as an independent record, not as one enormous rich-text document. The current build stores those records in `days.json`; the planned SQLite migration keeps the same atomic model.

### 3.3 Chronology is the native organization

The date is automatic. The user does not file entries into a hierarchy. The app's primary structure is simply when the thought was captured or last rebased.

### 3.4 The past exists without dominating the present

Old entries remain available and searchable, but the app opens at today. Unfinished historical tasks are represented by quiet edge counters until Zayd deliberately reviews them.

### 3.5 No automatic guilt machine

Tasks do not automatically duplicate or carry forward every midnight. Automatic carry-forward is how a manageable list becomes a permanent wall of failure. Rebase requires an intentional decision to bring an old task into today.

### 3.6 Rebase moves, never copies

When an old task is rebased to today, it appears once. Its original capture date remains in history, but the visible active date changes. No duplicate task is created.

### 3.7 Nothing important is truly deleted

Delete is soft-delete. Imports retain the raw source. Rebase operations are recorded. A daily backup is created automatically. The user should be able to experiment without fearing data loss.

### 3.8 Ideas and Life are visually dominant

The default lane widths should be:

- **Ideas: 37%**
- **Life: 37%**
- **Work: 26%**

Work gets enough room to function, but it does not visually take over the application.

---

## 4. The one-screen interface

```text
┌──────────────────────────────────── REBASE ────────────────────────────────────┐
│        IDEAS  37%        │          LIFE  37%         │       WORK  26%        │
│                          │                            │                         │
│  □ A protein design tool │  □ Submit gym claim       │  □ Prep meeting notes   │
│  □ Another idea          │  □ Call dentist           │  □ Review AI rollout    │
│                          │                            │                         │
│                          │                            │                         │
├─ 8 · 23 · 26 ──────────────────────────────────────────────────────────────────┤
│  □ Older idea            │  □ Older life task        │  □ Older work task      │
│                          │                            │                         │
├─ 8 · 22 · 26 ──────────────────────────────────────────────────────────────────┤
│                          │                            │                         │
│  ▼ 18 open ideas         │  ▼ 26 open life tasks     │  ▼ 41 open work tasks   │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Ideas  Life  Work       Write anything...                              Return ↵ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

This is a conceptual wireframe, not a final visual design.

### 4.1 One shared vertical scroll

The center of the app is one vertical scroll view. It contains a lazy stack of `DaySection` rows. Each `DaySection` contains one horizontal three-lane grid.

There must not be three independent vertical scroll views. Independent panes would require continuous scroll-position synchronization and would eventually drift. A shared parent scroll guarantees that every date line remains aligned.

### 4.2 Day row geometry

For each date:

1. Render the entries belonging to that day inside each lane.
2. Measure the natural height of each lane.
3. Set the day row height to the maximum of the three.
4. Allow the shorter lanes to contain blank space.
5. Draw one full-width date divider under the row.

The blank space is intentional. It communicates the actual shape of the day. A day full of ideas and nearly empty of work should look exactly like that.

### 4.3 Timeline direction

The newest day appears at the top. Older days continue downward. A newly captured entry appears at the top of today's relevant lane.

This matches the existing habit of adding new material to the top while allowing old material to accumulate below without requiring a jump to the end of a huge document.

### 4.4 Date format

The visible stamp should be compact and quiet:

`8 · 23 · 26`

Hovering or selecting it can reveal the full date:

`Sunday, August 23, 2026`

The app should use the IANA time zone identifier `America/Los_Angeles`, which means Pacific Time and correctly follows both standard time and daylight saving time. Internally, capture timestamps are stored in UTC while the day grouping is stored as a Pacific calendar date.

---

## 5. Capture behavior

### 5.1 The fixed capture bar

One input bar remains fixed to the bottom of the window. It contains:

- A three-way lane selector
- An importance toggle
- One text field

Keyboard behavior:

- `Command-1`: Ideas
- `Command-2`: Life
- `Command-3`: Work
- `Return`: Save
- `Shift-Return`: Insert a line break
- `Escape`: Clear or cancel
- `Command-Z`: Undo the last capture or edit

The selected lane persists after submission so a burst of related entries can be captured without repeatedly choosing the same lane.

### 5.2 Capture must remain dumb and dependable

No AI classification should run in the capture path. No network request should be required. No suggestion popover should interrupt typing. Zayd selects the lane, presses Return, and the entry exists.

The entire capture should feel safe in under two seconds.

### 5.3 Draft recovery

The unsent text in the capture bar is autosaved locally after a short idle period. If the app crashes or the Mac restarts, the draft returns.

### 5.4 Later global capture

After the main app is stable, add a global quick-capture window with a system-wide shortcut. It should use the same lane selector and save into the same database. This is not required for the first working build.

---

## 6. Entry behavior

### 6.1 Shared task model

Ideas, Life, and Work all use a quiet checkbox. Every entry can be open or
completed in the current build. Closed, archived, and recoverable-deleted states
remain planned.

The lane answers where an entry belongs. It does not decide whether the entry
can be finished.

### 6.2 Lane meaning

Ideas can hold a business concept, project thought, technical idea, observation,
or long-range plan. A checkbox does not make every idea urgent. It gives the
user one consistent way to clear anything that no longer needs attention.

Life holds personal obligations. Work holds employment and professional tasks.
All three lanes share the same visible completion behavior.

### 6.3 Inline editing

- A checkbox click toggles completion.
- Double-clicking task text toggles completion without making a single click destructive.
- Completed tasks use a thin strike and one line.
- Important tasks use a bright red asterisk; normal tasks use slate.
- Inline text editing remains later work.

### 6.4 Moving and reordering

- Drag within a lane to reorder entries on the same day.
- Drag across lanes to correct categorization.
- Reordering changes only presentation order, not timestamps.
- Moving across lanes changes categorization without changing completion state.

### 6.5 Markdown

The first build should support plain text reliably and render a small inline Markdown subset:

- Bold
- Italic
- Inline code
- Links
- Simple bullet continuation inside a multiline entry

Full Typora-style source hiding is a polish phase, not a prerequisite for proving the product. The product succeeds or fails on capture, chronology, and backlog control, not on perfect Markdown rendering.

---

## 7. The Rebase mechanic

This is the feature that turns the app from a prettier note into an actual crowd-control system.

### 7.1 Midnight behavior

At the first capture or launch after midnight in Pacific Time:

- A new day row becomes the top row.
- Old unfinished tasks remain on their historical dates.
- Nothing is copied into today.
- Quiet counters indicate that unresolved historical tasks exist below.

### 7.2 Edge indicators

Each lane may show a sticky top or bottom indicator inspired by off-screen game indicators:

- `▲ 4` means four relevant items exist above the viewport.
- `▼ 26 open` means twenty-six unresolved tasks exist below the viewport.
- Ideas, Life, and Work all count unresolved tasks.
- Clicking an indicator jumps to the nearest relevant item.
- The indicators should be subtle, not flashing red warnings.

### 7.3 Rebase review

`Command-R` opens a focused review overlay. It presents one old unresolved task at a time, never the whole backlog.

Each card has exactly three actions:

1. **Today**: Move the task's active date to today.
2. **Leave**: Keep it on its historical date and skip it for this review session.
3. **Close**: Mark it inactive without claiming it was completed.

A review session stops after ten items or whenever the user exits. The app must not demand backlog zero.

### 7.4 Historical integrity

Every task stores:

- Original capture timestamp
- Original calendar day
- Current active calendar day
- All rebase events
- Completion or closure timestamp

A rebased task can display a tiny provenance marker on hover, such as `from Aug 17`, but the main interface remains uncluttered.

### 7.5 No mandatory daily ritual

Rebase review is available, not compulsory. The application should never block capture behind a review modal, streak, score, or productivity lecture.

---

## 8. Search, history, and retrieval

### 8.1 Search

`Command-K` opens one search field across all entries. Results should:

- Match entry text
- Show lane and date
- Indicate open, completed, closed, archived, or deleted state
- Open the result in its original timeline context

The first version needs simple full-text search. Advanced filters can remain keyboard syntax rather than permanent interface chrome, for example:

- `lane:ideas protein`
- `lane:work status:open meeting`
- `before:2026-08-01 reimbursement`

### 8.2 Archive

Archive is not a fourth lane. It is a state. Archived ideas disappear from the default timeline but remain searchable and exportable.

### 8.3 Trash

Soft-deleted entries go to a recoverable Trash view. Automatic permanent deletion should be disabled in the first version.

---

## 9. Legacy-note migration

The first real migration is conversational, not a batch classification report.
The app ships with an empty timeline and no bundled sample entries.

### 9.1 Placement workflow

The workflow is:

1. Zayd pastes the to-do list in chat.
2. The assistant preserves every line in the pasted order.
3. For one entry at a time, the assistant asks:
   `Where does this go? 1 Ideas, 2 Life, or 3 Work?`
4. Zayd answers `1`, `2`, or `3`.
5. The confirmed entry is placed on the newest day in that lane.
6. The assistant moves to the next entry.
7. The final source-line and placed-entry counts must reconcile.

The assistant does not rewrite, split, merge, close, or prioritize entries
unless Zayd asks. Obvious duplicates can be flagged in one sentence, but Zayd
decides what stays.

### 9.2 Import safety

The current JSON file remains recoverable until the replacement list has been
checked in the real app. Future JSONL import can automate the same placement
workflow, but it is not required for the first real list.

---

## 10. Visual system

### 10.1 Typora-inspired, not copied

The useful Typora principle is not a proprietary implementation detail. It is the feeling of writing directly into a calm rendered page without a separate preview pane or visible machinery.

Rebase should reproduce that principle through clean-room implementation based on observable behavior. It should not copy Typora code, assets, themes, or binary internals.

### 10.2 Visual direction

- Warm `#F1E9D2` parchment in light mode and quiet slate in dark mode
- Very low interface chrome
- Accent-colored vertical separators between lanes
- Accent-colored horizontal date rules after each day
- Serif reading face for entry text
- System sans serif for controls
- Monospaced numerals for dates and counters
- One selected accent used consistently in light and dark mode
- No rounded card explosion
- No colorful priority matrix
- No motivational quotes generated by the app

### 10.3 Motion

Motion should communicate location, not entertain:

- New capture settles into place with a brief movement
- Rebased task visibly moves to today
- Edge indicator pulses once when its count changes
- No constant animation

### 10.4 Density

Entries should look like a beautifully typeset running notebook, not a board of detached cards. Hover can reveal controls so the resting interface remains mostly text and whitespace.

---

## 11. Technical architecture

### 11.1 Platform decision

Use **Swift and SwiftUI** for a native Mac application. The center timeline should be a custom `LazyVStack` of `DaySection` views, each containing a custom horizontal layout. Do not use `NavigationSplitView` for the three primary lanes because those lanes are parallel content streams, not a hierarchy where one column selects content for the next.

Use AppKit's `NSTextView` through `NSViewRepresentable` where the editor needs text behavior beyond SwiftUI's standard controls.

### 11.2 Persistence decision

The working build uses `~/Documents/Rebase/days.json` as its source of truth and
writes `rebase.md` beside it. This is simple, local, inspectable, and good enough
to validate daily use.

SQLite through GRDB remains the target persistence layer. The migration must
preserve every existing record and keep Markdown as an import, export, and
backup format.

### 11.3 Local-first boundary

Version 1 requires:

- No account
- No server
- No analytics
- No cloud dependency
- No AI dependency
- No network access for ordinary capture and retrieval

This matters especially for Work entries. Confidential employer content should not leave the Mac by default.

### 11.4 Suggested module structure

```text
Rebase/
├── App/
│   ├── RebaseApp.swift
│   ├── AppCommands.swift
│   └── AppEnvironment.swift
├── Database/
│   ├── DatabaseManager.swift
│   ├── Migrations.swift
│   ├── EntryRecord.swift
│   ├── EntryEventRecord.swift
│   └── SearchIndex.swift
├── Domain/
│   ├── Entry.swift
│   ├── Lane.swift
│   ├── EntryStatus.swift
│   ├── DayKey.swift
│   └── RebaseAction.swift
├── Timeline/
│   ├── TimelineView.swift
│   ├── DaySectionView.swift
│   ├── LaneColumnView.swift
│   ├── EntryRowView.swift
│   ├── DateDividerView.swift
│   └── EdgeIndicatorView.swift
├── Capture/
│   ├── CaptureBarView.swift
│   ├── CaptureDraftStore.swift
│   └── QuickCaptureWindow.swift
├── Review/
│   ├── RebaseReviewView.swift
│   └── RebaseReviewModel.swift
├── Search/
│   ├── SearchView.swift
│   └── SearchService.swift
├── ImportExport/
│   ├── LegacyImportService.swift
│   ├── JSONLCodec.swift
│   ├── MarkdownExporter.swift
│   └── BackupService.swift
└── Tests/
    ├── DatabaseTests/
    ├── TimelineLayoutTests/
    ├── ImportRoundTripTests/
    └── RebaseBehaviorTests/
```

### 11.5 Core schema

```sql
CREATE TABLE entries (
    id TEXT PRIMARY KEY NOT NULL,
    body TEXT NOT NULL,
    lane INTEGER NOT NULL,
    status INTEGER NOT NULL,
    captured_at REAL NOT NULL,
    captured_timezone TEXT NOT NULL,
    origin_day TEXT NOT NULL,
    active_day TEXT NOT NULL,
    sort_rank REAL NOT NULL,
    completed_at REAL,
    closed_at REAL,
    archived_at REAL,
    deleted_at REAL,
    source_id TEXT,
    source_line INTEGER,
    created_at REAL NOT NULL,
    updated_at REAL NOT NULL
);

CREATE INDEX entries_by_day_lane_rank
ON entries(active_day DESC, lane, sort_rank);

CREATE INDEX entries_open_tasks
ON entries(status, lane, active_day DESC);

CREATE TABLE entry_events (
    id TEXT PRIMARY KEY NOT NULL,
    entry_id TEXT NOT NULL REFERENCES entries(id),
    event_type TEXT NOT NULL,
    occurred_at REAL NOT NULL,
    payload_json TEXT NOT NULL
);
```

Add SQLite FTS5 after basic CRUD is stable.

### 11.6 Data location

Current files:

```text
~/Documents/Rebase/days.json
~/Documents/Rebase/rebase.md
~/Documents/Rebase/settings.json
```

The planned SQLite migration may move the source of truth to:

```text
~/Library/Application Support/Rebase/rebase.sqlite
```

That migration must leave human-readable backups in Documents and must never
wipe the existing JSON file before verification.

### 11.7 Markdown rendering

Initial display can use Foundation's Markdown-capable attributed strings. Inline source-hiding during editing can later be implemented with a custom `NSTextView` text-storage and layout layer. Do not let this difficult editor work block the core product.

---

## 12. Build sequence

### Phase 0: Freeze the product contract

Deliverables:

- This master plan
- One static visual prototype using fake data
- A written list of deliberate non-features
- A repository with a clean README and architecture decision record

Exit condition:

Zayd can look at one screen and say whether the spatial model matches the picture in his head. No database or Markdown editor work should begin before the shared day-row geometry feels correct.

### Phase 1: Functional vertical slice

Build only:

- Three fixed lanes
- Shared vertical timeline
- Date-aligned day rows
- Fixed bottom capture bar
- Create, edit, complete, close, archive, and soft-delete
- SQLite persistence
- Relaunch recovery
- Basic undo

Exit condition:

Rebase can replace the giant Apple Note for one ordinary day without losing an entry.

### Phase 2: Crowd control

Add:

- Off-screen lane indicators
- One-card-at-a-time Rebase review
- Historical provenance
- Search
- Keyboard navigation
- Draft recovery

Exit condition:

A large historical backlog can exist without being rendered as one giant present-day list.

### Phase 3: Migration and safety

Add:

- Legacy text import
- JSONL import
- Markdown export
- JSONL export
- Daily backups
- Trash recovery
- Import line mapping

Exit condition:

A representative section of the current Notes backlog can be migrated with zero silently dropped lines and exported back into readable text.

### Phase 4: Typographic polish

Add:

- Better inline Markdown editing
- Light and dark themes
- Refined typography
- Smooth but restrained transitions
- Accessibility labels
- Window restoration
- Performance instrumentation

Exit condition:

The app feels calm enough to leave open all day and fast enough that capture never feels risky.

### Phase 5: Optional expansion only after daily use proves the core

Possible later work:

- Global quick capture
- Menu-bar capture
- iPhone companion capture
- Sync
- Local model assisted import
- Calendar or Reminders export

None of these belongs in the initial build.

---

## 13. Performance and reliability requirements

The application should be tested against the behavior that broke the current workflow.

### 13.1 Performance targets

- Launch to usable interface without rendering the entire history
- Smooth scrolling across at least 50,000 entries
- Search across at least 100,000 entries without loading all text into Swift objects
- A single date containing 1,000 Ideas entries should remain navigable
- Capture should commit immediately and update the interface without blocking on export or backup work

### 13.2 Reliability tests

- Force quit during an unsent draft
- Force quit immediately after capture
- Rebase the same task repeatedly and confirm there is still only one visible task
- Cross midnight in Pacific Time
- Cross daylight-saving transitions
- Resize the window until columns become narrow
- Import text in bottom-up order
- Export and re-import without losing IDs, source lines, dates, or status
- Corrupt a backup copy and confirm the primary data remains intact
- Restore a soft-deleted entry

### 13.3 Privacy tests

- Confirm ordinary use produces no network traffic
- Confirm Work text never enters crash analytics because there is no third-party analytics SDK
- Confirm exports are opt-in except for the defined local backup directory

---

## 14. Deliberate non-features

These are exclusions, not missing work:

- No folders
- No nested pages
- No Kanban board
- No graph view
- No tags in the first version
- No priority levels
- No estimated durations
- No recurring tasks
- No calendar grid
- No collaboration
- No social layer
- No streaks
- No gamified productivity score
- No forced inbox-zero ritual
- No AI deciding what matters during capture
- No automatic carry-forward at midnight
- No plugin system
- No theme marketplace
- No web app
- No Electron shell

The application can gain features later only when repeated real use exposes a specific failure. It should not accumulate generic productivity features because other apps have them.

---

## 15. Reverse-engineering boundary

Do not make Ghidra work a prerequisite for Rebase.

Typora's relevant product behavior can be observed directly: low chrome, direct editing, rendered Markdown, strong typography, and no split preview. That is enough to formulate requirements and build a clean-room implementation.

Binary reverse engineering would be a bad first move for three reasons:

1. It does not solve the unique product problem, which is chronological three-lane crowd control.
2. It can consume the project in an interesting technical side quest before a usable app exists.
3. Copying proprietary implementation details or assets creates unnecessary legal and maintenance risk.

Any existing reverse-engineering notes can be converted into behavioral observations, such as cursor behavior, Markdown reveal rules, spacing, and keyboard interactions. Do not carry copied code, private symbols, assets, or implementation-specific material into the repository.

---

## 16. First implementation backlog

### Product and repository

- [x] Create repository named `rebase-mac`
- [x] Add this plan under `docs/REBASE_MASTER_PLAN.md`
- [x] Add `docs/ARCHITECTURE_DECISIONS.md`
- [x] Add the GPT project instructions file
- [x] Record the non-feature list in the README

### Data layer

- [ ] Define Lane, EntryStatus, DayKey, Entry, and EntryEvent
- [ ] Create GRDB database manager
- [ ] Add migration version 1
- [ ] Add entry create, update, soft-delete, and fetch queries
- [ ] Add event logging
- [x] Add a deterministic seeded-data generator

### Timeline

- [x] Create one shared ScrollView and LazyVStack
- [x] Create DaySection with three parallel lanes
- [x] Implement maximum-height day-row behavior
- [x] Draw the full-width date divider below each row
- [x] Keep newest day at the top
- [x] Virtualize old day rows

### Capture and editing

- [x] Create fixed bottom capture bar
- [x] Add lane shortcuts Command-1, Command-2, and Command-3
- [x] Add Return to submit
- [ ] Add Shift-Return for newline
- [ ] Add local draft recovery
- [ ] Add inline editing
- [x] Add task completion
- [ ] Add closure
- [ ] Add archive
- [ ] Add undo

### Rebase review

- [ ] Query historical open tasks without loading all history
- [ ] Display one task at a time
- [ ] Add Today, Leave, and Close actions
- [ ] Limit a session to ten items
- [ ] Preserve original date and record every move
- [ ] Add edge counts and jump behavior

### Import, export, and safety

- [ ] Preserve raw import source
- [ ] Implement JSONL import and export
- [x] Implement Markdown export grouped by date and lane
- [ ] Add import line mapping
- [ ] Create transactional daily backups
- [ ] Add Trash and recovery

### Validation

- [ ] Generate 100,000 test entries
- [ ] Profile launch and scroll behavior
- [ ] Test DST and midnight boundaries
- [ ] Test import in bottom-up order
- [ ] Test crash recovery
- [ ] Test export round trip

---

## 17. GPT chat mode

Use a dedicated project chat as Rebase's migration companion. It should contain
this plan, the project instructions, current screenshots, architecture
decisions, and the current build status.

The chat should not become another unstructured task pile. When Zayd pastes a
list, it works one entry at a time and asks:

`Where does this go? 1 Ideas, 2 Life, or 3 Work?`

After Zayd answers, the entry goes on the newest day in that lane. The companion
preserves the pasted wording and reconciles counts at the end. Tables,
normalization, deduplication, and import-file generation happen only when Zayd
asks for them.

For employer-related entries, redact confidential details unless company policy explicitly permits sharing them with an external AI service. Rebase itself remains local-first regardless of what is used during development.

---

## 18. Definition of the first real success

The first success is not a perfect Markdown engine or a polished app icon.

The first success is this sequence:

1. Zayd opens Rebase.
2. The app shows today's Ideas, Life, and Work without dumping months of backlog on screen.
3. He presses Command-1, writes an idea, and presses Return.
4. He presses Command-3, writes a work task, and presses Return.
5. Both entries appear under the same perfectly aligned date row.
6. He closes and reopens the app.
7. The entries are still there.
8. The interface remains calm.

Everything else comes after that.

---

## 19. Reference basis

- Typora's official product description emphasizes direct writing, live rendering, and removing the preview pane and mode switching: <https://typora.io/>
- Apple documents `NSViewRepresentable` as the bridge for AppKit views inside SwiftUI: <https://developer.apple.com/documentation/swiftui/nsviewrepresentable>
- Apple documents Markdown initialization for attributed strings: <https://developer.apple.com/documentation/foundation/instantiating-attributed-strings-with-markdown-syntax>
- GRDB is a Swift toolkit for SQLite application development: <https://github.com/groue/GRDB.swift>
- SQLite FTS5 provides full-text indexing and search: <https://www.sqlite.org/fts5.html>

---

# Appendix A: Original guiding prompt

The text below is preserved verbatim as product context.

```text
im like so disorganized and bad at getting myse a
I need a custom app on my Mac for myself. I'm trying to use like a trillion different Markdown editors. I tried to use notes and I tried to use Apple reminders. My to-do list is basically fucking so full that literally my notes app lags on all my devices. It's fucking bad.
Anyways we need to make a custom just-for-me app that I use on my Mac. I know we have some reverse engineering done on Typhora and feel free to do. We have Ghidra I think. Feel free to go harder on it. Rebase sounds good as hell&#x20;

Basically if you look, I don't even know if I want to make you look at my notes. I guess I could paste for an example but half of those things are more than half of those. I basically just put a to-do list starting from top to bottom and it stacks and goes on forever.
Any idea I have, whether or not it's a good business idea that I can pursue in the now or it's just a general mantra or a maxim for me to live by, I put those in my notes. Over two months it'll end up being such a long list that it's lagging because I can't do everything I even planned for the day. Half of it is to-do items for work, like "do this now, I have this meeting tomorrow." Some of it is the grand overarching plans about how I intend on moving up in the world, in life, and in projects and stuff.
There's no good way to currently, especially with my fucking retarded autistic brain, spaz out over these things and then get disabled and neutralized because I'm overwhelmed. This is my form of crowd control. I'm thinking I do three ways. I basically want this to be a three-tiled notepad with a beautiful look of type aura or something. Maybe you could help plan this. Yeah I should probably put this in plan mode first.  I guess yeah, there are the ideas. The way I'm thinking of breaking it down is into three general categories: ideas and two categories for to-do list, to-do life, and to-do for work. Life is far more important and ideas are far more important.
I was thinking some form of maybe a three-panel tiling and then there's a constant y-axis that gets drawn across. That's for the date. Even if one tile has the largest, like there's a lot of ideas for that day and a really short to-do list, which is optimal. That line gets drawn for the day, just to say, like 7, 13, 26. That line gets drawn under the ideas one so that way it's perfectly the same.
Kind of like video game damage indicators, they could tell you to scroll up, scroll down because there are so many things. I'm honestly just going to paste my to-do list and want you to go line by line and say, and I'll be pasting from the bottom up.
I guess I just want one entry box that tracks the date based on locations of computer time so it should just be like PST. I just enter my to-do list item and it goes to one of the three categories. I picked one of the three categories. I'm sure there are things that exist like this, like Notion or something, but I don't know. I get so overwhelmed. I just want, basically, don't even give me the options. I don't know what I want. I kind of know what I want vaguely but then I think about it and I overthink about everything. Just think a lot about it, make a plan, maybe even in the plan include my original prompt, which is everything I'm saying now in here, just at the bottom of the plan file, just for context. This is the guiding picture. I also kind of want to put this idea into the GPT chat mode.
```
