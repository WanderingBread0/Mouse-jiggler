# Mouse-jiggler

Drags the mouse across the screen between widely-spaced zones, wiggles inside
each zone for a while, then drags to the next zone. Repeats indefinitely to
keep the screen awake. Cross-platform: works on Linux, macOS, and Windows.

## Install

```bash
pip install -r requirements.txt
```

Linux extras (one of these may be needed depending on the distro):

```bash
sudo apt install python3-tk python3-dev scrot
```

macOS: grant the terminal **Accessibility** permission in
*System Settings → Privacy & Security → Accessibility* so it can move the cursor.

Windows: no extra setup.

## Run

```bash
python mouse_jiggler.py
```

Options:

```
--drag-time SECONDS     Time spent dragging between zones (default 1.5)
--wiggle-time SECONDS   Time spent wiggling in each zone (default 8)
--shuffle               Visit zones in random order instead of cycling
--no-failsafe           Disable the move-to-corner abort failsafe
```

Stop it by pressing `Ctrl+C`, or by flicking the mouse to a screen corner
(unless `--no-failsafe` is set).
