# Screenprint Poster Maker

Turn a photo into a bold poster printed in two to four flat inks, in the style of the 2008 *Hope* poster, or into a two-tone image ready for a laser engraver, with a LightBurn project file to burn it. It's a single HTML file with no build step and no server, and your photos never leave the browser.

## Features

- **2, 3 or 4 inks.** More inks keep more detail. The default inks are navy, red, light blue and cream.
- **Any colours.** Change an ink with a colour picker or a hex code, or start from one of six presets.
- **Effect sliders.** Rotation, zoom, blur, brightness, contrast and line hatching.
- **Tone split.** Drag markers over a histogram of the photo to set how much of the picture each ink covers.
- **Message band.** An optional word along the bottom, in one of four typefaces.
- **PNG export** at 2400 px on the long side.
- **Laser engraving mode.** Dithers the photo to pure engrave/blank pixels at exactly one pixel per laser dot, with material presets, and exports a sized PNG plus a ready-to-run `.lbrn2` LightBurn file. See [Laser engraving](#laser-engraving).

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

## Laser engraving

Switch **Make a** to **Laser engraving**. The preview becomes the actual dot pattern that will be burned: every pixel is either *engraved* or *blank*, and there is one pixel per laser dot. Open `index.html#engrave` to start in this mode.

### Why one pixel per dot matters

A laser engraves a photo as rows of dots. The software (LightBurn, LaserGRBL, etc.) normally takes a grayscale image, resamples it to the machine's dot pitch, then dithers it. If you hand it an image that is *already* dithered at some other resolution, it resamples the dither pattern, which turns crisp dots into grey mush and moiré. So this mode does the opposite of the poster mode: it renders at the laser's own grid (for example 100 mm at 0.1 mm per dot = 1000 pixels wide), dithers there, and tells LightBurn to use the file as-is (**Pass-through**).

### Making an engraving

1. **Pick a material.** Each preset sets the preview colours, whether the picture is inverted, and sensible starting values for the midtones, sharpening and shadow density.
2. **Set the output.** Width in millimetres and the resolution (line interval). 254 DPI / 0.10 mm suits most diode and CO2 lasers; use 318 or 508 DPI only if your machine's spot is small enough. The readout shows the finished size, the dot grid and a rough job time.
3. **Choose a style** and adjust the tones. The preview updates on the real dot grid.
4. **Download.** **Download for LightBurn** saves a `.lbrn2` project with the image embedded, placed at the origin, sized correctly, on an Image layer with Pass-through on at the chosen DPI. **Download PNG** saves the same two-tone image with its physical size embedded, for any other laser software (in LightBurn, import it, set the layer to Image mode and switch Pass-through on).
5. **In LightBurn**, open the `.lbrn2` with **File → Open** (Import drops the layer settings), set your speed and power on the layer (the values in the file are only placeholders), and do not resize the image. If you must change the size, come back here and re-export at the new width.

### What the controls do

| Control | What it does | Why |
|---|---|---|
| Material | Preview colours, inversion and starting values | On slate, anodised metal, glass and coated tumblers the laser leaves a *light* mark on a *dark* surface, so the picture is inverted: bright areas get engraved |
| Invert | Flip which tones are engraved | Override the material's choice |
| Style | The dithering algorithm (see below) | Different materials hold different dot structures |
| Brightness, Contrast | Shift and stretch the tones after auto-levels | The photo's 1st–99th percentiles are always stretched to the full range first |
| Midtones | Gamma. Positive lifts the midtones | Burns come out darker than the screen suggests, so wood and leather presets start at +10 to +20 |
| Sharpen | Unsharp mask, radius about 1 dot | Dot spread blurs edges; sharpening before dithering brings them back |
| Smoothing | A small blur before dithering | Removes sensor noise and JPEG grain that error diffusion would otherwise amplify |
| Shadow density | Caps the share of dots burned in the darkest areas | 100% dots on wood merge into a charred patch with no detail; 85–90% keeps texture |
| Highlight density | Floor for the lightest areas | Normally 0; raise it to keep a faint tone in blown-out highlights |
| Dot size | Cell size for the Halftone style | Bigger dots burn more reliably on soft wood and glass |
| Tone split | Threshold for the Threshold and Poster styles | Where engraved meets blank |
| Speed, Power | Written into the LightBurn layer | Starting points only; test on scrap |

### Styles

| Style | Best for |
|---|---|
| Jarvis | Portraits and photos on wood. The smoothest tones |
| Stucki | Like Jarvis, slightly crisper and cleaner in flat areas |
| Floyd–Steinberg | Finest grain. Tile, slate, anodised metal, and anything with a small laser spot |
| Sierra | Between Floyd–Steinberg and Jarvis |
| Atkinson | Punchy, high-contrast look. Drops some error so highlights clear and shadows fill |
| Ordered (Bayer) | Even, predictable pattern with visible texture |
| Halftone dots | Clustered dots that grow with the shadows. Soft wood, glass, slow machines |
| Threshold | Two flat tones, no dots. Logos, text, line art |
| Poster | The screenprint look in one tone, with line hatching |

### The files

- **PNG.** Pure black (engrave) and white (blank), one pixel per dot, with a `pHYs` chunk carrying the DPI so it imports at the right size.
- **`.lbrn2`.** A LightBurn project (XML) containing the PNG as base64 in a `Bitmap` shape whose `W`/`H` are pixels × 25.4 / DPI and whose `XForm` holds the centre, plus one `CutSetting_Img` layer with `passThrough` on (LightBurn stores `ditherMode="threshold"` beside it), the DPI and line interval linked, and the speed and power from the Output section. The structure follows files written by LightBurn 0.9 to 2.0; the format is undocumented but plain XML.

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

In engrave mode the pipeline is: frame at the output dot grid → grayscale → smoothing → unsharp mask → auto-levels, brightness, contrast, gamma → tone to *share of dots to burn* (clamped between the highlight and shadow densities, inverted for light-on-dark materials) → dither to one bit per dot. Error diffusion scans alternate rows in opposite directions (serpentine) to avoid worm artefacts. Text and the band are drawn afterwards and snapped to pure two-tone so no anti-aliased grey pixels reach the laser. Jobs over about 2.4 million dots preview on a reduced grid and export at full size.

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
| `MATERIALS` | Engraving material presets: preview colours, inversion, shadow cap, midtones, sharpening and default style |
| `DITHERS`, `KERNELS` | The style list and the error-diffusion kernels |
| `INTERVALS` | The line intervals (mm) offered in the Resolution menu |
| `PREVIEW_MAX_DOTS` | Above this many dots the engrave preview renders on a reduced grid |

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
- **Lasers.** The `.lbrn2` file follows the structure of files LightBurn itself writes and was tested by parsing, not in every LightBurn version. If LightBurn ever refuses it, import the PNG instead: set the layer to Image mode and switch Pass-through on.

## Credits

- Inspired by Shepard Fairey's 2008 *Hope* poster and [obamapostermaker.com](https://obamapostermaker.com/).
- Sample photo: "Chelsea the cat" by Stefan van der Walt, CC0, from the [scikit-image](https://scikit-image.org/) sample data.
- Typefaces from [Google Fonts](https://fonts.google.com/) under the SIL Open Font License: Archivo, Montserrat, Oswald, Bebas Neue and Alfa Slab One.
