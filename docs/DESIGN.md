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

Each date row is a disclosure handle above its content. Expanding the date keeps
the clicked row in place and reveals the shared three-lane day below it like a
quiet drawer. It never inserts content above the control the user clicked.

Date state remains readable while collapsed:

- Three lane pips and an open count indicate unresolved entries.
- A checkmark indicates a nonempty day with no open entries.
- A faint hollow pip indicates a completely empty day.
- Expanded dates use a restrained accent wash and stronger rule.

Empty dates start collapsed so the timeline begins directly beneath the fixed
lane header instead of showing an anonymous blank region. Explicit day and month
expansion choices persist across relaunches.

## Capture bar

The bottom bar stays compact:

1. Settings gear.
2. Small Ideas, Life, and Work switcher.
3. Importance asterisk.
4. Borderless text field.
5. Submit glyph.

The lane headers and `Command-1` through `Command-3` provide the same selection
controls.

## Settings

Updates occupy one compact row: installed version and commit, an automatic-check
toggle, one status line, Check now, and a contextual View action. The checker may
contact GitHub, but it never touches the Rebase data directory or replaces the
app in place.

## Texture and motion

The bundled paper grain uses `softLight` at 5 percent in light mode and 12
percent in dark mode. Motion uses a short ease-out transition and respects
reduced-motion settings. Date content moves only downward from its disclosure
row, so motion explains location instead of creating layout surprise.
