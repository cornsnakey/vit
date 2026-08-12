# VIT
Video In Terminal — plays YouTube videos as ASCII art with audio.

## Install (Arch / Debian / Ubuntu)

curl -fsSL https://raw.githubusercontent.com/cornsnakey/vit/main/install.sh | bash

Or:

git clone https://github.com/cornsnakey/vit
cd vit
bash install.sh

## Usage

vit                     # prompts for a URL
vit <youtube-url>       # play directly

## Controls

Space     Pause / Resume
← / →     Seek 5s
9 / 0     Volume down / up
q         Quit

## Dependencies

mpv (with libcaca), yt-dlp, ffmpeg

Arch: mpv-full from AUR if libcaca is missing
Debian/Ubuntu: apt's mpv already includes libcaca

## Update

vit --update

## Uninstall

rm ~/.local/bin/vit ~/.local/bin/video-in-terminal
rm -rf ~/.local/share/vit