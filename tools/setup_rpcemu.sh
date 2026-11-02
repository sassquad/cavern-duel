#!/bin/bash
# Install RPCEmu Extended for macOS plus RISC OS 5 (Direct) and RISC OS 3.71
# machines made from the Easy Start bundles, with this project's app/ folder
# as the Shared drive that every machine sees.
#
#   tools/setup_rpcemu.sh [data-dir]      (default: ~/RPCEmu-Extended)
#
# Safe to re-run: downloads are cached in <data-dir>/Downloads and existing
# machines are left alone (delete a machine's folders to rebuild it).
set -euo pipefail

ROOT="${1:-$HOME/RPCEmu-Extended}"
PROJECT_APP="$(cd "$(dirname "$0")/.." && pwd)/app"
DOWNLOADS="$ROOT/Downloads"
APP="$HOME/Applications/RPCEmu-Extended.app"

RPCEMU_VERSION="2.0.0"
RPCEMU_FILE="rpcemu_${RPCEMU_VERSION}_macos_universal.tar.gz"
RPCEMU_URL="https://github.com/andrewtimmins/rpcemu-extended/releases/download/v$RPCEMU_VERSION/$RPCEMU_FILE"
# Easy Start "Other platforms" editions, from http://www.marutan.net/rpcemu/easystart.html
DIRECT_ID="1uIAUIB8wuixm2-49bXQSvnLjdeN8ePaz"
RO371_ID="1HWd67HYNRsIh9wgQZZT06GsANlYd4V4i"

fetch() {  # url file test-command
    if [ -s "$2" ]; then
        echo "Already downloaded: $(basename "$2")"
    else
        echo "Downloading $(basename "$2")..."
        curl -fL --progress-bar -o "$2.part" "$1"
        mv "$2.part" "$2"
    fi
    # Google Drive answers with an HTML page when it refuses a download
    if ! $3 "$2" >/dev/null 2>&1; then
        rm -f "$2"
        echo "$(basename "$2") is not a valid archive. Download it in a browser" >&2
        echo "and save it as $2, then run this script again." >&2
        exit 1
    fi
}

drive_url() {
    echo "https://drive.usercontent.google.com/download?id=$1&export=download&confirm=t"
}

mkdir -p "$DOWNLOADS" "$ROOT/configs" "$ROOT/machines" "$ROOT/roms"
fetch "$RPCEMU_URL" "$DOWNLOADS/$RPCEMU_FILE" "tar tzf"
fetch "$(drive_url "$DIRECT_ID")" "$DOWNLOADS/EasyStart-Direct.zip" "unzip -tqq"
fetch "$(drive_url "$RO371_ID")" "$DOWNLOADS/EasyStart-371.zip" "unzip -tqq"

# The emulator itself, unpacked afresh every run so a new version takes effect
mkdir -p "$HOME/Applications"
rm -rf "$APP"
UNPACK="$(mktemp -d "$DOWNLOADS/unpack.XXXXXX")"
tar xzf "$DOWNLOADS/$RPCEMU_FILE" -C "$UNPACK"
mv "$UNPACK/RPCEmu.app" "$APP"
rm -rf "$UNPACK"
# The app is not notarised, so macOS would refuse to open it
xattr -dr com.apple.quarantine "$APP"
echo "Installed ~/Applications/RPCEmu-Extended.app"

# The Shared drive is the project, so a build shows up straight away
if [ -L "$ROOT/shared" ]; then
    rm "$ROOT/shared"
elif [ -e "$ROOT/shared" ]; then
    echo "$ROOT/shared exists and isn't a link; move it and run this again" >&2
    exit 1
fi
ln -s "$PROJECT_APP" "$ROOT/shared"

make_machine() {  # name description bundle-zip
    local name="$1" machine="$ROOT/machines/$1"
    if [ -d "$machine" ]; then
        echo "Keeping existing machine $name"
        return
    fi
    echo "Creating machine $name..."
    # Build in a scratch folder and only move it into place once complete,
    # so a failed run never leaves a half-made machine behind
    local work="$ROOT/machines/.$name.partial"
    rm -rf "$work"
    trap 'rm -rf "$work"' EXIT
    mkdir -p "$work/bundle" "$work/machine"
    # ditto, not unzip: some bundle filenames use the RISC OS character set,
    # which macOS rejects unless the names are converted
    ditto -x -k "$3" "$work/bundle"
    # The bundle unpacks to a single "RPCEmu - ..." folder
    local top
    top="$(find "$work/bundle" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [ -z "$top" ] || [ ! -d "$top/roms" ] || [ ! -d "$top/hostfs" ]; then
        echo "$(basename "$3") doesn't look like an Easy Start bundle" >&2
        echo "(expected one folder holding roms/ and hostfs/)." >&2
        exit 1
    fi
    mv "$top/hostfs" "$top/cmos.ram" "$work/machine/"

    # RISC OS 5 asks for its address by DHCP. RISC OS 3.71 can't, and the
    # bundle gives it one on the old emulator's network: move it to this one.
    # It has no default route, but the host is on the same network as it.
    local inet="$work/machine/hostfs/!Boot/Choices/Internet"
    if grep -q '10\.10\.10\.10' "$inet/Startup,feb"; then
        sed -i '' -e 's/10\.10\.10\.10/100.64.0.10/g' \
                  -e 's/10\.10\.10\.3/100.64.0.2/g' \
                  -e 's/255\.255\.255\.0/255.192.0.0/g' "$inet/Startup,feb"
    fi

    # When the desktop starts, the emulator's RPCEmuMonitor module on RISC OS 3
    # replaces the monitor file !Boot chose with its own, which has no 640x256,
    # so MODE 12 becomes 640x480. Boot tasks run after that: load !Boot's again.
    if [ "$name" = ro371 ]; then
        echo "LoadModeFile BootResources:Configure.Monitors.EmuMon" \
            > "$work/machine/hostfs/!Boot/Choices/Boot/Tasks/EmuMon,feb"
    fi

    # Keep the machine the bundle describes, with two-button mouse mode (right
    # click = Menu, which suits a Mac) and networking on
    {
        echo "[General]"
        echo "description=$2"
        grep -E '^(model|mem_size|vram_size)=' "$top/rpc.cfg"
        echo "rom_dir=$name"
        echo "network_type=nat"
        echo "mouse_twobutton=1"
        echo "sound_enabled=1"
    } > "$ROOT/configs/$name.cfg"

    rm -rf "$ROOT/roms/$name"
    mv "$top/roms" "$ROOT/roms/$name"
    mv "$work/machine" "$machine"
    rm -rf "$work"
    trap - EXIT
}

make_machine direct "RISC OS 5" "$DOWNLOADS/EasyStart-Direct.zip"
make_machine ro371 "RISC OS 3.71" "$DOWNLOADS/EasyStart-371.zip"

echo
echo "Done. Start a machine with:  tools/rpcemu.sh direct   or   tools/rpcemu.sh 371"
