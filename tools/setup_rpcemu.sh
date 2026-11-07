#!/bin/bash
# Install RPCEmu Extended for macOS plus RISC OS 5.27 (Direct) and RISC OS 3.71
# machines made from the Easy Start bundles and a RISC OS 5.30 machine made from
# RISC OS Open's downloads, with this project's app/ folder as the Shared drive
# that every machine sees.
#
#   tools/setup_rpcemu.sh [data-dir]      (default: ~/RPCEmu-Extended)
#
# Safe to re-run: downloads are cached in <data-dir>/Downloads and existing
# machines are left alone (delete a machine's folders to rebuild it).
set -euo pipefail

ROOT="${1:-$HOME/RPCEmu-Extended}"
TOOLS="$(cd "$(dirname "$0")" && pwd)"
PROJECT_APP="$(dirname "$TOOLS")/app"
DOWNLOADS="$ROOT/Downloads"
APP="$HOME/Applications/RPCEmu-Extended.app"

RPCEMU_VERSION="2.0.0"
RPCEMU_FILE="rpcemu_${RPCEMU_VERSION}_macos_universal.tar.gz"
RPCEMU_URL="https://github.com/andrewtimmins/rpcemu-extended/releases/download/v$RPCEMU_VERSION/$RPCEMU_FILE"
# Easy Start "Other platforms" editions, from http://www.marutan.net/rpcemu/easystart.html
DIRECT_ID="1uIAUIB8wuixm2-49bXQSvnLjdeN8ePaz"
RO371_ID="1HWd67HYNRsIh9wgQZZT06GsANlYd4V4i"
# RISC OS 5.30 stable, from https://www.riscosopen.org/content/downloads
ROOL_ZIPS="https://www.riscosopen.org/zipfiles/platform"

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
fetch "$ROOL_ZIPS/riscpc/IOMD-Flash.5.30.zip" "$DOWNLOADS/IOMD-Flash.5.30.zip" "unzip -tqq"
fetch "$ROOL_ZIPS/common/HardDisc4.5.30.zip" "$DOWNLOADS/HardDisc4.5.30.zip" "unzip -tqq"

# The emulator itself, unpacked afresh every run so a new version takes effect,
# unless a machine is open and using the installed copy
mkdir -p "$HOME/Applications"
if [ -d "$APP" ] && pgrep -qf "$APP/Contents/MacOS/rpcemu"; then
    echo "Keeping the installed RPCEmu Extended, because a machine is running"
else
    rm -rf "$APP"
    UNPACK="$(mktemp -d "$DOWNLOADS/unpack.XXXXXX")"
    tar xzf "$DOWNLOADS/$RPCEMU_FILE" -C "$UNPACK"
    mv "$UNPACK/RPCEmu.app" "$APP"
    rm -rf "$UNPACK"
    # The app is not notarised, so macOS would refuse to open it
    xattr -dr com.apple.quarantine "$APP"
    echo "Installed ~/Applications/RPCEmu-Extended.app"
fi

# The Shared drive is the project, so a build shows up straight away
if [ -L "$ROOT/shared" ]; then
    rm "$ROOT/shared"
elif [ -e "$ROOT/shared" ]; then
    echo "$ROOT/shared exists and isn't a link; move it and run this again" >&2
    exit 1
fi
ln -s "$PROJECT_APP" "$ROOT/shared"

write_config() {  # name description file-with-model-and-memory
    # Keep the machine that file describes, with two-button mouse mode (right
    # click = Menu, which suits a Mac) and networking on
    {
        echo "[General]"
        echo "description=$2"
        grep -E '^(model|mem_size|vram_size)=' "$3"
        echo "rom_dir=$1"
        echo "network_type=nat"
        echo "mouse_twobutton=1"
        echo "sound_enabled=1"
    } > "$ROOT/configs/$1.cfg"
}

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
    # bundle gives it one on the old emulator's network: move it to this one,
    # with the emulator as its route to the internet.
    local inet="$work/machine/hostfs/!Boot/Choices/Internet"
    if grep -q '10\.10\.10\.10' "$inet/Startup,feb"; then
        sed -i '' -e 's/10\.10\.10\.10/100.64.0.10/g' \
                  -e 's/10\.10\.10\.3/100.64.0.2/g' \
                  -e 's/10\.10\.10\.2/100.64.0.1/g' \
                  -e 's/255\.255\.255\.0/255.192.0.0/g' "$inet/Startup,feb"
    fi

    # When the desktop starts, the emulator's RPCEmuMonitor module on RISC OS 3
    # replaces the monitor file !Boot chose with its own, which has no 640x256,
    # so MODE 12 becomes 640x480. Boot tasks run after that: load !Boot's again.
    if [ "$name" = ro371 ]; then
        echo "LoadModeFile BootResources:Configure.Monitors.EmuMon" \
            > "$work/machine/hostfs/!Boot/Choices/Boot/Tasks/EmuMon,feb"
    fi

    write_config "$name" "$2" "$top/rpc.cfg"

    rm -rf "$ROOT/roms/$name"
    mv "$top/roms" "$ROOT/roms/$name"
    mv "$work/machine" "$machine"
    rm -rf "$work"
    trap - EXIT
}

make_ro530() {  # The ROM and disc come from RISC OS Open; the rest matches direct
    local machine="$ROOT/machines/ro530"
    if [ -d "$machine" ]; then
        echo "Keeping existing machine ro530"
        return
    fi
    echo "Creating machine ro530..."
    local work="$ROOT/machines/.ro530.partial"
    rm -rf "$work"
    trap 'rm -rf "$work"' EXIT
    mkdir -p "$work/hostfs"
    python3 "$TOOLS/unzip_acorn.py" "$DOWNLOADS/HardDisc4.5.30.zip" HardDisc4/ "$work/hostfs"
    cp "$ROOT/machines/direct/cmos.ram" "$work/"
    # HardDisc4 starts with no network, so add the emulator's own settings. The
    # first boot copies the hook for its ROM into Choices.Boot, so the file that
    # starts the network goes in the hooks: making Choices.Boot would stop that.
    local net="$APP/Contents/Resources/resources/ro5/network"
    cp -R "$net/!Boot/" "$work/hostfs/!Boot/"
    cp "$net/PreDesk/RPCEmuNet,feb" "$work/hostfs/!Boot/RO530Hook/Boot/PreDesk/"
    sed -i '' 's/^Set Inet\$HostName .*/Set Inet$HostName ro530/' "$work/hostfs/!Boot/Choices/Internet/Startup,feb"
    write_config ro530 "RISC OS 5.30" "$ROOT/configs/direct.cfg"
    mkdir -p "$ROOT/roms/ro530"
    unzip -p "$DOWNLOADS/IOMD-Flash.5.30.zip" '!KinPrg/riscos' > "$ROOT/roms/ro530/ROM530"
    mv "$work" "$machine"
    trap - EXIT
}

make_machine direct "RISC OS 5" "$DOWNLOADS/EasyStart-Direct.zip"
make_machine ro371 "RISC OS 3.71" "$DOWNLOADS/EasyStart-371.zip"
make_ro530

echo
echo "Done. Start a machine with:  tools/rpcemu.sh direct,  tools/rpcemu.sh 530  or  tools/rpcemu.sh 371"
