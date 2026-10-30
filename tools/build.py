#!/usr/bin/env python3
"""Build Cavern Duel: keep src/*.bas and the HostFS app folder in step.

    build.py build    tokenise src/**/*.bas into app/**/*,ffb (libraries in
                      src/shared/ are copied into each app listed in SHARED)
    build.py pull     detokenise app/**/*,ffb back into src/ (after editing
                      BASIC inside RISC OS)
    build.py check    confirm every source tokenises and round-trips cleanly,
                      then lint each program against its libraries
    build.py deploy   build, then copy app/ into the HostFS folder named in
                      deploy.local.json ({"hostfs": "/path/to/rpcemu/hostfs/CavernDuel"})
"""
import json
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bbcbasic  # noqa: E402
import lint  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
APP = os.path.join(ROOT, "app")

# Libraries kept once in src/shared/ and built into each of these apps
SHARED = {
    "shared/DrWimp": ["!CavenDuel/DrWimp", "!CavernEd/DrWimp"],
}


# Programs and the libraries they load with LIBRARY, for lint
PROGRAMS = {
    "!CavenDuel/!RunImage": ["shared/DrWimp"],
    "!CavenDuel/Game": [],
    "!CavernEd/!RunImage": ["shared/DrWimp"],
}


def targets(rel):
    return [os.path.join(APP, t + ",ffb") for t in SHARED.get(rel, [rel])]


def sources():
    for dirpath, _, files in os.walk(SRC):
        for name in sorted(files):
            if name.endswith(".bas"):
                path = os.path.join(dirpath, name)
                rel = os.path.relpath(path, SRC)[:-len(".bas")]
                yield path, targets(rel)


def read_text(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def read_bytes(path):
    with open(path, "rb") as f:
        return f.read()


def write_if_changed(path, data):
    if os.path.exists(path) and read_bytes(path) == data:
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)
    return True


def build():
    failed = False
    for src, outs in sources():
        try:
            data = bbcbasic.tokenise(read_text(src))
        except bbcbasic.BasicError as e:
            # file:line: message, so VS Code's problem matcher can find it
            print(f"{os.path.relpath(src, ROOT)}: error: {e}")
            failed = True
            continue
        for out in outs:
            if write_if_changed(out, data):
                print(f"built {os.path.relpath(out, ROOT)}")
    return 1 if failed else 0


def pull():
    shared_from = {t: rel for rel, ts in SHARED.items() for t in ts}
    pulled = {}  # source path -> (app copy, tokenised data)
    conflicts = set()
    for dirpath, _, files in os.walk(APP):
        for name in sorted(files):
            if not name.endswith(",ffb"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, APP)[:-len(",ffb")]
            out = os.path.join(SRC, shared_from.get(rel, rel) + ".bas")
            data = read_bytes(path)
            if out in pulled:
                # A shared library edited in one app but not the other
                if pulled[out][1] != data:
                    print(f"{os.path.relpath(out, ROOT)}: error: "
                          f"{os.path.relpath(pulled[out][0], ROOT)} and "
                          f"{os.path.relpath(path, ROOT)} differ; "
                          f"copy the one you edited over the other, then pull")
                    conflicts.add(out)
                continue
            pulled[out] = (path, data)
    for out, (path, data) in sorted(pulled.items()):
        if out in conflicts:
            continue
        text = bbcbasic.detokenise(data)
        if write_if_changed(out, text.encode("utf-8")):
            print(f"pulled {os.path.relpath(out, ROOT)}")
    return 1 if conflicts else 0


def check():
    failed = False
    for src, _ in sources():
        rel = os.path.relpath(src, ROOT)
        try:
            data = bbcbasic.tokenise(read_text(src))
            again = bbcbasic.tokenise(bbcbasic.detokenise(data))
        except bbcbasic.BasicError as e:
            print(f"{rel}: error: {e}")
            failed = True
            continue
        if again != data:
            print(f"{rel}: error: tokenised output does not round-trip")
            failed = True
        else:
            print(f"ok    {rel}")
    for program, libs in PROGRAMS.items():
        paths = [os.path.relpath(os.path.join(SRC, p + ".bas"), ROOT)
                 for p in [program] + libs]
        if lint.main(["lint.py"] + paths):
            failed = True
    return 1 if failed else 0


def deploy():
    if build():
        return 1
    config = os.path.join(ROOT, "deploy.local.json")
    if not os.path.exists(config):
        print("deploy.local.json not found; copy deploy.example.json and set "
              "\"hostfs\" to a folder inside RPCEmu's hostfs directory")
        return 1
    with open(config) as f:
        target = os.path.expanduser(json.load(f)["hostfs"])
    if os.path.realpath(target) == os.path.realpath(APP):
        print("hostfs points at app/ already (symlink); nothing to copy")
        return 0
    shutil.copytree(APP, target, dirs_exist_ok=True)
    print(f"deployed app/ to {target}")
    return 0


def main(argv):
    commands = {"build": build, "pull": pull, "check": check, "deploy": deploy}
    if len(argv) != 2 or argv[1] not in commands:
        print(__doc__, file=sys.stderr)
        return 2
    return commands[argv[1]]()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
