#!/bin/bash
# Start RPCEmu Extended with one of the machines made by setup_rpcemu.sh.
#
#   tools/rpcemu.sh direct|371 [data-dir]      (default: ~/RPCEmu-Extended)
#
# Each machine gets its own window and process, so both can run at once.
set -euo pipefail

ROOT="${2:-$HOME/RPCEmu-Extended}"
APP="$HOME/Applications/RPCEmu-Extended.app"
case "${1:-}" in
    direct) MACHINE="direct" ;;
    371)    MACHINE="ro371" ;;
    *)      echo "usage: $0 direct|371 [data-dir]" >&2; exit 2 ;;
esac

if [ ! -f "$ROOT/configs/$MACHINE.cfg" ] || [ ! -d "$APP" ]; then
    echo "$MACHINE not found in $ROOT; run tools/setup_rpcemu.sh first" >&2
    exit 1
fi

open -n "$APP" --args --datadir "$ROOT" --machine "$MACHINE"
