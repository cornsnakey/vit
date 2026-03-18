# VIT 
what is vit? vit stands for video in terminal
although, when you do it it opens a new window
this was made for a random reason
please know this is a beta and there probably Will be bugs (i had a issue with something in it myself)
---

## Install (Arch Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/vit/main/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/YOUR_USERNAME/vit
cd vit
bash install.sh
```

## Usage

```bash
vit                              # prompts you for a URL
video-in-terminal                # same thing, longer alias

vit https://youtu.be/dQw4w9WgXcQ (Don't search the link plz)   # pass URL directly
```

### Controls (while playing)

| Key | Action |
|-----|--------|
| `Space` | Pause / Resume |
| `←` / `→` | Seek 5 seconds |
| `9` / `0` | Volume down / up |
| `q` | Quit |

---

## How it works

- **yt-dlp** fetches the video stream URL (no full download needed)
- **mpv** plays the video using the `--vo=caca` driver (libcaca), which converts frames to coloured ASCII art in real time
- Audio is handled by mpv natively alongside the video

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `mpv` + `libcaca` | ASCII video playback |
| `yt-dlp` | YouTube stream resolution |
| `ffmpeg` | Audio/video demuxing |

> **Note:** The default `mpv` from the Arch repos includes libcaca support. If yours doesn't, install `mpv-full` from the AUR instead.

---

## Update

```bash
vit --update    # re-runs git pull in the install directory
```

Or just re-run `install.sh`.

---

## Uninstall

```bash
rm ~/.local/bin/vit ~/.local/bin/video-in-terminal
rm -rf ~/.local/share/vit
```
