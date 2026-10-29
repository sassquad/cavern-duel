#!/bin/bash
# Install RPCEmu for macOS plus the RISC OS 5 (Direct) and RISC OS 3.71
# Easy Start bundles, with this project's app/ folder mapped as a HostFS drive.
#
#   tools/setup_rpcemu.sh [install-dir]      (default: ~/RPCEmu)
#
# Safe to re-run: downloads are cached in <install-dir>/Downloads and existing
# machines are left alone (delete a machine's folder to rebuild it).
set -euo pipefail

ROOT="${1:-$HOME/RPCEmu}"
PROJECT_APP="$(cd "$(dirname "$0")/.." && pwd)/app"
DOWNLOADS="$ROOT/Downloads"

RPCEMU_VERSION="0.9.5b"
RPCEMU_URL="https://github.com/Septercius/rpcemu-dev/releases/download/$RPCEMU_VERSION/RPCEmu-$RPCEMU_VERSION-Release.zip"
# Easy Start "Other platforms" editions, from http://www.marutan.net/rpcemu/easystart.html
DIRECT_ID="1uIAUIB8wuixm2-49bXQSvnLjdeN8ePaz"
RO371_ID="1HWd67HYNRsIh9wgQZZT06GsANlYd4V4i"

fetch() {  # url file
    if [ -s "$2" ]; then
        echo "Already downloaded: $(basename "$2")"
    else
        echo "Downloading $(basename "$2")..."
        curl -fL --progress-bar -o "$2.part" "$1"
        mv "$2.part" "$2"
    fi
    # Google Drive answers with an HTML page when it refuses a download
    if ! unzip -tqq "$2" >/dev/null 2>&1; then
        rm -f "$2"
        echo "$(basename "$2") is not a valid zip. Download it in a browser" >&2
        echo "and save it as $2, then run this script again." >&2
        exit 1
    fi
}

drive_url() {
    echo "https://drive.usercontent.google.com/download?id=$1&export=download&confirm=t"
}

mkdir -p "$DOWNLOADS"
fetch "$RPCEMU_URL" "$DOWNLOADS/RPCEmu-$RPCEMU_VERSION.zip"
fetch "$(drive_url "$DIRECT_ID")" "$DOWNLOADS/EasyStart-Direct.zip"
fetch "$(drive_url "$RO371_ID")" "$DOWNLOADS/EasyStart-371.zip"

# The emulator itself, plus a template "Data" folder
STAGE="$DOWNLOADS/rpcemu-$RPCEMU_VERSION"
if [ ! -d "$STAGE" ]; then
    unzip -q "$DOWNLOADS/RPCEmu-$RPCEMU_VERSION.zip" -d "$STAGE"
fi
mkdir -p "$HOME/Applications"
rm -rf "$HOME/Applications/RPCEmu-Interpreter.app"
cp -R "$STAGE/RPCEmu-Interpreter.app" "$HOME/Applications/"
# The app is not notarised, so macOS would refuse to open it
xattr -dr com.apple.quarantine "$HOME/Applications/RPCEmu-Interpreter.app"
echo "Installed ~/Applications/RPCEmu-Interpreter.app"

make_machine() {  # name bundle-zip
    local dest="$ROOT/$1" bundle="$2"
    if [ -d "$dest" ]; then
        echo "Keeping existing $dest"
        return
    fi
    echo "Creating $dest..."
    # Build in a scratch folder and only move it into place once complete,
    # so a failed run never leaves a half-made machine behind
    local work="$dest.partial"
    rm -rf "$work"
    trap 'rm -rf "$work"' EXIT
    mkdir -p "$work/bundle"
    # ditto, not unzip: some bundle filenames use the RISC OS character set,
    # which macOS rejects unless the names are converted
    ditto -x -k "$bundle" "$work/bundle"
    # The bundle unpacks to a single "RPCEmu - ..." folder
    local top
    top="$(find "$work/bundle" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [ -z "$top" ] || [ ! -d "$top/roms" ] || [ ! -d "$top/hostfs" ]; then
        echo "$(basename "$bundle") doesn't look like an Easy Start bundle" >&2
        echo "(expected one folder holding roms/ and hostfs/)." >&2
        exit 1
    fi

    cp -R "$STAGE/Data" "$work/machine"
    cp -R "$top/." "$work/machine/"
    rm -rf "$work/bundle"
    # Multi-drive HostFS needs its own podule ROMs, not the single-drive ones
    rm -f "$work/machine/poduleroms/hostfs,ffa" \
          "$work/machine/poduleroms/hostfsfiler,ffa"
    cp "$STAGE/Data/poduleroms/multihostfs,ffa" \
       "$STAGE/Data/poduleroms/multihostfsfiler,ffa" "$work/machine/poduleroms/"
    # Multi-drive HostFS boots from the drive in CMOS logical &50
    # (*Configure HostFSDrive), which the bundles leave at 0, so RISC OS
    # stops at the * prompt. Point it at drive 4, the machine's hard disc.
    # cmos.ram is stored by physical address (logical + &40); RPCEmu fixes
    # the checksum when it loads the file.
    printf '\x04' | dd of="$work/machine/cmos.ram" bs=1 seek=$((0x90)) \
        conv=notrunc 2>/dev/null

    # Keep the bundle's settings, but use two-button mouse mode (right click
    # = Menu, which suits a Mac) and add the project as HostFS drive 2.
    local cfg="$work/machine/rpc.cfg"
    awk '/^\[/ { skip = ($0 == "[HostFS]") } !skip' "$cfg" \
        | sed 's/^mouse_twobutton=.*/mouse_twobutton=1/' > "$cfg.new"
    cat >> "$cfg.new" <<EOF

[HostFS]
1\\boot_option=2
1\\enabled=1
1\\name=HostFS
1\\path=./hostfs
2\\boot_option=0
2\\enabled=1
2\\name=CavernDuel
2\\path=$PROJECT_APP
3\\enabled=0
4\\enabled=0
size=4
EOF
    mv "$cfg.new" "$cfg"

    mv "$work/machine" "$dest"
    rm -rf "$work"
    trap - EXIT
}

make_machine "Direct" "$DOWNLOADS/EasyStart-Direct.zip"
make_machine "RO371" "$DOWNLOADS/EasyStart-371.zip"

echo
echo "Done. Start a machine with:"
echo "  tools/rpcemu.sh direct    (RISC OS 5)"
echo "  tools/rpcemu.sh 371       (RISC OS 3.71)"
echo "You can delete $DOWNLOADS to free about 1.4 GB."
