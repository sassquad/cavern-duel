#!/bin/bash
# Start RPCEmu with one of the machines made by setup_rpcemu.sh.
#
#   tools/rpcemu.sh direct|371 [install-dir]      (default: ~/RPCEmu)
#
# The macOS build remembers a single data folder, so this points it at the
# chosen machine before launching. Quit RPCEmu before switching machines.
set -euo pipefail

ROOT="${2:-$HOME/RPCEmu}"
case "${1:-}" in
    direct) MACHINE="$ROOT/Direct" ;;
    371)    MACHINE="$ROOT/RO371" ;;
    *)      echo "usage: $0 direct|371 [install-dir]" >&2; exit 2 ;;
esac

if [ ! -f "$MACHINE/rpc.cfg" ]; then
    echo "$MACHINE not found; run tools/setup_rpcemu.sh first" >&2
    exit 1
fi
if pgrep -xq RPCEmu-Interpreter; then
    echo "RPCEmu is already running; quit it first (File > Exit)" >&2
    exit 1
fi

defaults write org.marutan.rpcemu DataDirectory "$MACHINE"
open "$HOME/Applications/RPCEmu-Interpreter.app"
