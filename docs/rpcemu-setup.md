# Setting up RPCEmu Extended on a Mac or Windows PC

This guide sets up three emulated Risc PCs, using
[RPCEmu Extended](https://github.com/andrewtimmins/rpcemu-extended), on macOS or
Windows 11:

| Machine  | RISC OS              | Use it for                                  |
|----------|----------------------|---------------------------------------------|
| `direct` | RISC OS 5.27 (Direct) | Main target: modern 32-bit RISC OS, with many apps |
| `ro530`  | RISC OS 5.30         | The current stable release, on RISC OS Open's own disc |
| `ro371`  | RISC OS 3.71         | Checking the game still runs on old systems |

Every machine sees this project's `app/` folder as its **Shared** disc. Run the
**Build** task in VS Code (⇧⌘B on a Mac, Ctrl+Shift+B on Windows), and the new
build is there straight away. Nothing needs copying.

## What you need

- **Python 3.8 or later.**
  - Mac: the Xcode command line tools' `python3` is fine.
  - Windows: install it from [python.org](https://www.python.org/downloads/windows/),
    or run `winget install Python.Python.3.13`. This gives the `py` command the
    VS Code tasks use on Windows.
- **Git**, and **VS Code**.
- About 4 GB of disc space.

## What each piece is

- **The emulator.** RPCEmu Extended has builds for Apple silicon and Intel Macs,
  and for Windows on Intel/AMD (amd64) and ARM (arm64). The setup script picks
  the right one.
  - Mac: it goes in `~/Applications/RPCEmu-Extended.app`. It isn't notarised,
    so the script removes the macOS "downloaded from the internet" flag.
  - Windows: it goes in `%LOCALAPPDATA%\Programs\RPCEmu-Extended`.
- **The data folder**, `RPCEmu-Extended` in your home folder:

  ```
  configs/<name>.cfg                        each machine's settings
  machines/<name>/hostfs/                   its hard disc, as ordinary files
  machines/<name>/cmos.ram                  its saved RISC OS settings
  machines/<name>/rpclog.txt                its log
  roms/<name>/                              its RISC OS ROM image
  shared/                                   a link to this project's app/
  ```

  On Windows, `shared` is a directory junction, which needs no administrator
  rights.
- **The Easy Start bundles** supply each machine's ROM, ready-made hard disc
  and CMOS settings. They are hosted on Google Drive, linked from
  <http://www.marutan.net/rpcemu/easystart.html>. The **"Other platforms"**
  editions are the ones used.
- **RISC OS Open's downloads** supply `ro530`: the
  [IOMD 5.30 stable ROM](https://www.riscosopen.org/content/downloads/riscpc)
  and the [HardDisc4 5.30 disc](https://www.riscosopen.org/content/downloads/common).
  `tools/unzip_acorn.py` unpacks the disc, keeping its file types, and the network
  settings come from RPCEmu Extended itself.

  RISC OS is copyright RISC OS Developments Ltd and is maintained by RISC OS Open
  Ltd. None of it is in this repository: the setup script downloads it from RISC
  OS Open onto your computer. Much of it is under the Apache 2.0 licence, and
  [their licences page](https://www.riscosopen.org/content/documents/licences) has
  the terms. Read those before passing on a ROM or disc.
- **HostFS** is how RISC OS sees the computer's folders. A RISC OS file type
  travels in the filename as a suffix (`Game,ffb`), which is why `app/` is laid
  out that way.

## Install

On a Mac:

```bash
python3 tools/setup_rpcemu.py
```

On Windows, in a Command Prompt or PowerShell in the project folder:

```
py -3 tools\setup_rpcemu.py
```

What it does, in order:

1. It downloads five files into `RPCEmu-Extended/Downloads`, about 1.1 GB in
   total: RPCEmu Extended 2.0.0 for your system, the RISC OS Direct and RISC OS
   3.71 bundles, and RISC OS Open's 5.30 ROM and disc.
2. It installs the emulator, unless a machine is running.
3. It links `RPCEmu-Extended/shared` to this project's `app/` folder.
4. It builds the `direct` and `ro371` machines from the bundles, and `ro530`, with
   two-button mouse mode and networking on. RISC OS 5 gets its network address
   by DHCP. RISC OS 3.71 can't use DHCP, so the script gives it the fixed
   address `100.64.0.10` and the emulator as its route to the internet. The
   script also adds a boot task to 3.71 so that MODE 12 stays 640×256 (see
   [Troubleshooting](#troubleshooting)).
5. It forwards port 30123 on your computer to each machine, so another computer
   can join a game hosted in the emulator (see
   [network-play.md](network-play.md#in-rpcemu)). Other forwarding rules are
   kept. Existing machines get it too, unless one is running.

Options:

- `--three-button`: use a three-button mouse's middle button for Menu, instead
  of right click.
- `--arch amd64` or `--arch arm64` (Windows only): choose the emulator build.
  ARM PCs can run either; arm64 is faster.
- A folder name: use that data folder instead of `RPCEmu-Extended` in your home
  folder.

Downloaded files are kept, so running the script again carries on where it left
off. It never touches a machine that already exists. To rebuild one, delete its
`machines/<name>` and `roms/<name>` folders and `configs/<name>.cfg`, then run the
script again.

Then start a machine with the **Run on RISC OS 5**, **Run on RISC OS 5.30** or
**Run on RISC OS 3.71** task in VS Code (Command Palette › *Tasks: Run Task*), or:

```bash
python3 tools/rpcemu.py direct
```

using `530` or `371` for the others, and `py -3 tools\rpcemu.py` on Windows. Each
machine opens in its own window, and they can all run at once.

## Using RISC OS in the emulator

| RISC OS      | Mouse or keyboard                                 |
|--------------|--------------------------------------------------|
| Select       | Click                                            |
| Menu         | Right click, or two-finger click on a Mac trackpad (two-button mode) |
| Adjust       | Middle click (two-button mode)                   |
| Command line | F12 (if macOS uses the F-keys for itself, hold fn) |
| Leave full-screen | Alt+Enter                                   |

## Running Cavern Duel

1. In VS Code, run the **Build** task.
2. In RISC OS, click the **Shared** disc icon on the icon bar to open it.
3. Double-click `!CavenDuel`, then click its icon on the icon bar.

Change some BASIC, build again, and run it again in RISC OS. Re-open the filer
window if it doesn't notice the change.

Speed under emulation says little about real hardware. Use a Pi to judge timing.

## Running commands in RISC OS from a terminal

While a machine is running, its RISC OS command line can be used from a
terminal, and the output comes back there. On a Mac:

```bash
RPCEMU_DATADIR=~/RPCEmu-Extended ~/Applications/RPCEmu-Extended.app/Contents/MacOS/rpcemu-run --machine direct -- Cat 'HostFS::Shared.$'
```

On Windows, in a Command Prompt:

```
set RPCEMU_DATADIR=%USERPROFILE%\RPCEmu-Extended
"%LOCALAPPDATA%\Programs\RPCEmu-Extended\rpcemu-run.exe" --machine direct -- Cat HostFS::Shared.$
```

`rpcemu-shell` beside it gives an interactive prompt, and `rpcemu-netcap` shows
the machine's network traffic. See the emulator's `docs/hostcmd.md` and
`docs/netcapture.md`.

On Windows, `rpcemu-run` only works with one machine running: in RPCEmu
Extended 2.0.0 every Windows machine listens on the same port, 15590, so the
command can reach the wrong one.

A machine can also run with no window, reached over VNC:

```bash
~/Applications/RPCEmu-Extended.app/Contents/MacOS/rpcemu --datadir ~/RPCEmu-Extended --machine direct --headless --vnc-port 5901
```

On Windows the program is `rpcemu-recompiler.exe`, with the same options.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Cavern Duel on `ro371` stops with `Not enough memory to create sprite at line 1072` | MODE 12 has come up at 640×480. When the desktop starts, the emulator's RPCEmuMonitor module replaces the machine's monitor file with its own, which has no 640×256 mode. The `Tasks/EmuMon` boot task in `!Boot.Choices.Boot` loads the original file back. A machine made before the script added that task needs rebuilding (see [Install](#install)) |
| Mac: "RPCEmu Extended can't be opened" or "is damaged" | Run `xattr -dr com.apple.quarantine ~/Applications/RPCEmu-Extended.app` |
| Windows: `python3` opens the Microsoft Store | Use `py -3` instead, as the VS Code tasks do, after installing Python from python.org |
| Windows: a firewall prompt when testing network play | Allow Python on private networks. `tools/netpeer.py` and `tools/relay.py` wait for connections, which Windows asks about |
| Home-network game: the other player can't connect to a host in RPCEmu | They must type the host computer's address, not the one RISC OS shows. Check the machine has port 30123 forwarded (run the setup script with every machine closed), that the computer's firewall allows RPCEmu, and that only one machine on that computer is running |
| "Failed to add NAT Network port forwarding rule … Address already in use" | Another machine, or another program, already has port 30123 on this computer. The machine still works, but can't host a home-network game |
| A machine refuses to start and says it's already running | A machine can only run once at a time. Close its other window |
| Black window, nothing boots | `roms/<name>/` has no ROM file in it. `machines/<name>/rpclog.txt` says what went wrong |
| No **Shared** disc contents | Check `RPCEmu-Extended/shared` still links to the project: run the setup script again |
| Google Drive download fails or gives a small HTML file | Download in a browser instead and put the files in `RPCEmu-Extended/Downloads` as `EasyStart-Direct.zip` and `EasyStart-371.zip`, then run the script again |

## Removing it all

Delete the `RPCEmu-Extended` data folder in your home folder, and the emulator:
`~/Applications/RPCEmu-Extended.app` on a Mac, or
`%LOCALAPPDATA%\Programs\RPCEmu-Extended` on Windows.
