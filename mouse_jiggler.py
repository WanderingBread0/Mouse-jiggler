#!/usr/bin/env python3
"""Cross-platform mouse jiggler.

Drags the cursor across the screen between widely-spaced zones, wiggles
inside each zone for a while, then drags to the next zone. Keeps the
screen awake on Linux, macOS, and Windows.
"""
import argparse
import random
import sys
import time

try:
    import pyautogui
except ImportError:
    sys.stderr.write(
        "pyautogui is required. Install with:\n"
        "    pip install pyautogui\n"
        "On Linux you may also need: sudo apt install python3-tk python3-dev scrot\n"
    )
    sys.exit(1)


def pick_zones(width, height, margin_frac=0.06):
    """Return a list of (cx, cy, radius) zones spread across the screen."""
    mx = int(width * margin_frac)
    my = int(height * margin_frac)
    radius = max(40, min(width, height) // 14)
    return [
        (mx + radius, my + radius, radius),
        (width - mx - radius, my + radius, radius),
        (width // 2, height // 2, radius),
        (mx + radius, height - my - radius, radius),
        (width - mx - radius, height - my - radius, radius),
    ]


def drag_to(x, y, duration):
    pyautogui.moveTo(x, y, duration=duration, tween=pyautogui.easeInOutQuad)


def wiggle(cx, cy, radius, duration, step=0.25):
    end = time.time() + duration
    while time.time() < end:
        nx = cx + random.randint(-radius, radius)
        ny = cy + random.randint(-radius, radius)
        pyautogui.moveTo(nx, ny, duration=step, tween=pyautogui.easeInOutSine)


def main():
    p = argparse.ArgumentParser(description="Cross-platform mouse jiggler.")
    p.add_argument("--drag-time", type=float, default=1.5,
                   help="Seconds to drag between zones (default: 1.5).")
    p.add_argument("--wiggle-time", type=float, default=8.0,
                   help="Seconds to wiggle inside each zone (default: 8).")
    p.add_argument("--shuffle", action="store_true",
                   help="Visit zones in random order instead of cycling.")
    p.add_argument("--no-failsafe", action="store_true",
                   help="Disable pyautogui's move-to-corner abort failsafe.")
    args = p.parse_args()

    if args.no_failsafe:
        pyautogui.FAILSAFE = False

    width, height = pyautogui.size()
    zones = pick_zones(width, height)
    print(f"Screen {width}x{height}; jiggling across {len(zones)} zones. "
          f"Move mouse to a screen corner or press Ctrl+C to quit.")

    try:
        i = 0
        while True:
            zone = random.choice(zones) if args.shuffle else zones[i % len(zones)]
            cx, cy, r = zone
            drag_to(cx, cy, args.drag_time)
            wiggle(cx, cy, r, args.wiggle_time)
            i += 1
    except KeyboardInterrupt:
        print("\nStopped.")
    except pyautogui.FailSafeException:
        print("\nFailsafe triggered (mouse moved to corner). Stopped.")


if __name__ == "__main__":
    main()
