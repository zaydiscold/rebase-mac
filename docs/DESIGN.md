# Rebase visual system

Quiet paper, readable type, and one accent that helps the structure make sense.

## Color

The app uses the following base tokens:

| Token | Light | Dark |
|---|---|---|
| paper | `#F1E9D2` | `#2C2E31` |
| ink | `#222222` | `#D2D5D8` |
| muted | `#666666` | `#8E9397` |
| open task | `#E62929` | `#E62929` |

Light mode shares its warm parchment with zayd.wtf. Dark mode stays slate rather
than blue-black.

The selected accent can be:

| Name | Hex |
|---|---|
| Orange | `#FF8040` |
| Violet | `#9B7DFF` |
| Lilac | `#9878D0` |
| Ice | `#98D8F8` |

The accent marks the selected lane, the compact bottom lane switcher, settings
controls, and the horizontal and vertical timeline rules. Structural rules use
about 30 to 34 percent opacity so the color is visible without taking over the
page.

## Entries

Ideas, Life, and Work all use the same task treatment:

- A quiet checkbox on the left.
- Serif body text.
- A bright red asterisk on the right when marked important.
- A quiet slate asterisk otherwise.

A checkbox toggles immediately. Double-clicking the task text performs the same
action while preventing accidental single-click completion.

## Timeline

The three lanes share one vertical scroll. Each day is one horizontal row, and
the tallest lane determines the row height. Shorter lanes keep intentional blank
space.

Date dividers span the full window. Collapsed days only show occupancy pips for
lanes with unfinished tasks. Empty and fully completed days show no pips.

## Capture bar

The bottom bar stays compact:

1. Settings gear.
2. Small Ideas, Life, and Work switcher.
3. Importance asterisk.
4. Borderless text field.
5. Submit glyph.

The lane headers and `Command-1` through `Command-3` provide the same selection
controls.

## Texture and motion

The bundled paper grain uses `softLight` at 5 percent in light mode and 12
percent in dark mode. Motion uses a short ease-out transition and respects
reduced-motion settings.
