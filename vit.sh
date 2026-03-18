#!/usr/bin/env bash
# vit - Video In Terminal
# Plays YouTube videos as ASCII art with audio

set -e

# ── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

# ── banner ───────────────────────────────────────────────────────────────────
print_banner() {
  echo -e "${CYN}${BLD}"
  echo '  ██╗   ██╗██╗████████╗'
  echo '  ██║   ██║██║╚══██╔══╝'
  echo '  ██║   ██║██║   ██║   '
  echo '  ╚██╗ ██╔╝██║   ██║   '
  echo '   ╚████╔╝ ██║   ██║   '
  echo '    ╚═══╝  ╚═╝   ╚═╝   '
  echo -e "${YLW}  Video In Terminal${RST}"
  echo ""
}

# ── dependency check ─────────────────────────────────────────────────────────
check_deps() {
  local missing=()
  for cmd in yt-dlp mpv ffmpeg; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  # Check mpv has libcaca support
  if command -v mpv &>/dev/null; then
    if ! mpv --vo=help 2>/dev/null | grep -q caca; then
      echo -e "${RED}✗ mpv was found but lacks libcaca (ASCII) support.${RST}"
      echo -e "  Install ${YLW}libcaca${RST} and rebuild/reinstall mpv, or install ${YLW}mpv-full${RST} from AUR."
      exit 1
    fi
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}✗ Missing dependencies: ${missing[*]}${RST}"
    echo -e "  Install with: ${YLW}sudo pacman -S ${missing[*]}${RST}"
    echo -e "  (yt-dlp may need: ${YLW}sudo pacman -S yt-dlp${RST} or pip install yt-dlp)"
    exit 1
  fi
}

# ── get url ──────────────────────────────────────────────────────────────────
get_url() {
  if [[ -n "$1" ]]; then
    URL="$1"
  else
    echo -e "${BLD}Paste a YouTube URL and press Enter:${RST}"
    echo -ne "  ${YLW}▶ ${RST}"
    read -r URL
  fi

  if [[ -z "$URL" ]]; then
    echo -e "${RED}✗ No URL provided.${RST}"
    exit 1
  fi

  # Basic URL sanity check
  if ! echo "$URL" | grep -qE '(youtube\.com|youtu\.be)'; then
    echo -e "${YLW}⚠ This doesn't look like a YouTube URL — trying anyway...${RST}"
  fi
}

# ── fetch title ──────────────────────────────────────────────────────────────
get_title() {
  echo -ne "${CYN}  Fetching video info...${RST}"
  TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "Unknown title")
  echo -e "\r  ${GRN}✔${RST} ${BLD}${TITLE}${RST}                    "
}

# ── play ─────────────────────────────────────────────────────────────────────
play_video() {
  echo ""
  echo -e "${YLW}  Controls: ${RST}[space] pause  [←/→] seek  [q] quit  [9/0] volume"
  echo ""
  sleep 1

  # Get terminal size for best ASCII output
  COLS=$(tput cols 2>/dev/null || echo 160)
  ROWS=$(tput lines 2>/dev/null || echo 40)

  # Play with mpv:
  #   --vo=caca          → ASCII video output via libcaca
  #   --really-quiet     → suppress mpv log spam in terminal
  #   --no-video-aspect  → let caca use full terminal width
  #   ytdl format opts   → best quality with merged audio
  CACA_DRIVER=ncurses mpv \
    --vo=caca \
    --really-quiet \
    --msg-level=all=no \
    --ytdl-format="bestvideo[height<=480]+bestaudio/best[height<=480]/best" \
    --ytdl-raw-options="no-playlist=" \
    "$URL"
}

# ── self-update ───────────────────────────────────────────────────────────────
self_update() {
  INSTALL_DIR="$HOME/.local/share/vit"
  if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo -e "${CYN}Updating vit...${RST}"
    git -C "$INSTALL_DIR" pull --ff-only
    echo -e "${GRN}✔ Up to date!${RST}"
  else
    echo -e "${RED}✗ Can't find install dir at $INSTALL_DIR${RST}"
    exit 1
  fi
}

# ── main ─────────────────────────────────────────────────────────────────────
main() {
  case "$1" in
    --update|-u) print_banner; self_update; exit 0 ;;
    --help|-h)
      print_banner
      echo -e "  ${BLD}Usage:${RST} vit [URL]"
      echo -e "         vit --update"
      echo ""
      exit 0 ;;
  esac

  print_banner
  check_deps
  get_url "$1"
  get_title
  play_video
}

main "$@"
