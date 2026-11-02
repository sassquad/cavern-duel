# Setting up RPCEmu Extended on the Mac

This guide sets up two emulated Risc PCs on the Mac, using
[RPCEmu Extended](https://github.com/andrewtimmins/rpcemu-extended):

| Machine  | RISC OS              | Use it for                                  |
|----------|----------------------|---------------------------------------------|
| `direct` | RISC OS 5 (Direct)   | Main target: modern 32-bit RISC OS          |
| `ro371`  | RISC OS 3.71         | Checking the game still runs on old systems |

Both machines see this project's `app/` folder as their **Shared** disc. Press
⇧⌘B in VS Code, and the new build is there straight away. Nothing needs
copying.

## What each piece is

- **The emulator.** RPCEmu Extended is a universal app that runs natively on
  Apple silicon. It isn't notarised, so the setup script removes the macOS
  "downloaded from the internet" flag.
- **The data folder**, `~/RPCEmu-Extended`:

  ```
  configs/direct.cfg  configs/ro371.cfg     each machine's settings
  machines/<name>/hostfs/                   its hard disc, as ordinary Mac files
  machines/<name>/cmos.ram                  its saved RISC OS settings
  machines/<name>/rpclog.txt                its log
  roms/<name>/                              its RISC OS ROM image
  shared/                                   a link to this project's app/
  ```

- **The Easy Start bundles** supply each machine's ROM, ready-made hard disc
  and CMOS settings. They are hosted on Google Drive, linked from
  <http://www.marutan.net/rpcemu/easystart.html>. The **"Other platforms"**
  editions are the ones used.
- **HostFS** is how RISC OS sees Mac folders. A RISC OS file type travels in
  the Mac filename as a suffix (`Game,ffb`), which is why `app/` is laid out
  that way.

## Install

```bash
tools/setup_rpcemu.sh
```

What it does, in order:

1. It downloads three files into `~/RPCEmu-Extended/Downloads`, about 1.1 GB in
   total: RPCEmu Extended 2.0.0, the RISC OS Direct bundle and the RISC OS 3.71
   bundle.
2. It installs `RPCEmu-Extended.app` into `~/Applications`.
3. It links `~/RPCEmu-Extended/shared` to this project's `app/` folder.
4. It builds the `direct` and `ro371` machines from the bundles, with
   two-button mouse mode and networking on. RISC OS 5 gets its network address
   by DHCP. RISC OS 3.71 can't use DHCP, so the script gives it the fixed
   address `100.64.0.10`. The script also adds a boot task to 3.71 so that
   MODE 12 stays 640×256 (see [Troubleshooting](#troubleshooting)).

Downloaded files are kept, so running the script again carries on where it left
off. It never touches a machine that already exists. To rebuild one, delete its
files and run the script again:

```bash
rm -rf ~/RPCEmu-Extended/machines/ro371 ~/RPCEmu-Extended/roms/ro371 ~/RPCEmu-Extended/configs/ro371.cfg
```

Then start a machine:

```bash
tools/rpcemu.sh direct
```

```bash
tools/rpcemu.sh 371
```

Each machine opens in its own window, and both can run at once. There are also
**Run on RISC OS 5** and **Run on RISC OS 3.71** tasks in VS Code (⇧⌘P ›
*Tasks: Run Task*).

## Using RISC OS in the emulator

| RISC OS      | On the Mac                                       |
|--------------|--------------------------------------------------|
| Select       | Click                                            |
| Menu         | Right click / two-finger click (two-button mode) |
| Command line | F12 (if macOS uses the F-keys for itself, hold fn) |
| Leave full-screen | Alt+Enter                                   |

## Running Cavern Duel

1. In VS Code, press ⇧⌘B to build.
2. In RISC OS, click the **Shared** disc icon on the icon bar to open it.
3. Double-click `!CavenDuel`, then click its icon on the icon bar.

Change some BASIC, press ⇧⌘B, and run it again in RISC OS. Re-open the filer
window if it doesn't notice the change.

Speed under emulation says little about real hardware. Use a Pi to judge timing.

## Running commands in RISC OS from the Mac

While a machine is running, its RISC OS command line can be used from a Mac
terminal, and the output comes back there:

```bash
RPCEMU_DATADIR=~/RPCEmu-Extended ~/Applications/RPCEmu-Extended.app/Contents/MacOS/rpcemu-run --machine direct -- Cat 'HostFS::Shared.$'
```

`rpcemu-shell` beside it gives an interactive prompt, and `rpcemu-netcap` shows
the machine's network traffic. See the emulator's `docs/hostcmd.md` and
`docs/netcapture.md`.

A machine can also run with no window, reached over VNC:

```bash
~/Applications/RPCEmu-Extended.app/Contents/MacOS/rpcemu --datadir ~/RPCEmu-Extended --machine direct --headless --vnc-port 5901
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Cavern Duel on `ro371` stops with `Not enough memory to create sprite at line 1072` | MODE 12 has come up at 640×480. When the desktop starts, the emulator's RPCEmuMonitor module replaces the machine's monitor file with its own, which has no 640×256 mode. The `Tasks/EmuMon` boot task in `!Boot.Choices.Boot` loads the original file back. A machine made before the script added that task needs rebuilding (see [Install](#install)) |
| "RPCEmu Extended can't be opened" or "is damaged" | Run `xattr -dr com.apple.quarantine ~/Applications/RPCEmu-Extended.app` |
| A machine refuses to start and says it's already running | A machine can only run once at a time. Close its other window |
| Black window, nothing boots | `roms/<name>/` has no ROM file in it. `machines/<name>/rpclog.txt` says what went wrong |
| No **Shared** disc contents | Check `~/RPCEmu-Extended/shared` still links to the project: run the setup script again |
| Google Drive download fails or gives a small HTML file | Download in a browser instead and put the files in `~/RPCEmu-Extended/Downloads` as `EasyStart-Direct.zip` and `EasyStart-371.zip`, then run the script again |

## Removing it all

```bash
rm -rf ~/RPCEmu-Extended ~/Applications/RPCEmu-Extended.app
```
