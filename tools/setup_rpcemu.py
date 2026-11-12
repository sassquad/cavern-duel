#!/usr/bin/env python3
"""Install RPCEmu Extended and three RISC OS machines, on macOS or Windows.

    setup_rpcemu.py [data-dir] [--arch amd64|arm64]

Makes RISC OS 5.27 (Direct) and RISC OS 3.71 machines from the Easy Start
bundles, and a RISC OS 5.30 machine from RISC OS Open's downloads. Every machine
sees this project's app/ folder as its Shared disc. The data directory defaults
to RPCEmu-Extended in your home folder.

Safe to run again: downloads are kept in <data-dir>/Downloads, and machines
that already exist are left alone (delete a machine's folders to rebuild it).
The emulator itself is unpacked afresh each time, so a new version takes
effect, unless a machine is running.

On Windows, --arch picks the emulator build: arm64 or amd64. It defaults to the
machine's own; amd64 also runs on ARM PCs, more slowly.
"""
import argparse
import os
import platform
import re
import shutil
import subprocess
import sys
import tarfile
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import unzip_acorn  # noqa: E402

TOOLS = os.path.dirname(os.path.abspath(__file__))
PROJECT_APP = os.path.join(os.path.dirname(TOOLS), "app")
WINDOWS = sys.platform == "win32"
MAC = sys.platform == "darwin"

RPCEMU_VERSION = "2.0.0"
RPCEMU_RELEASES = "https://github.com/andrewtimmins/rpcemu-extended/releases/download/v" + RPCEMU_VERSION
# Easy Start "Other platforms" editions, from http://www.marutan.net/rpcemu/easystart.html
DIRECT_ID = "1uIAUIB8wuixm2-49bXQSvnLjdeN8ePaz"
RO371_ID = "1HWd67HYNRsIh9wgQZZT06GsANlYd4V4i"
# RISC OS 5.30 stable, from https://www.riscosopen.org/content/downloads
ROOL_ZIPS = "https://www.riscosopen.org/zipfiles/platform"


def default_root():
    return os.path.join(os.path.expanduser("~"), "RPCEmu-Extended")


def windows_arch():
    return "arm64" if platform.machine().upper() in ("ARM64", "AARCH64") else "amd64"


class Emulator:
    """Where RPCEmu Extended is installed on this system, and how to start it."""

    def __init__(self, arch=None):
        if MAC:
            self.home = os.path.expanduser("~/Applications/RPCEmu-Extended.app")
            self.bin = os.path.join(self.home, "Contents", "MacOS")
            self.resources = os.path.join(self.home, "Contents", "Resources", "resources")
            self.download = f"rpcemu_{RPCEMU_VERSION}_macos_universal.tar.gz"
        elif WINDOWS:
            self.home = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "RPCEmu-Extended")
            self.bin = self.home
            self.resources = os.path.join(self.home, "resources")
            self.download = f"rpcemu_{RPCEMU_VERSION}_windows_{arch or windows_arch()}.zip"
        else:
            sys.exit("This script sets up macOS or Windows; see docs/rpcemu-setup.md")

    def program(self, name):
        """The path of one of the emulator's programs, such as rpcemu-run."""
        return os.path.join(self.bin, name + (".exe" if WINDOWS else ""))

    def installed(self):
        return os.path.exists(self.program("rpcemu-run"))

    def start(self, root, machine):
        """Start a machine in its own window and process, and return at once."""
        if MAC:
            subprocess.run(["open", "-n", self.home, "--args", "--datadir", root,
                            "--machine", machine], check=True)
        else:
            flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
            subprocess.Popen([self.program("rpcemu-recompiler"), "--datadir", root,
                              "--machine", machine], cwd=self.home, creationflags=flags,
                             stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, close_fds=True)

    def running(self):
        if MAC:
            return subprocess.run(["pgrep", "-qf", os.path.join(self.bin, "rpcemu")]).returncode == 0
        out = subprocess.run(["tasklist", "/fo", "csv", "/nh"], capture_output=True, text=True).stdout
        return any(line.lower().startswith('"rpcemu-') for line in out.splitlines())


def fetch(url, path, valid):
    """Download url to path unless it's there already; stop if it isn't valid."""
    name = os.path.basename(path)
    if os.path.exists(path) and os.path.getsize(path):
        print(f"Already downloaded: {name}")
    else:
        print(f"Downloading {name}...", flush=True)
        # curl comes with macOS and Windows 10 and later, and uses the system's certificates
        subprocess.run(["curl", "-fL", "--progress-bar", "-o", path + ".part", url], check=True)
        os.replace(path + ".part", path)
    # Google Drive answers with an HTML page when it refuses a download
    if not valid(path):
        os.remove(path)
        sys.exit(f"{name} is not a valid archive. Download it in a browser and save "
                 f"it as {path}, then run this script again.")


def drive_url(file_id):
    return f"https://drive.usercontent.google.com/download?id={file_id}&export=download&confirm=t"


def remove(path):
    """Delete a file or folder, if it's there. A link goes, not what it points to."""
    if is_link(path):
        if WINDOWS and os.path.isdir(path):
            os.rmdir(path)  # A junction
        else:
            os.remove(path)
    elif os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.lexists(path):
        os.remove(path)


def is_link(path):
    """A symbolic link, or on Windows a directory junction."""
    if os.path.islink(path):
        return True
    isjunction = getattr(os.path, "isjunction", None)  # Python 3.12 and later
    if isjunction:
        return isjunction(path)
    try:
        os.readlink(path)  # Also reads junctions on Windows
        return True
    except (OSError, ValueError, AttributeError):
        return False


def install_emulator(emu, downloads):
    if emu.installed() and emu.running():
        print("Keeping the installed RPCEmu Extended, because a machine is running")
        return
    unpack = emu.home + ".partial"
    remove(unpack)
    archive = os.path.join(downloads, emu.download)
    if MAC:
        os.makedirs(unpack)
        subprocess.run(["tar", "xzf", archive, "-C", unpack], check=True)
        remove(emu.home)
        os.makedirs(os.path.dirname(emu.home), exist_ok=True)
        os.replace(os.path.join(unpack, "RPCEmu.app"), emu.home)
        remove(unpack)
        # The app is not notarised, so macOS would refuse to open it if it were quarantined
        subprocess.run(["xattr", "-dr", "com.apple.quarantine", emu.home])
        print("Installed ~/Applications/RPCEmu-Extended.app")
    else:
        with zipfile.ZipFile(archive) as z:
            z.extractall(unpack)
        remove(emu.home)
        os.makedirs(os.path.dirname(emu.home), exist_ok=True)
        os.replace(unpack, emu.home)
        print(f"Installed {emu.home}")


def link_shared(root):
    """The Shared disc is the project's app/ folder, so a build shows up straight away."""
    shared = os.path.join(root, "shared")
    if is_link(shared):
        remove(shared)
    elif os.path.exists(shared):
        sys.exit(f"{shared} exists and isn't a link; move it and run this again")
    if WINDOWS:
        # A junction, which unlike a symbolic link needs no administrator rights
        subprocess.run(["cmd", "/c", "mklink", "/J", shared, PROJECT_APP], check=True,
                       stdout=subprocess.DEVNULL)
    else:
        os.symlink(PROJECT_APP, shared)


def write_config(root, name, description, source, three_button):
    """Keep the machine that source describes, with networking on and, unless
    three_button, two-button mouse mode (right click is Menu)."""
    with open(source, encoding="latin-1") as f:
        keep = [line.rstrip("\r\n") for line in f if re.match(r"(model|mem_size|vram_size)=", line)]
    lines = ["[General]", f"description={description}", *keep, f"rom_dir={name}",
             "network_type=nat", f"mouse_twobutton={0 if three_button else 1}", "sound_enabled=1"]
    with open(os.path.join(root, "configs", name + ".cfg"), "w", encoding="latin-1", newline="\n") as f:
        f.write("\n".join(lines) + "\n")


def edit_text(path, changes):
    """Replace text in a RISC OS text file, keeping its LF endings."""
    with open(path, encoding="latin-1", newline="") as f:
        text = f.read()
    for old, new in changes:
        text = text.replace(old, new)
    with open(path, "w", encoding="latin-1", newline="") as f:
        f.write(text)


def make_machine(root, name, description, bundle, three_button):
    machine = os.path.join(root, "machines", name)
    if os.path.isdir(machine):
        print(f"Keeping existing machine {name}")
        return
    print(f"Creating machine {name}...", flush=True)
    # Build in a scratch folder and move it into place only once it's complete,
    # so a failed run never leaves a half-made machine behind
    work = os.path.join(root, "machines", "." + name + ".partial")
    remove(work)
    try:
        with zipfile.ZipFile(bundle) as z:
            # The bundle unpacks to a single "RPCEmu - ..." folder. Its names were
            # written on Windows, in the old DOS character set, which zipfile reads
            z.extractall(os.path.join(work, "bundle"))
        tops = [os.path.join(work, "bundle", d) for d in os.listdir(os.path.join(work, "bundle"))]
        top = next((t for t in tops if os.path.isdir(os.path.join(t, "hostfs"))), None)
        if not top or not os.path.isdir(os.path.join(top, "roms")):
            sys.exit(f"{os.path.basename(bundle)} doesn't look like an Easy Start bundle "
                     "(expected one folder holding roms and hostfs).")
        os.makedirs(os.path.join(work, "machine"))
        for item in ("hostfs", "cmos.ram"):
            os.replace(os.path.join(top, item), os.path.join(work, "machine", item))

        # RISC OS 5 asks for its address by DHCP. RISC OS 3.71 can't, and the
        # bundle gives it one on the old emulator's network: move it to this one,
        # with the emulator as its route to the internet.
        startup = os.path.join(work, "machine", "hostfs", "!Boot", "Choices", "Internet", "Startup,feb")
        with open(startup, encoding="latin-1") as f:
            old_network = "10.10.10.10" in f.read()
        if old_network:
            edit_text(startup, [("10.10.10.10", "100.64.0.10"), ("10.10.10.3", "100.64.0.2"),
                                ("10.10.10.2", "100.64.0.1"), ("255.255.255.0", "255.192.0.0")])

        # When the desktop starts, the emulator's RPCEmuMonitor module on RISC OS 3
        # replaces the monitor file !Boot chose with its own, which has no 640x256,
        # so MODE 12 becomes 640x480. Boot tasks run after that: load !Boot's again.
        if name == "ro371":
            task = os.path.join(work, "machine", "hostfs", "!Boot", "Choices", "Boot", "Tasks", "EmuMon,feb")
            with open(task, "w", encoding="latin-1", newline="\n") as f:
                f.write("LoadModeFile BootResources:Configure.Monitors.EmuMon\n")

        write_config(root, name, description, os.path.join(top, "rpc.cfg"), three_button)
        roms = os.path.join(root, "roms", name)
        remove(roms)
        os.replace(os.path.join(top, "roms"), roms)
        os.replace(os.path.join(work, "machine"), machine)
    finally:
        remove(work)


def make_ro530(root, emu, downloads, three_button):
    """The ROM and disc come from RISC OS Open; the rest matches direct."""
    machine = os.path.join(root, "machines", "ro530")
    if os.path.isdir(machine):
        print("Keeping existing machine ro530")
        return
    print("Creating machine ro530...", flush=True)
    work = os.path.join(root, "machines", ".ro530.partial")
    remove(work)
    try:
        hostfs = os.path.join(work, "hostfs")
        os.makedirs(hostfs)
        unzip_acorn.main(os.path.join(downloads, "HardDisc4.5.30.zip"), "HardDisc4/", hostfs)
        shutil.copy(os.path.join(root, "machines", "direct", "cmos.ram"), work)
        # HardDisc4 starts with no network, so add the emulator's own settings. The
        # first boot copies the hook for its ROM into Choices.Boot, so the file that
        # starts the network goes in the hooks: making Choices.Boot would stop that.
        net = os.path.join(emu.resources, "ro5", "network")
        shutil.copytree(os.path.join(net, "!Boot"), os.path.join(hostfs, "!Boot"), dirs_exist_ok=True)
        shutil.copy(os.path.join(net, "PreDesk", "RPCEmuNet,feb"),
                    os.path.join(hostfs, "!Boot", "RO530Hook", "Boot", "PreDesk"))
        startup = os.path.join(hostfs, "!Boot", "Choices", "Internet", "Startup,feb")
        with open(startup, encoding="latin-1", newline="") as f:
            lines = f.read().split("\n")
        lines = ["Set Inet$HostName ro530" if line.startswith("Set Inet$HostName ") else line for line in lines]
        with open(startup, "w", encoding="latin-1", newline="") as f:
            f.write("\n".join(lines))
        write_config(root, "ro530", "RISC OS 5.30", os.path.join(root, "configs", "direct.cfg"), three_button)
        roms = os.path.join(root, "roms", "ro530")
        os.makedirs(roms, exist_ok=True)
        with zipfile.ZipFile(os.path.join(downloads, "IOMD-Flash.5.30.zip")) as z:
            with open(os.path.join(roms, "ROM530"), "wb") as f:
                f.write(z.read("!KinPrg/riscos"))
        os.replace(work, machine)
    finally:
        remove(work)


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("root", nargs="?", default=default_root(), help="the data directory")
    parser.add_argument("--arch", choices=["amd64", "arm64"], help="Windows only: the emulator build")
    parser.add_argument("--three-button", action="store_true",
                        help="use a three-button mouse's middle button for Menu, instead of right click")
    args = parser.parse_args(argv[1:])
    root = os.path.abspath(os.path.expanduser(args.root))
    emu = Emulator(args.arch)
    downloads = os.path.join(root, "Downloads")
    for d in (downloads, os.path.join(root, "configs"), os.path.join(root, "machines"), os.path.join(root, "roms")):
        os.makedirs(d, exist_ok=True)

    fetch(f"{RPCEMU_RELEASES}/{emu.download}", os.path.join(downloads, emu.download),
          tarfile.is_tarfile if emu.download.endswith(".tar.gz") else zipfile.is_zipfile)
    fetch(drive_url(DIRECT_ID), os.path.join(downloads, "EasyStart-Direct.zip"), zipfile.is_zipfile)
    fetch(drive_url(RO371_ID), os.path.join(downloads, "EasyStart-371.zip"), zipfile.is_zipfile)
    fetch(f"{ROOL_ZIPS}/riscpc/IOMD-Flash.5.30.zip", os.path.join(downloads, "IOMD-Flash.5.30.zip"), zipfile.is_zipfile)
    fetch(f"{ROOL_ZIPS}/common/HardDisc4.5.30.zip", os.path.join(downloads, "HardDisc4.5.30.zip"), zipfile.is_zipfile)

    install_emulator(emu, downloads)
    link_shared(root)
    make_machine(root, "direct", "RISC OS 5", os.path.join(downloads, "EasyStart-Direct.zip"), args.three_button)
    make_machine(root, "ro371", "RISC OS 3.71", os.path.join(downloads, "EasyStart-371.zip"), args.three_button)
    make_ro530(root, emu, downloads, args.three_button)

    print("\nDone. Start a machine with the Run on RISC OS tasks in VS Code, or:")
    print("  python3 tools/rpcemu.py direct|530|371" if not WINDOWS else "  py -3 tools\\rpcemu.py direct|530|371")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
