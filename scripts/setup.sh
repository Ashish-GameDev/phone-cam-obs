#!/usr/bin/env bash
# One-time host setup for phone-cam-obs. Run with sudo.
# SPDX-License-Identifier: MIT
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "This script installs packages and kernel-module config. Run it with sudo." >&2
  exit 1
fi

MODCONF=/etc/modules-load.d/v4l2loopback.conf
MODOPT=/etc/modprobe.d/v4l2loopback.conf

install_packages() {
  if command -v pacman >/dev/null 2>&1; then
    echo "==> Installing packages (Arch Linux)"
    pacman -S --needed scrcpy android-tools v4l2loopback-dkms ffmpeg
  elif command -v apt-get >/dev/null 2>&1; then
    echo "==> Installing packages (Debian/Ubuntu)"
    apt-get update
    apt-get install -y scrcpy adb v4l2loopback-dkms ffmpeg v4l-utils
  else
    echo "==> Unsupported package manager. Install manually: scrcpy, adb, ffmpeg,"
    echo "    v4l2loopback-dkms and v4l-utils, then re-run this script." >&2
    return 0
  fi
}

install_packages

echo "==> Writing v4l2loopback configuration"
mkdir -p "$(dirname "$MODCONF")" "$(dirname "$MODOPT")"
printf 'v4l2loopback\n' > "$MODCONF"
cat > "$MODOPT" <<'EOF'
options v4l2loopback devices=1 video_nr=10 card_label="Phone Camera" exclusive_caps=0 max_buffers=8
EOF

echo "==> Loading v4l2loopback"
modprobe -r v4l2loopback 2>/dev/null || true
modprobe v4l2loopback devices=1 video_nr=10 card_label="Phone Camera" exclusive_caps=0 max_buffers=8

echo
echo "Setup complete. /dev/video10 should now exist."
echo "Next: plug in your phone (USB debugging on), then run ./phone-cam-obs.sh"
echo "Then add an ffmpeg Media Source in OBS pointing at /dev/video10 (input_format v4l2)."
