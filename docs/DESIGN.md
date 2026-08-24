# Rebase visual system

Clean-room tokens harvested from Typora's user-editable theme CSS on frostbyte, not from binary internals.

Typora preference on this machine: **Night**, `useDarkTheme = 1`.

Dark is the default. Light follows macOS appearance later. Phase 0 is dark-only.

## Dark (Night)

| Token | Value | Role |
|---|---|---|
| `paper` | `#363B40` | Window / page |
| `paper2` | `#2E3033` | Capture bar |
| `ink` | `#B8BFC6` | Entry text |
| `muted` | `#8A9198` | Date rules, counters, placeholders |
| `hairline` | `#555555` | Lane separators and date rules |
| `caret` | `#6DC1E7` | Focus / selected lane |
| `select` | `#4A89DC` | Text selection |

## Light (Newsprint, deferred)

| Token | Value | Role |
|---|---|---|
| `paper` | `#F3F2EE` | Window / page |
| `paper2` | `#E8E6DF` | Capture bar |
| `ink` | `#1F0909` | Entry text |
| `muted` | `#444444` | Date rules, counters |
| `hairline` | `#C9C6BB` | Separators |
| `caret` | `#065588` | Focus / selected lane |
| `select` | `rgba(32, 43, 51, 0.63)` | Text selection |

## Type

- Entry body: New York, 16pt, line-height 1.5
- Chrome / capture / lane labels: SF Pro
- Dates and edge counters: SF Mono, tabular lining numerals
- Date stamp: `8 · 23 · 26`

## Chrome

- Typeset notebook lines, not rounded cards
- 1px hairlines between lanes
- Hover reveals controls. Resting state is text and whitespace
- Lane widths: Ideas 37% / Life 37% / Work 26%
- Motion only to show location

## Boundary

Do not copy Typora code, assets, private symbols, or license logic. Theme CSS is the public customization surface. Ghidra is off the critical path for color.
