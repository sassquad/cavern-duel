#!/usr/bin/env python3
"""Unpack a RISC OS zip (SparkFS/!Zip) into a HostFS-ready folder.

RISC OS file types are kept in the "ARC0" extra field of each zip entry. They
become the ",xxx" filename suffix that RPCEmu's HostFS uses, or
",llllllll-eeeeeeee" for files with load/exec addresses. Tokenised BASIC
(,ffb) is also detokenised into the source tree.

Usage:
    import_zip.py <archive.zip> <strip-prefix> <app-dir> <src-dir>

Example:
    import_zip.py reference/Cavern_v1271.zip CavernDuel1271/CavernDuel/ app src
"""
import os
import struct
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bbcbasic  # noqa: E402


def riscos_suffix(info):
    extra = info.extra
    while len(extra) >= 4:
        tag, size = struct.unpack("<HH", extra[:4])
        field = extra[4:4 + size]
        if tag == 0x4341 and field[:4] == b"ARC0":
            load, exec_ = struct.unpack("<II", field[4:12])
            if load >> 20 == 0xFFF:
                return f",{(load >> 8) & 0xFFF:03x}"
            return f",{load:08x}-{exec_:08x}"
        extra = extra[4 + size:]
    return ""


def main(argv):
    if len(argv) != 5:
        print(__doc__, file=sys.stderr)
        return 2
    archive, prefix, app_dir, src_dir = argv[1:]
    with zipfile.ZipFile(archive) as z:
        for info in z.infolist():
            if info.is_dir() or not info.filename.startswith(prefix):
                continue
            rel = info.filename[len(prefix):]
            suffix = riscos_suffix(info)
            data = z.read(info)
            if suffix == ",ffb":
                out = os.path.join(src_dir, rel + ".bas")
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with open(out, "w", encoding="utf-8", newline="\n") as f:
                    f.write(bbcbasic.detokenise(data))
                print(f"src  {out}")
            out = os.path.join(app_dir, rel + suffix)
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with open(out, "wb") as f:
                f.write(data)
            print(f"app  {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
