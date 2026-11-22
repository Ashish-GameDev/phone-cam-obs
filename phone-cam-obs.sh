#!/usr/bin/env bash
# phone-cam-obs — stream an Android phone camera into a virtual camera for OBS on Linux.
# SPDX-License-Identifier: MIT
set -euo pipefail

DEV="${V4L2_DEV:-/dev/video10}"   # virtual camera created by scripts/setup.sh
CAMERA_ID="${CAMERA_ID:-1}"       # 1 = front, 0 = back, 2/3 = extra lenses
SIZE="${CAMERA_SIZE:-1280x720}"   # use `scrcpy --list-camera-sizes` to see options
FPS="${CAMERA_FPS:-30}"
BUFFER="${V4L2_BUFFER:-0}"        # ms; 0 = lowest latency (USB), 50-150 for Wi-Fi

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

for cmd in adb scrcpy; do
  command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' not found. Run: sudo ./scripts/setup.sh"
done

[[ -e "$DEV" ]] || die "$DEV not found. Run: sudo ./scripts/setup.sh"

adb get-state >/dev/null 2>&1 || die "no adb device. Enable USB debugging and check 'adb devices'."

printf 'phone-cam-obs: camera %s  %s@%s fps  ->  %s\n' "$CAMERA_ID" "$SIZE" "$FPS" "$DEV"
printf 'In OBS: the "Phone Camera" source (ffmpeg v4l2) reads %s automatically.\n' "$DEV"
printf 'Press Ctrl+C to stop.\n\n'

exec scrcpy \
  --video-source=camera \
  --camera-id="$CAMERA_ID" \
  --camera-size="$SIZE" \
  --camera-fps="$FPS" \
  --v4l2-sink="$DEV" \
  --v4l2-buffer="$BUFFER" \
  --no-video-playback
