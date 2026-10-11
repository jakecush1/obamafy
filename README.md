# Screenprint Poster Maker

Turn a photo into a bold poster printed in two to four flat inks, in the style of the 2008 *Hope* poster. It's a single HTML file with no build step and no server, and your photos never leave the browser.

## Features

- **2, 3 or 4 inks.** More inks keep more detail. The default inks are navy, red, light blue and cream.
- **Any colours.** Change an ink with a colour picker or a hex code, or start from one of six presets.
- **Effect sliders.** Rotation, zoom, blur, brightness, contrast and line hatching.
- **Tone split.** Drag markers over a histogram of the photo to set how much of the picture each ink covers.
- **Message band.** An optional word along the bottom, in one of four typefaces.
- **PNG export** at 2400 px on the long side.

## Quick start

Everything is in `index.html`. Open it straight from disk:

```bash
open index.html        # macOS: opens it in your default browser
xdg-open index.html    # Linux
start index.html       # Windows
```

Or serve the folder locally, which is how it runs once hosted:

```bash
python3 -m http.server 8000   # serves this folder at http://localhost:8000
```

To put it online, upload `index.html` to any static host. For GitHub Pages, push this folder to a repo and turn on Pages for the branch that holds `index.html` (**Settings → Pages**).

## Making a poster

1. **Import a photo.** Click **Import photo**, drop an image anywhere on the page, or paste one. A sample photo loads at start.
2. **Frame it.** Pick a frame shape, then rotate and zoom. Drag the poster to move the photo inside the frame.
3. **Choose inks.** Set the number of inks, then edit them or click a preset. **Reverse order** swaps dark and light; **Random inks** rolls a new palette.
4. **Adjust the effects.** Blur merges detail into larger shapes, brightness and contrast shift the tones, and line hatching turns the edges between inks into horizontal stripes. Drag the **Tone split** markers to give an ink more or less of the picture.
5. **Write the message.** Type a word, then choose its typeface, band height, letter spacing and inks. You can also switch the band off.
6. **Download.** **Download PNG** saves the poster as `<message>-poster.png`.

To reset a single slider, double-click its name. Each section's **Reset** link resets the whole section.

## Controls

### Photo

| Control | Range | Default | Notes |
|---|---|---|---|
| Frame | Poster, Square, Photo shape | Poster | Poster is 1 : 1.38, Square is 1 : 1, and Photo shape uses the photo's own ratio |
| Rotation | −180° to 180° | 0° | At 100% zoom the photo scales up as it turns so the frame stays covered |
| Zoom | 50% to 400% | 100% | At 100% the photo fills the frame. Below 100% the whole photo shrinks inside it |

### Inks

There are four ink slots, ordered from darkest to lightest. The ink count decides which slots print in the picture:

| Inks | Slots that print |
|---|---|
| 2 | Shadow, Highlight |
| 3 | Shadow, Dark, Highlight |
| 4 | Shadow, Dark, Light, Highlight |

The paper border prints in the Highlight ink.

| Preset | Inks (darkest → lightest) |
|---|---|
| Classic | `#00304E` `#D71A21` `#71969F` `#FCE4A8` |
| Newsprint | `#161616` `#4D4D4D` `#A2A2A2` `#F1EFE8` |
| Riso | `#22378F` `#FF48B0` `#FFE800` `#F7F3E8` |
| Sunset | `#2B1640` `#C2185B` `#F57C00` `#FFE3A3` |
| Forest | `#11291E` `#2F6B3E` `#9BBF7A` `#F0F1D8` |
| Harbour | `#0B2545` `#13608A` `#8DB7CF` `#EEF4F2` |

### Effects

| Control | Range | Default | Notes |
|---|---|---|---|
| Blur | 0 to 100 | 30 | Smooths the photo before the tones are split. Higher values give larger, simpler shapes |
| Brightness | −100 to +100 | 0 | Shifts every tone lighter or darker |
| Contrast | −100 to +100 | 0 | Pushes tones apart (up to 4×) or pulls them together (down to ¼×) |
| Line hatching | 0 to 100 | 45 | Sets how wide the striped zone between inks is. 0 gives clean edges |
| Tone split | One marker per ink boundary | Even split | Sets where each ink starts. Arrow keys move a focused marker 1% (5% with Shift) |

### Message

| Control | Range | Default | Notes |
|---|---|---|---|
| Message | Up to 28 characters | HOPE | Sized automatically to fit the band |
| Typeface | Montserrat Black, Oswald Bold, Bebas Neue, Alfa Slab One | Montserrat Black | |
| All caps | On / off | On | |
| Band height | 50% to 170% | 100% | At 100% the band's height is a quarter of the image width |
| Letter spacing | −6 to +40 | +6 | In hundredths of the type size |
| Band ink / Letter ink | Any of the four inks | Shadow / Light | |
| Paper border | On / off | On | Adds a margin around the poster in the Highlight ink |

### Shortcuts

| Action | How |
|---|---|
| Move the photo | Drag the poster, or focus it and use the arrow keys (hold Shift for bigger steps) |
| Load a photo | Drop it anywhere on the page, or paste it |
| Reset one slider | Double-click its name |

## How it works

All of this runs on a canvas in plain JavaScript:

1. **Frame.** The photo is drawn into the poster's image area at the current zoom, rotation and offset.
2. **Grayscale.** Each pixel becomes a luminance value (Rec. 601 weights).
3. **Blur.** A Gaussian blur, approximated with three box-blur passes. The blur radius is a fixed share of the poster width, so the preview and the export look the same.
4. **Normalize.** Tones are stretched between the photo's 1st and 99th percentiles, so dark and bright photos both use every ink. Brightness and contrast are applied next.
5. **Split.** Each pixel takes the ink of the tone band it falls in. Line hatching adds a repeating offset row by row, which breaks the edges between inks into horizontal lines.
6. **Finish.** The border, message band and lettering are drawn on top.

The preview renders at screen resolution and caches the framing and blur steps, so changing an ink or a Tone split marker only redoes the split. Export runs the same pipeline at full size.

## Customizing

These settings are near the top of the script in `index.html`:

| Name | What it sets |
|---|---|
| `PRESETS` | The preset palettes, each with four inks from darkest to lightest. The first preset is the default |
| `SLOTS_FOR` | Which ink slots print at 2, 3 and 4 inks |
| `SLIDERS` | The value each slider resets to, and how its value is shown. Ranges are set on the `<input type="range">` elements |
| `S` | The starting state: frame, ink count, message, typeface, band and letter inks, border |
| `FONTS` | Message typefaces. A new one also needs adding to the Google Fonts `<link>` and the Typeface `<select>` |
| `EXPORT_LONG_SIDE` | Length of the exported PNG's long side, in pixels |
| `FRAME_ASPECT` | Height-to-width ratios of the Poster and Square frames |
| `SAMPLE_PHOTO` | The photo shown at start, as a data URI |

## Project structure

```
.
├── index.html   # the whole app: markup, styles, script and the sample photo
└── README.md
```

## Notes

- **Privacy.** Photos are read and processed in the browser and never uploaded. The only network requests are for Google Fonts, and system fonts are used if those fail to load.
- **Formats.** It opens any image the browser can decode: JPG, PNG, WebP and GIF everywhere, and HEIC only in browsers that support it.
- **Browsers.** It needs a current browser with Canvas 2D, Pointer Events and ResizeObserver. It was tested in Chromium.
- **Running inside Claude.** As a Claude artifact, **Download PNG** goes through the viewer's save prompt (`window.claude`). Everywhere else it's a normal browser download.

## Credits

- Inspired by Shepard Fairey's 2008 *Hope* poster and [obamapostermaker.com](https://obamapostermaker.com/).
- Sample photo: "Chelsea the cat" by Stefan van der Walt, CC0, from the [scikit-image](https://scikit-image.org/) sample data.
- Typefaces from [Google Fonts](https://fonts.google.com/) under the SIL Open Font License: Archivo, Montserrat, Oswald, Bebas Neue and Alfa Slab One.
