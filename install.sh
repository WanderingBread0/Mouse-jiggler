#!/bin/sh
# Mouse-jiggler installer for Linux and macOS.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/WanderingBread0/Mouse-jiggler/main/install.sh | sh
#
# Environment overrides:
#   INSTALL_DIR   destination directory (default: $HOME/.local/bin)
#   VERSION       release tag to install (default: latest)
#   REPO          owner/name override for forks
set -eu

REPO="${REPO:-WanderingBread0/Mouse-jiggler}"
VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
BIN_NAME="mouse-jiggler"

err() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }

os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)

case "$os" in
  linux)  os_label=linux  ;;
  darwin) os_label=macos  ;;
  *) err "unsupported OS: $os (use install.ps1 on Windows)" ;;
esac

case "$arch" in
  x86_64|amd64) arch_label=x86_64 ;;
  aarch64|arm64) arch_label=arm64 ;;
  *) err "unsupported architecture: $arch" ;;
esac

asset="${BIN_NAME}-${os_label}-${arch_label}"
if [ "$VERSION" = "latest" ]; then
  url="https://github.com/${REPO}/releases/latest/download/${asset}"
  sums_url="https://github.com/${REPO}/releases/latest/download/SHA256SUMS"
else
  url="https://github.com/${REPO}/releases/download/${VERSION}/${asset}"
  sums_url="https://github.com/${REPO}/releases/download/${VERSION}/SHA256SUMS"
fi

mkdir -p "$INSTALL_DIR"
dest="$INSTALL_DIR/$BIN_NAME"
tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.sums"' EXIT

info "Downloading $asset"
if ! curl -fSL --progress-bar -o "$tmp" "$url"; then
  err "download failed: $url"
fi

# Best-effort checksum verification (skipped silently if SHA256SUMS not published)
if curl -fsSL -o "$tmp.sums" "$sums_url" 2>/dev/null; then
  expected=$(awk -v a="$asset" '$2 == a || $2 == "*"a {print $1; exit}' "$tmp.sums")
  if [ -n "$expected" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      actual=$(sha256sum "$tmp" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
      actual=$(shasum -a 256 "$tmp" | awk '{print $1}')
    else
      actual=""
    fi
    if [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
      err "checksum mismatch for $asset"
    fi
    [ -n "$actual" ] && info "Checksum verified"
  fi
fi

mv "$tmp" "$dest"
chmod +x "$dest"

if [ "$os" = "darwin" ]; then
  # Strip Gatekeeper quarantine; -dr is a no-op when the attribute is absent.
  xattr -dr com.apple.quarantine "$dest" 2>/dev/null || true
fi

info "Installed: $dest"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    printf '\n\033[33mNote:\033[0m %s is not on your PATH.\n' "$INSTALL_DIR"
    printf '  Add this to your shell rc file:\n'
    printf '    export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
    ;;
esac

printf 'Run it with:\n  %s\n' "$BIN_NAME"
if [ "$os" = "darwin" ]; then
  printf '\nFirst run on macOS may prompt for Accessibility permission\n'
  printf '(System Settings -> Privacy & Security -> Accessibility).\n'
fi
