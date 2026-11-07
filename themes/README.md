# Editor themes

Each folder in here is a theme for the editor. Pick one from **More** (bottom of the bar down the
side of the editor) under **Look** - it's remembered.

To make your own: copy `default`, rename the copy, and edit its `theme.json`. **Reload the theme**
in the same menu shows your changes without restarting.

```json
{
	"name": "Default",
	"accent": "#2FB3A3",
	"background": null,
	"backgroundOpacity": 0.18,
	"layout": {
		"bar": "left",
		"barLabels": true
	},
	"splash": "splash.png"
}
```

| Setting | What it does |
| --- | --- |
| `accent` | The one highlight color - selected things, the active tool, Funkin Studio's tags. `#RRGGBB`. |
| `background` | A picture in this folder (eg. `"background.png"`) shown faintly behind the Home tab, Funkin Studio's start page and its editors' canvases. `null` for none. It fills the space and is cropped, never squashed. |
| `backgroundOpacity` | How much of the picture shows, from `0` (nothing) to `1` (all of it). Keep it low so text stays readable. |
| `layout.bar` | `"left"` or `"right"` - which edge the bar with Home / Game / Files... sits on. |
| `layout.barLabels` | `true` for a word under each icon, `false` for a slimmer icons-only bar. |
| `splash` | The picture on the startup screen, in this folder. Without one, the default theme's is used. |

## Sounds: the editor's own

A theme's `sounds/` folder is the editor's sounds - its clicks (`sounds/menu/scroll.ogg`,
`confirm.ogg`, `cancel.ogg`) and the charter's hitsound and metronome
(`sounds/editors/charter/hitsound.ogg`, `metronome.ogg`). Whatever your theme doesn't have comes
from `default`. They're only ever the editor's: a game never hears a theme's sounds, and a game's
own menu sounds never replace the editor's. **Editor sounds** in Editor Options switches the
clicks off (the charter's hitsound and metronome have their own switches).

`default/sounds/menu/` is also what a game falls back on when it has no menu sounds of its own.

## A theme is also the engine's asset pack

Everything else the engine itself ships lives in `default` too: `fonts/`, `images/`, `shaders/`,
`languages/` and `data/`. Your theme can replace any of it by having a file at the same path -
eg. `mytheme/fonts/vcr.ttf` - and whatever it doesn't have still comes from `default`. So a theme
can be just a `theme.json`, or a full font and picture pack.

Don't delete `default`: it's what every other theme falls back on.

The two layout settings also have switches in the **Look** menu; flipping one saves it into the
theme you're using.

Floating windows in Funkin Studio (Layers, Properties...) can be dragged and resized wherever you
like - that's remembered by itself, not part of a theme.
