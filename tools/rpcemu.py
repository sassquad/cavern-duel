#!/usr/bin/env python3
"""Start RPCEmu Extended with one of the machines made by setup_rpcemu.py.

    rpcemu.py direct|530|371 [data-dir]

Each machine gets its own window and process, so several can run at once.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import setup_rpcemu  # noqa: E402

MACHINES = {"direct": "direct", "530": "ro530", "371": "ro371"}


def main(argv):
    if len(argv) not in (2, 3) or argv[1] not in MACHINES:
        print(__doc__, file=sys.stderr)
        return 2
    machine = MACHINES[argv[1]]
    root = os.path.abspath(os.path.expanduser(argv[2])) if len(argv) == 3 else setup_rpcemu.default_root()
    emu = setup_rpcemu.Emulator()
    if not os.path.exists(os.path.join(root, "configs", machine + ".cfg")) or not emu.installed():
        print(f"{machine} not found in {root}; run tools/setup_rpcemu.py first", file=sys.stderr)
        return 1
    emu.start(root, machine)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
