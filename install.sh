#!/usr/bin/env bash
# install.sh — sets up the `vit` / `video-in-terminal` command on Arch Linux and Debian/Ubuntu
set -e

REPO_URL="https://github.com/cornsnakey/vit" # ← replace before publishing
INSTALL_DIR="$HOME/.local/share/vit"
BIN_DIR="$HOME/.local/bin"

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

echo ""
echo -e "${CYN}${BLD} VIT Installer${RST}"
echo -e " ─────────────────────────────"
echo ""

# ── 0. detect distro / package manager ─────────────────────────────────────
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt-get &>/dev/null; then
    DISTRO="debian"
else
    echo -e "${RED}✘ Unsupported distro: no pacman or apt-get found.${RST}"
    echo -e "  This installer supports Arch Linux and Debian/Ubuntu-based systems."
    exit 1
fi

# ── 1. install dependencies ─────────────────────────────────────────────────
echo -e "${BLD}[1/4] Checking dependencies (${DISTRO})...${RST}"

if [[ "$DISTRO" == "arch" ]]; then
    PACMAN_PKGS=()
    for pkg in ffmpeg libcaca; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            PACMAN_PKGS+=("$pkg")
        fi
    done

    if ! pacman -Q mpv &>/dev/null && ! pacman -Q mpv-full &>/dev/null; then
        PACMAN_PKGS+=(mpv)
    fi

    if [[ ${#PACMAN_PKGS[@]} -gt 0 ]]; then
        echo -e " Installing: ${YLW}${PACMAN_PKGS[*]}${RST}"
        sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    else
        echo -e " ${GRN}✔ pacman deps already installed${RST}"
    fi

    if ! command -v yt-dlp &>/dev/null; then
        echo -e " Installing yt-dlp..."
        if pacman -Si yt-dlp &>/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm yt-dlp
        else
            pip install --user yt-dlp
        fi
    else
        echo -e " ${GRN}✔ yt-dlp already installed${RST}"
    fi

elif [[ "$DISTRO" == "debian" ]]; then
    APT_PKGS=()
    for pkg in ffmpeg mpv; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            APT_PKGS+=("$pkg")
        fi
    done

    if [[ ${#APT_PKGS[@]} -gt 0 ]]; then
        echo -e " Installing: ${YLW}${APT_PKGS[*]}${RST}"
        sudo apt-get update
        sudo apt-get install -y "${APT_PKGS[@]}"
    else
        echo -e " ${GRN}✔ apt deps already installed${RST}"
    fi

    if ! ldconfig -p 2>/dev/null | grep -q libcaca; then
        echo -e " Installing libcaca0 (mpv ASCII output)..."
        sudo apt-get install -y libcaca0 || true
    fi

    if ! command -v yt-dlp &>/dev/null; then
        echo -e " Installing yt-dlp..."
        if command -v pipx &>/dev/null; then
            pipx install yt-dlp
        else
            pip install --user --break-system-packages yt-dlp 2>/dev/null || pip install --user yt-dlp
        fi
    else
        echo -e " ${GRN}✔ yt-dlp already installed${RST}"
    fi
fi

echo ""

# ── 2. clone / update repo ────────────────────────────────────────────────────
echo -e "${BLD}[2/4] Setting up vit...${RST}"
mkdir -p "$INSTALL_DIR"
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo -e " Updating existing install..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo -e " Cloning ${YLW}${REPO_URL}${RST}..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
chmod +x "$INSTALL_DIR/vit.sh"
echo -e " ${GRN}✔ Files ready at $INSTALL_DIR${RST}"
echo ""

# ── 3. create symlinks ────────────────────────────────────────────────────────
echo -e "${BLD}[3/4] Installing commands...${RST}"
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/vit.sh" "$BIN_DIR/vit"
ln -sf "$INSTALL_DIR/vit.sh" "$BIN_DIR/video-in-terminal"
echo -e " ${GRN}✔ Commands linked:${RST} vit / video-in-terminal"
echo ""

# ── 4. PATH check ─────────────────────────────────────────────────────────────
echo -e "${BLD}[4/4] Checking PATH...${RST}"
if echo "$PATH" | grep -q "$BIN_DIR"; then
    echo -e " ${GRN}✔ $BIN_DIR is already in your PATH${RST}"
else
    echo -e " ${YLW}⚠ $BIN_DIR is not in your PATH.${RST}"
    echo -e " Adding it now to your shell config..."
    SHELL_RC=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ "$SHELL" == *"fish"* ]]; then
        SHELL_RC="$HOME/.config/fish/config.fish"
    fi

    if [[ -n "$SHELL_RC" ]]; then
        if [[ "$SHELL" == *"fish"* ]]; then
            echo "fish_add_path $BIN_DIR" >> "$SHELL_RC"
        else
            echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
        fi
        echo -e " ${GRN}✔ Added to $SHELL_RC${RST}"
        echo -e " ${YLW}→ Restart your terminal or run: source $SHELL_RC${RST}"
    else
        echo -e " Add this line to your shell config manually:"
        echo -e " ${YLW}export PATH=\"$BIN_DIR:\$PATH\"${RST}"
    fi
fi

echo ""
echo -e "${GRN}${BLD} ✔ VIT installed successfully!${RST}"
echo ""
echo -e " Run it with: ${CYN}vit${RST} or ${CYN}video-in-terminal${RST}"
echo -e " Or pass URL: ${CYN}vit https://youtu.be/...${RST}"
echo ""