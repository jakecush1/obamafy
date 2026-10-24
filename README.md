# Poster & Engrave

Turn a photo into a flat-ink poster, or into a two-tone image ready for a laser engraver with a LightBurn project file to burn it. It is a single HTML file with no build step and no server, and photos never leave the browser.

## Features

**Poster mode**

- **2, 3 or 4 inks.** More inks keep more detail.
- **Any colours.** Change an ink with a colour picker or a hex code, or start from one of six palettes.
- **Effects.** Blur, brightness, contrast, line hatching, line density, and where the hatching goes.
- **Tone split.** Drag markers over a histogram of the photo to set how much of the picture each ink covers.
- **PNG export** at 2400 px on the long side.

**Laser engraving mode**

- **One pixel per laser dot.** The picture is dithered at the laser's own grid, so nothing is resampled on the way to the machine.
- **Material presets** for wood, leather, paper, tile, slate, anodised metal and glass, with inversion for materials where the laser leaves a light mark.
- **Nine styles** from Jarvis and Stucki error diffusion to halftone dots and flat two-tone.
- **Shaped pieces.** Make the piece a circle, oval, rounded rectangle, arch, heart, hexagon or star. The LightBurn file cuts it out, optionally with an engraved outline and a keychain hole.
- **Exports** a 1-bit PNG with its size embedded, and a `.lbrn2` LightBurn project with the image placed, sized and set to Pass-through, plus the cut layer.

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

To put it online, upload `index.html` to any static host. For GitHub Pages, push this folder to a repo and turn on Pages for the branch that holds `index.html` (**Settings → Pages**). `./update.sh` commits and pushes everything in one go.

Open `index.html#engrave` to start in engraving mode.

## Making a poster

1. **Import a photo.** Click **Import photo**, drop an image anywhere on the page, or paste one. A sample photo loads at start.
2. **Frame it.** Pick a frame, then rotate and zoom. Drag the preview to move the photo inside the frame.
3. **Choose inks.** Set the number of inks, then edit them or click a palette. **Reverse order** swaps dark and light; **Random inks** rolls a new set.
4. **Adjust the effects.** Blur merges detail into larger shapes, brightness and contrast shift the tones, and line hatching turns the edge of the shadow ink into horizontal lines. Drag the **Tone split** markers to give an ink more or less of the picture.
5. **Download.** **Download PNG** saves the poster.

To reset a single slider, double-click its name. Each section's **Reset** link resets the whole section.

## Making an engraving

Switch **Make a** to **Laser engraving**. The preview becomes the actual dot pattern that will be burned: every pixel is either *engraved* or *blank*, and there is one pixel per laser dot.

### Why one pixel per dot matters

A laser engraves a photo as rows of dots. Laser software normally takes a grayscale image, resamples it to the machine's dot pitch, then dithers it. If you hand it an image that is already dithered at some other resolution, it resamples the dither pattern, which turns crisp dots into grey mush and moiré. So this mode renders at the laser's own grid (for example 100 mm at 0.1 mm per dot = 1000 pixels wide), dithers there, and tells LightBurn to use the file as-is (**Pass-through**).

### Steps

1. **Pick a material.** Each preset sets the preview colours, whether the picture is inverted, and starting values for the midtones, sharpening and shadow density.
2. **Choose a shape** (optional). The piece becomes that shape: the preview shows it cut out, the margin is ignored, and the LightBurn file gets a cut layer along the edge (**Cut out the piece**, on by default). Circle, heart, hexagon and star set their own proportions; oval, rounded and arch follow the Frame choice. **Engrave an outline** adds a line just inside the edge. **Keychain hole** adds a small hole near the top edge; set its size and slide it left or right, and it moves down by itself until a rim of material fits around it.
3. **Set the output.** Width in millimetres and the resolution (line interval). 254 DPI / 0.10 mm suits most diode and CO2 lasers; use 318 or 508 DPI only if your machine's spot is small enough. The readout shows the finished size, the dot grid and a rough job time.
4. **Choose a style** and adjust the tones. The preview updates on the real dot grid.
5. **Download.** **Download for LightBurn** saves a `.lbrn2` project with the image embedded, placed at the origin, sized correctly, on an Image layer with Pass-through on at the chosen DPI, plus the cut layer. **Download PNG** saves the two-tone image with its physical size embedded, for any other laser software (in LightBurn, import it, set the layer to Image mode and switch Pass-through on). The PNG is rectangular; the cut-out comes from the `.lbrn2`.
6. **In LightBurn**, open the `.lbrn2` with **File → Open** (Import drops the layer settings), set your speed and power on both layers (the values in the file are only placeholders), and do not resize anything. If you must change the size, come back here and re-export at the new width.

### Engraving controls

| Control | What it does | Why |
|---|---|---|
| Material | Preview colours, inversion and starting values | On slate, anodised metal, glass and coated tumblers the laser leaves a *light* mark on a *dark* surface, so the picture is inverted: bright areas get engraved |
| Invert | Flip which tones are engraved | Override the material's choice |
| Shape | Makes the piece a circle, oval, rounded rectangle, arch, heart, hexagon or star | For ornaments, coasters, keychains and plaques. The dashed line in the preview is where the laser cuts |
| Engrave an outline | A line just inside the shape's edge (or around the picture when unshaped) | Hides the ragged dither edge and gives a finished look |
| Cut out the piece | A second, vector layer in the `.lbrn2` along the shape, or the outer rectangle | Circles and ovals are native LightBurn ellipses, the rest closed polylines. Speed and power on that layer are placeholders |
| Keychain hole | A small circular cut near the top edge | Hole size 2–10 mm; position slides left to right. A rim of at least 1.5 mm (or 90% of the hole radius) is kept, so the hole drops lower in narrow spots such as a star's point |
| Style | The dithering algorithm (see below) | Different materials hold different dot structures |
| Brightness, Contrast | Shift and stretch the tones after auto-levels | The photo's 1st–99th percentiles are always stretched to the full range first |
| Midtones | Gamma. Positive lifts the midtones | Burns come out darker than the screen suggests, so wood and leather presets start at +10 to +20 |
| Sharpen | Unsharp mask, radius about 1 dot | Dot spread blurs edges; sharpening before dithering brings them back |
| Smoothing | A small blur before dithering | Removes sensor noise and JPEG grain that error diffusion would otherwise amplify |
| Shadow density | Caps the share of dots burned in the darkest areas | 100% dots on wood merge into a charred patch with no detail; 85–90% keeps texture |
| Highlight density | Floor for the lightest areas | Normally 0; raise it to keep a faint tone in blown-out highlights |
| Dot size | Cell size for the Halftone style | Bigger dots burn more reliably on soft wood and glass |
| Tone split | Threshold for the Threshold and Poster styles | Where engraved meets blank |
| Width, Resolution | Physical size and dot pitch | The dot grid is width ÷ interval; the readout shows it |
| Speed, Power | Written into the LightBurn image layer | Starting points only; test on scrap |

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
| Poster | The poster look in one tone, with line hatching |

### The files

- **PNG.** A 1-bit grayscale PNG: black is engraved, white is blank, one pixel per dot, with a `pHYs` chunk carrying the DPI so it imports at the right size. Everything outside the shape, and the hole, is white.
- **`.lbrn2`.** A LightBurn project (XML) containing the PNG as base64 in a `Bitmap` shape whose `W`/`H` are pixels × 25.4 / DPI and whose `XForm` holds the centre, plus one `CutSetting_Img` layer with `passThrough` on (LightBurn stores `ditherMode="threshold"` beside it), the DPI and line interval linked, and the speed and power from the Output section. When anything is cut, a second `CutSetting type="Cut"` layer holds the outline as an `Ellipse`, a `Rect`, or a `Path` whose `VertList` is a run of `V<x> <y>` vertices in mm (Y up) with `PrimList` set to `LineClosed`, and the hole as a small `Ellipse`. LightBurn cuts inner shapes first by default, so the hole is cut before the outline. The structure follows files written by LightBurn 0.9 to 2.0; the format is undocumented but plain XML.

## Poster controls

### Photo

| Control | Range | Default | Notes |
|---|---|---|---|
| Frame | Portrait, Square, Landscape, Photo | Portrait | Portrait is 4 : 5, Landscape is 5 : 4, and Photo uses the photo's own ratio |
| Rotation | −180° to 180° | 0° | At 100% zoom the photo scales up as it turns so the frame stays covered |
| Zoom | 50% to 400% | 100% | At 100% the photo fills the frame. Below 100% the whole photo shrinks inside it |
| Margin | On / off | On | A margin around the picture in the Highlight ink (blank material when engraving). Ignored for shaped pieces |

### Inks

There are four ink slots, ordered from darkest to lightest. The ink count decides which slots print:

| Inks | Slots that print |
|---|---|
| 2 | Shadow, Highlight |
| 3 | Shadow, Dark, Highlight |
| 4 | Shadow, Dark, Light, Highlight |

| Palette | Inks (darkest → lightest) |
|---|---|
| Indigo | `#1E1B4B` `#4F46E5` `#A5B4FC` `#F5F3FF` |
| Mono | `#111111` `#4A4A4A` `#A3A3A3` `#F5F5F4` |
| Riso | `#22378F` `#FF48B0` `#FFE800` `#F7F3E8` |
| Ember | `#2B1640` `#C2185B` `#F57C00` `#FFE3A3` |
| Forest | `#11291E` `#2F6B3E` `#9BBF7A` `#F0F1D8` |
| Ocean | `#0B2545` `#13608A` `#8DB7CF` `#EEF4F2` |

### Effects

| Control | Range | Default | Notes |
|---|---|---|---|
| Blur | 0 to 100 | 30 | Smooths the photo before the tones are split. Higher values give larger, simpler shapes |
| Brightness | −100 to +100 | 0 | Shifts every tone lighter or darker |
| Contrast | −100 to +100 | 0 | Pushes tones apart (up to 4×) or pulls them together (down to ¼×) |
| Line hatching | 0 to 100 | 45 | Sets how wide the striped zone between inks is. 0 gives clean edges |
| Line density | 30 to 160 | 80 | Number of lines across the poster's width. Lower is bolder |
| Hatch | Shadows only, Every boundary | Shadows only | Shadows only hatches just the edge of the darkest ink. Every boundary hatches all of them |
| Tone split | One marker per ink boundary | Even split | Sets where each ink starts. Arrow keys move a focused marker 1% (5% with Shift) |

### Shortcuts

| Action | How |
|---|---|
| Move the photo | Drag the preview, or focus it and use the arrow keys (hold Shift for bigger steps) |
| Load a photo | Drop it anywhere on the page, or paste it |
| Reset one slider | Double-click its name |

## How it works

All of this runs on a canvas in plain JavaScript.

**Poster mode**

1. **Frame.** The photo is drawn into the image area at the current zoom, rotation and offset.
2. **Grayscale.** Each pixel becomes a luminance value (Rec. 601 weights).
3. **Blur.** A Gaussian blur, approximated with three box-blur passes. The blur radius is a fixed share of the poster width, so the preview and the export look the same.
4. **Normalize.** Tones are stretched between the photo's 1st and 99th percentiles, so dark and bright photos both use every ink. Brightness and contrast are applied next.
5. **Split.** Each pixel takes the ink of the tone band it falls in. Near a hatched boundary, rows alternate between the two inks as horizontal lines whose weight runs from 20% to 80% across the zone, so the lines thin and thicken without crumbling into specks. By default only the shadow boundary is hatched.

The preview renders at screen resolution and caches the framing and blur steps, so changing an ink or a Tone split marker only redoes the split. Export runs the same pipeline at full size.

**Engraving mode**

Frame at the output dot grid → grayscale → smoothing → unsharp mask → auto-levels, brightness, contrast, gamma → tone to *share of dots to burn* (clamped between the highlight and shadow densities, inverted for light-on-dark materials) → dither to one bit per dot. Error diffusion scans alternate rows in opposite directions (serpentine) to avoid worm artefacts. The shape mask, outline and hole are drawn afterwards and snapped to pure two-tone so no anti-aliased grey pixels reach the laser. In the preview the area outside the shape and the hole are transparent, so the piece looks cut out, and dashed lines mark the cuts. Jobs over about 2.4 million dots preview on a reduced grid and export at full size.

## Customizing

These settings are near the top of the script in `index.html`:

| Name | What it sets |
|---|---|
| `PRESETS` | The palettes, each with four inks from darkest to lightest. The first one is the default |
| `SLOTS_FOR` | Which ink slots print at 2, 3 and 4 inks |
| `SLIDERS` | The value each slider resets to, and how its value is shown. Ranges are set on the `<input type="range">` elements |
| `S` | The starting state: frame, ink count, margin, engraving defaults |
| `EXPORT_LONG_SIDE` | Length of the exported poster PNG's long side, in pixels |
| `FRAME_ASPECT` | Height-to-width ratios of the Portrait, Square and Landscape frames |
| `SAMPLE_PHOTO` | The photo shown at start, as a data URI |
| `MATERIALS` | Engraving material presets: preview colours, inversion, shadow cap, midtones, sharpening and default style |
| `SHAPES`, `shapePoints()` | The engraving shapes and the polygon each one is drawn, masked and cut with |
| `holeGeometry()` | Where the keychain hole goes and how much rim it keeps |
| `DITHERS`, `KERNELS` | The style list and the error-diffusion kernels |
| `INTERVALS` | The line intervals (mm) offered in the Resolution menu |
| `PREVIEW_MAX_DOTS` | Above this many dots the engrave preview renders on a reduced grid |

The look of the page is set by the design tokens at the top of the stylesheet (`--bg`, `--surface`, `--text`, `--accent` and so on), with a dark set under `prefers-color-scheme: dark`.

## Project structure

```
.
├── index.html   # the whole app: markup, styles, script and the sample photo
├── update.sh    # stages, commits ("update" or a message you pass) and pushes
└── README.md
```

To publish a change, run `./update.sh` or `./update.sh "what changed"`.

## Notes

- **Privacy.** Photos are read and processed in the browser and never uploaded. The only network request is for the Inter typeface from Google Fonts, and the system font is used if that fails to load.
- **Formats.** It opens any image the browser can decode: JPG, PNG, WebP and GIF everywhere, and HEIC only in browsers that support it.
- **Browsers.** It needs a current browser with Canvas 2D, Pointer Events and ResizeObserver. It was tested in Chromium.
- **Running inside Claude.** As a Claude artifact, downloads go through the viewer's save prompt (`window.claude`). Everywhere else they are normal browser downloads.
- **Lasers.** The `.lbrn2` file follows the structure of files LightBurn itself writes and was tested by parsing, not in every LightBurn version. If LightBurn ever refuses it, import the PNG instead: set the layer to Image mode and switch Pass-through on.

## Credits

- Sample photo: "Chelsea the cat" by Stefan van der Walt, CC0, from the [scikit-image](https://scikit-image.org/) sample data.
- Typeface: Inter, from [Google Fonts](https://fonts.google.com/) under the SIL Open Font License.
