# Mouse-jiggler

Drags the mouse across the screen between widely-spaced zones, wiggles inside
each zone for a while, then drags to the next zone. Repeats indefinitely to
keep the screen awake. Cross-platform: Linux, macOS, Windows.

## Install

### Linux / macOS — one line

```bash
curl -fsSL https://raw.githubusercontent.com/WanderingBread0/Mouse-jiggler/main/install.sh | sh
```

Installs the right binary for your OS/arch into `~/.local/bin/mouse-jiggler`,
strips macOS Gatekeeper quarantine, and verifies the SHA256.

### Windows — one line (PowerShell)

```powershell
irm https://raw.githubusercontent.com/WanderingBread0/Mouse-jiggler/main/install.ps1 | iex
```

Installs into `%LOCALAPPDATA%\Programs\mouse-jiggler\` and adds it to your
user `PATH`. Open a new terminal afterwards.

Then run it from any terminal:

```bash
mouse-jiggler
```

Stop with `Ctrl+C`, or flick the mouse to a screen corner (failsafe).

---

## Manual download

Prefer to grab a binary yourself? Each release on the
[Releases page][releases] ships single-file binaries plus a `SHA256SUMS`:

| OS      | Architecture  | Asset                              |
| ------- | ------------- | ---------------------------------- |
| Linux   | x86_64        | `mouse-jiggler-linux-x86_64`       |
| Linux   | arm64         | `mouse-jiggler-linux-arm64`        |
| macOS   | Apple Silicon | `mouse-jiggler-macos-arm64`        |
| macOS   | Intel         | `mouse-jiggler-macos-x86_64`       |
| Windows | x86_64        | `mouse-jiggler-windows-x86_64.exe` |

[releases]: https://github.com/WanderingBread0/Mouse-jiggler/releases/latest

### Linux / macOS manual run

```bash
chmod +x ~/Downloads/mouse-jiggler-*
# macOS only — clears Gatekeeper quarantine if present:
xattr -dr com.apple.quarantine ~/Downloads/mouse-jiggler-* 2>/dev/null || true
~/Downloads/mouse-jiggler-*
```

On macOS, the first run will prompt for **Accessibility** permission
(*System Settings → Privacy & Security → Accessibility*). Approve the
terminal app, then run the binary again.

Linux requires an X11 session (libX11 / libXtst, present on most desktop
distros).

### Windows manual run

Double-click the `.exe`. SmartScreen may warn about an unsigned binary —
click *More info → Run anyway*.

---

## Options

```
--drag-time SECONDS     Time spent dragging between zones (default 1.5)
--wiggle-time SECONDS   Time spent wiggling in each zone (default 8)
--shuffle               Visit zones in random order instead of cycling
--no-failsafe           Disable the move-to-corner abort failsafe
```

## Run from source

```bash
pip install -r requirements.txt
python mouse_jiggler.py
```

## Uninstall

- Linux/macOS: `rm ~/.local/bin/mouse-jiggler`
- Windows: delete `%LOCALAPPDATA%\Programs\mouse-jiggler\` and remove that
  directory from your user `PATH`.
