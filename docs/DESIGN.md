# Rebase visual system

Dark-first, with a light parchment mode in Settings. zayd.wtf archive tokens, not Typora Night.

Source: `~/dev/zayd-wtf/public/assets/css/styles.css` and `_docs/DESIGN.md`.

## Surface

| Token | Value | Role |
|---|---|---|
| `paper` | `#1F1D18` | Window. Darker than zayd.wtf `#2a2a2a`, warm undertone from parchment |
| `paper2` | `#161410` | Capture bar |
| `ink` | `#F1E9D2` | Entry text. This is zayd.wtf `--paper-base` / dark `--ink` |
| `muted` | `#C9C1AB` | Dates, placeholders. zayd.wtf dark `--muted` |
| `orange` | `#FF8040` | Ideas/Life rule, selected pill, capture-bar hairline. Light `--accent` |
| `purple` | `#9B7DFF` | Life/Work rule, unselected pill outline. Dark `--accent` |
| `dateRule` | parchment at 32% | Horizontal day lines |

Grain is a 512px tiled warm gaussian overlay at 16% with `softLight` blend. Fine analog variation. Not fiber, not cement, not a stain.

## Type

- Entry body: system serif, 16pt, line-height 1.5
- Chrome / capture / lane labels: SF Pro
- Dates and edge counters: SF Mono, tabular lining numerals
- Date stamp: `8 · 23 · 26`

## Chrome

- Typeset notebook lines, not rounded cards
- Vertical rules: orange then purple
- Horizontal date rules: quiet parchment
- Lane widths: Ideas 37% / Life 37% / Work 26%
