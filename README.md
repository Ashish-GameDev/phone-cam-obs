# phone-cam-obs

**Use your Android phone as a webcam in OBS on Linux — no app on the phone, no Windows, no watermark.**

[![version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/Ashish-GameDev/phone-cam-obs/releases)
[![license](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![platform](https://img.shields.io/badge/platform-Linux-orange)](README.md)

`phone-cam-obs` is a small, self-contained tool that turns an Android phone into a
virtual camera device on Linux. It uses [scrcpy](https://github.com/Genymobile/scrcpy)
in camera mode over ADB and feeds the frames into a `v4l2loopback` device that OBS
can read as a video source. Nothing is installed on the phone, and no root is required.

> This is an independent Linux project by **Ashish Sonawane ([Ashish-GameDev](https://github.com/Ashish-GameDev))**.
> It is inspired by the idea behind [Plugcam](https://github.com/Qwinty/plugcam), which is a
> Windows-only app; this project is the Linux/OBS equivalent built on scrcpy.

## Why

- **No app on the phone** — scrcpy's camera server is pushed over ADB only while streaming.
- **No OBS plugin to install** — the phone appears as a normal video device.
- **Lightweight** — a single shell script; scrcpy does the heavy lifting.
- **USB or Wi-Fi** — anything ADB can reach works.
- **Free and open source** — MIT licensed.

## How it works

```
phone camera ──▶ scrcpy-server ──▶ adb ──▶ scrcpy ──▶ /dev/video10 ──▶ OBS
                (H.264 in phone)   (USB/Wi-Fi)  (decode)  (v4l2loopback)  (Media Source)
```

## Requirements

- Linux with `adb`, `scrcpy`, `ffmpeg` and the `v4l2loopback` kernel module.
- Android 12 or newer phone with **USB debugging** enabled (camera capture needs 12+).
- OBS Studio (any recent version).

## Install

```bash
git clone https://github.com/Ashish-GameDev/phone-cam-obs.git
cd phone-cam-obs
chmod +x phone-cam-obs.sh scripts/setup.sh
sudo ./scripts/setup.sh
```

`setup.sh` installs the dependencies, creates the virtual camera `/dev/video10`
(labelled **Phone Camera**) and makes the module load automatically at boot.

## Usage

1. Plug in the phone and accept the USB debugging prompt. Check with `adb devices`.
2. Start the stream:

   ```bash
   ./phone-cam-obs.sh
   ```

   Keep it running (or detach it with `setsid nohup ./phone-cam-obs.sh >/tmp/phone-cam-obs.log 2>&1 &`).

3. In OBS, add a **Media Source**:
   - **Local File:** `/dev/video10`
   - **Input Format:** `v4l2`
   - Uncheck *Loop* / *Clear when media ends*.

   The source picks up the phone camera as soon as the script is streaming.

### Camera options

| Goal | Command |
|---|---|
| Front camera (default) | `./phone-cam-obs.sh` |
| Back camera | `CAMERA_ID=0 ./phone-cam-obs.sh` |
| Extra back lens | `CAMERA_ID=2 ./phone-cam-obs.sh` |
| 1080p | `CAMERA_SIZE=1920x1080 ./phone-cam-obs.sh` |
| Wi-Fi (more buffer) | `V4L2_BUFFER=100 ./phone-cam-obs.sh` |
| List camera sizes | `scrcpy --list-camera-sizes` |

## Troubleshooting

- **Camera busy on phone** — close other camera apps (DroidCam, stock camera).
  Identify the holder with `adb shell dumpsys media.camera`.
- **`/dev/video10` missing** — re-run `sudo ./scripts/setup.sh`.
- **OBS shows black** — confirm the script is running and test with:
  `ffmpeg -f v4l2 -i /dev/video10 -frames:v 1 /tmp/test.png`.
- **Why a Media Source instead of OBS's V4L2 source?** Some OBS builds cannot
  read `v4l2loopback` reliably (the `select timed out` bug). The ffmpeg-based
  Media Source uses the same device path and works consistently.

## Files

- `phone-cam-obs.sh` — main launcher (scrcpy → v4l2loopback).
- `scripts/setup.sh` — one-time host setup.
- `LICENSE` — MIT.
- `CHANGELOG.md` — release history.

## Credits

- [scrcpy](https://github.com/Genymobile/scrcpy) — Apache-2.0, does the camera capture.
- [v4l2loopback](https://github.com/umlaeute/v4l2loopback) — GPL-2.0, virtual camera device.
- [OBS Studio](https://obsproject.com/) — the target application.
- [Plugcam](https://github.com/Qwinty/plugcam) — inspiration for the phone-as-camera idea.

## License

[MIT](LICENSE) © 2026 Ashish Sonawane (Ashish-GameDev)
