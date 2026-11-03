#!/usr/bin/env python3
"""Unpack a zip made on RISC OS into a HostFS folder, keeping file types.

    unzip_acorn.py archive.zip prefix/ destination

Unpacks the entries under prefix/, leaving BASIC tokenised. Use import_zip.py
to bring an archive of this project's own source in.
"""
import os
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_zip import riscos_suffix  # noqa: E402


def main(archive, prefix, dest):
    with zipfile.ZipFile(archive) as z:
        for info in z.infolist():
            if not info.filename.startswith(prefix):
                continue
            # Python reads these names as CP437; HostFS keeps RISC OS's own Latin-1
            name = info.filename[len(prefix):].encode("cp437").decode("latin-1")
            if info.is_dir():  # Some must exist though empty, such as !Boot's RO530Hook.Res
                os.makedirs(os.path.join(dest, name), exist_ok=True)
                continue
            path = os.path.join(dest, name + riscos_suffix(info))
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "wb") as f:
                f.write(z.read(info))
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    sys.exit(main(*sys.argv[1:]))
