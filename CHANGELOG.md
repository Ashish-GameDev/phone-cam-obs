# Changelog

All notable changes to this project are documented here.

## v1.0.0 (2026-11-22)

First public release.

- Stream the Android phone camera to `/dev/video10` via scrcpy + v4l2loopback.
- `scripts/setup.sh` installs dependencies and configures the virtual camera persistently.
- OBS integration documented using an ffmpeg Media Source (`input_format: v4l2`).
- Support for front/back/extra cameras, resolution and frame-rate options, and Wi-Fi buffering.
- MIT license, README and troubleshooting guide.
