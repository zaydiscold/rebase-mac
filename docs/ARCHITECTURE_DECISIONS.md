# Architecture decisions

These decisions describe the app that exists now and the storage change planned
for later.

## ADR-001: Use one shared day-row timeline

Three independently scrolling columns would drift. Rebase uses one parent scroll
of day-sized rows, which keeps every date rule at the same vertical position.
The tallest lane determines the row height. Blank space in a shorter lane is
intentional.

## ADR-002: Keep the current build local and file-backed

The working app stores atomic entries in `~/Documents/Rebase/days.json` and
writes a Markdown copy to `rebase.md`. Settings live beside them in
`settings.json`.

SQLite through GRDB remains the planned persistence layer once the daily
interaction is settled. Markdown stays an import, export, and backup format.
The app must migrate existing files without deleting or duplicating entries.

## ADR-003: Use SwiftUI with a custom layout

The lanes are parallel streams, not a selection hierarchy. Rebase uses a custom
layout instead of `NavigationSplitView` so Ideas, Life, and Work remain aligned
inside one timeline.

## ADR-004: Ship a native SwiftPM Mac app

Rebase is Swift and AppKit/SwiftUI. It has no Electron runtime or account system.
The scripts build and package `Rebase.app` with bundle identifier
`com.zayd.rebase`.

## ADR-005: Give every lane the same task behavior

Ideas, Life, and Work all use checkboxes. The lane answers where a task belongs;
it does not change whether the entry can be completed. This keeps Rebase a
to-do list instead of turning Ideas into a permanent pile of non-actionable
bullets.

## ADR-006: Use one accent as structure

The chosen accent marks the active lane, bottom lane switcher, settings controls,
and timeline rules. Open tasks use a fixed bright red asterisk. Completed tasks
use slate. Light mode uses the zayd.wtf parchment token `#F1E9D2`.
