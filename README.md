# Mouse-jiggler

Drags the mouse across the screen between widely-spaced zones, wiggles inside
each zone for a while, then drags to the next zone. Repeats indefinitely to
keep the screen awake. Cross-platform: Linux, macOS, Windows.

## Download and run (no Python needed)

Grab the binary for your OS from the [Releases page][releases] and run it.
Each binary is a single self-contained file.

[releases]: https://github.com/WanderingBread0/Mouse-jiggler/releases/latest

### Windows

1. Download `mouse-jiggler-windows.exe`.
2. Double-click it. (SmartScreen may warn about an unsigned binary —
   click *More info → Run anyway*.)

### macOS

1. Download `mouse-jiggler-macos`.
2. In a terminal:
   ```bash
   chmod +x ~/Downloads/mouse-jiggler-macos
   xattr -d com.apple.quarantine ~/Downloads/mouse-jiggler-macos   # bypass Gatekeeper
   ~/Downloads/mouse-jiggler-macos
   ```
3. The first run will prompt for **Accessibility** permission
   (*System Settings → Privacy & Security → Accessibility*). Approve the
   terminal app, then run the binary again.

### Linux

1. Download `mouse-jiggler-linux-x86_64`.
2. In a terminal:
   ```bash
   chmod +x ~/Downloads/mouse-jiggler-linux-x86_64
   ~/Downloads/mouse-jiggler-linux-x86_64
   ```

Requires an X11 session (libX11 / libXtst, present on most desktop distros).

## Options

```
--drag-time SECONDS     Time spent dragging between zones (default 1.5)
--wiggle-time SECONDS   Time spent wiggling in each zone (default 8)
--shuffle               Visit zones in random order instead of cycling
--no-failsafe           Disable the move-to-corner abort failsafe
```

Stop with `Ctrl+C` in the terminal, or flick the mouse to a screen corner
(unless `--no-failsafe` is set).

## Run from source

```bash
pip install -r requirements.txt
python mouse_jiggler.py
```
