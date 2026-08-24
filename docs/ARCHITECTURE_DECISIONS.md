# Architecture decisions

## ADR-001: Shared day-row timeline

Three independently scrolling columns would drift. One parent scroll of day-sized rows makes the date rule the same y-coordinate in every lane. Row height is the max of the three lanes. Blank space in a short lane is intentional.

## ADR-002: SQLite through GRDB, not Markdown files

Apple Notes lags because one document holds everything. Each thought is a database row. Markdown and JSONL are export and backup formats.

Deferred to Phase 1. Phase 0 is a static prototype.

## ADR-003: SwiftUI + custom Layout, not NavigationSplitView

The three lanes are parallel streams, not a selection hierarchy.

## ADR-004: Native SwiftPM Mac app

No Electron. No Tuist. Scripted `.app` packaging. Bundle id `com.zayd.rebase`. Local git only.

## ADR-005: Dark-first Typora Night tokens

Zayd's Typora is Night. Phase 0 ships those colors so the first window does not look like a generic productivity app.
