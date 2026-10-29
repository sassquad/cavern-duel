# Setting up RPCEmu on the Mac

This guide sets up two emulated Risc PCs on the Mac:

| Machine  | RISC OS              | Use it for                                  |
|----------|----------------------|---------------------------------------------|
| `Direct` | RISC OS 5 (Direct)   | Main target: modern 32-bit RISC OS          |
| `RO371`  | RISC OS 3.71 (1998)  | Checking the game still runs on old systems |

Both machines see this project's `app/` folder as an extra disc called
**CavernDuel**. Press ⇧⌘B in VS Code, and the new build is there straight
away. Nothing needs copying.

## Why it's fiddly, and what each piece is

RPCEmu is put together from parts that come from different places:

- **The emulator.** The official RPCEmu site (marutan.net) only offers a
  Windows build. Mac builds come from a separate project,
  [Septercius/rpcemu-dev](https://github.com/Septercius/rpcemu-dev/releases).
  We use **0.9.5b** (September 2026), which can map extra Mac folders as
  HostFS discs.
- **The "data folder".** The app keeps nothing inside itself. Each machine is
  a folder holding:
  - `roms/`: the RISC OS ROM image
  - `hostfs/`: the machine's hard disc, as ordinary Mac files
  - `cmos.ram`: the machine's saved settings
  - `rpc.cfg`: the emulator settings
  - `poduleroms/` and `netroms/`: emulator support modules
  - `rpclog.txt`: the log, written when the emulator runs

  The Mac build asks for this folder the first time it starts, and then
  remembers **only one**.
- **The Easy Start bundles** fill a data folder with a ROM, a ready-made
  hard disc, CMOS settings and networking. They are hosted on Google Drive,
  linked from <http://www.marutan.net/rpcemu/easystart.html>. Use the
  **"Other platforms"** editions, which leave out the Windows program.
- **HostFS** is how RISC OS sees Mac folders. A RISC OS file type travels in
  the Mac filename as a suffix (`Game,ffb`), which is why `app/` is laid out
  that way.

## Option A: run the setup script (recommended)

```bash
tools/setup_rpcemu.sh
```

What it does, in order:

1. It downloads three files into `~/RPCEmu/Downloads`, about 1.4 GB in
   total:
   - RPCEmu 0.9.5b
   - the RISC OS Direct bundle (1 GB)
   - the RISC OS 3.71 bundle
2. It installs `RPCEmu-Interpreter.app` into `~/Applications`. It also
   removes the macOS "downloaded from the internet" flag, because the app is
   not notarised and macOS would otherwise refuse to open it.
3. It builds `~/RPCEmu/Direct` and `~/RPCEmu/RO371`. Each one starts from
   RPCEmu's template data folder with the bundle copied over it. Then the
   script:
   - swaps in the multi-drive HostFS modules
   - turns on two-button mouse mode
   - adds this project's `app/` folder as HostFS drive 2, named `CavernDuel`

Downloaded files are kept, so running the script again carries on where it
left off. It never touches a machine folder that already exists. To rebuild a
machine, delete its folder and run the script again.

Then start a machine:

```bash
tools/rpcemu.sh direct
```

```bash
tools/rpcemu.sh 371
```

The launcher points RPCEmu at the chosen machine's folder and opens it.
Quit RPCEmu (**File › Exit**) before switching to the other machine.

There are also **Run on RISC OS 5** and **Run on RISC OS 3.71** tasks in VS
Code (⇧⌘P › *Tasks: Run Task*).

If something goes wrong, see [Troubleshooting](#troubleshooting). Option B
below is the same process done by hand, which helps when you need to see
which step failed.

## Option B: by hand

### 1. Install the emulator

1. Go to <https://github.com/Septercius/rpcemu-dev/releases> and download
   **`RPCEmu-0.9.5b-Release.zip`**. Use the zip, not the DMG, and the
   Release build, not Debug.
2. Unzip it. Inside are:
   - `RPCEmu-Interpreter.app`: works on Apple silicon and Intel. **Use this
     one.**
   - `RPCEmu-Recompiler.app`: Intel code only. On Apple silicon it runs
     through Rosetta and is usually slower than the Interpreter.
   - `Data/`: a template data folder.
3. Drag `RPCEmu-Interpreter.app` into **Applications**.
4. Let macOS open it. The app isn't notarised, so on first launch macOS
   says it "can't be opened". Either run this:

   ```bash
   xattr -dr com.apple.quarantine /Applications/RPCEmu-Interpreter.app
   ```

   or try to open it once, then go to **System Settings › Privacy &
   Security**, scroll down and click **Open Anyway**.

### 2. Download the Easy Start bundles

1. Open <http://www.marutan.net/rpcemu/easystart.html>.
2. Under **RISC OS Direct**, click **Other platforms Edition** (about
   1 GB). Under **RISC OS 3.71**, do the same (about 116 MB).
3. Google Drive shows a page saying it "can't scan this file for viruses".
   Click **Download anyway**.
4. Unzip both by double-clicking them in Finder. Each unzips to a single
   folder named `RPCEmu - …`. Don't use `unzip` in Terminal: some filenames
   in the 3.71 bundle use the RISC OS character set, which macOS rejects.
   `unzip` then stops part-way with a misleading "disk full?" error. Finder
   converts the names instead (`!Élite` comes out as `!Çlite`, which only
   affects bundled extras).

### 3. Build each machine's data folder

Do this once for each bundle. The example is for RISC OS 5.

1. Make a folder for the machine, such as `~/RPCEmu/Direct`.
2. Copy the **contents** of the template `Data` folder into it.
3. Copy the **contents** of the unzipped bundle folder over the top.
   Replace files when asked. You should end up with this:

   ```
   ~/RPCEmu/Direct/
     cmos.ram   rpc.cfg   roms/   hostfs/   poduleroms/   netroms/
   ```

4. Look in `poduleroms/`. It must contain `multihostfs,ffa` and
   `multihostfsfiler,ffa`. If it also has `hostfs,ffa` or
   `hostfsfiler,ffa`, delete those two. Extra HostFS discs only work with
   the multi-drive versions.

### 4. First start

1. Open RPCEmu-Interpreter. It asks for a data folder. Click **Select**
   and choose `~/RPCEmu/Direct`.
2. RISC OS starts, but the first time it stops at a `*` prompt under the
   word "Supervisor". The bundles were made for the older single-drive
   HostFS. The multi-drive version also needs to be told which drive to
   boot from, and the bundles leave that unset. Type these two lines,
   pressing Return after each:

   ```
   *Configure HostFSDrive 4
   *Configure Boot
   ```

   then choose **File › Reset**. RISC OS now boots to the desktop in about
   a minute, with **HostFS** and the other drives on the icon bar along the
   bottom. The setting is saved, so you only do this once per machine.
   (The setup script sets this for you.)
3. Choose **Settings › Mouse › Two-button Mouse Mode**, so that a right
   click (or two-finger trackpad click) acts as RISC OS's **Menu** button.
4. Choose **Settings › HostFS…**. In the second drive's box:
   - tick **Enabled**
   - **Name:** `CavernDuel`
   - **Location:** click **Select…** and choose `~/www/cavern-duel/app`

   Then click OK. If RPCEmu doesn't restart RISC OS by itself, use
   **File › Reset**.

To use the other machine later, quit RPCEmu, point it at the other data
folder, and open it again:

```bash
defaults write org.marutan.rpcemu DataDirectory ~/RPCEmu/RO371
```

That command is all `tools/rpcemu.sh` does.

## Using RISC OS in the emulator

| RISC OS     | On the Mac                                               |
|-------------|----------------------------------------------------------|
| Select      | Click                                                    |
| Menu        | Right click / two-finger click (two-button mode)         |
| Adjust      | Only with two-button mode off: then right click = Adjust |
| Release a captured mouse | Ctrl+⌘                                      |
| Command line | F12 (if macOS uses the F-keys for itself, hold fn) |

- **Settings › Configure…** sets the RAM size and CPU. The bundles already
  choose sensible values (a StrongARM Risc PC).
- **Follow Host Mouse** is on by default, so the RISC OS pointer simply
  follows the Mac one. That is easiest for desktop use.
- **Full-screen mode** is in the Settings menu. Ctrl+⌘ gets you out again.
- The bundles set networking to NAT, which should let RISC OS reach the
  internet with no further setup.

## Running Cavern Duel

1. In VS Code, press ⇧⌘B to build.
2. In RISC OS, click the **CavernDuel** disc icon on the icon bar to open
   it.
3. Double-click `!CavenDuel`.

Change some BASIC, press ⇧⌘B, and run it again in RISC OS. Re-open the
filer window if it doesn't notice the change.

Things to watch for, which are the porting work:

- On **RISC OS 5**, the game should start in MODE 12 under emulation. Real
  Raspberry Pi hardware may not offer that mode.
- On **3.71** the game should behave exactly as it always has. If it
  doesn't, a change has broken backwards compatibility.
- Speed under emulation says little about real hardware. Use a Pi to judge
  timing.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| "RPCEmu-Interpreter can't be opened" or "is damaged" | Run the `xattr` command from step 1.4, or use **Open Anyway** |
| Asks for the data folder every time | The saved folder has moved or been deleted. Choose it again, or run `tools/rpcemu.sh` |
| Stops at a `*` prompt under "Supervisor" | The HostFS boot drive isn't set. Type `*Configure HostFSDrive 4`, then **File › Reset** (step 4.2) |
| Black window, nothing boots | `roms/` has no ROM file in it. Re-copy it from the bundle. `rpclog.txt` in the data folder says what went wrong |
| No **CavernDuel** disc on the icon bar | Check **Settings › HostFS…**. Check `poduleroms/` holds the `multihostfs` files (step 3.4). Check the folder path exists |
| No sound | Check sound is turned on in **Settings › Configure…** (`sound_enabled=1` in `rpc.cfg`). Also check the Mac's output device |
| `unzip` says "write error (disk full?)" | It isn't the disc. It's a RISC OS filename macOS won't accept. Unzip in Finder instead (see step 2.4) |
| Google Drive download fails or gives a small HTML file | Download in a browser instead and put the files in `~/RPCEmu/Downloads` as `EasyStart-Direct.zip` and `EasyStart-371.zip`, then run the script again |
| Wrong machine started | Quit RPCEmu completely (File › Exit), then use `tools/rpcemu.sh` |

## Removing it all

```bash
rm -rf ~/RPCEmu ~/Applications/RPCEmu-Interpreter.app
```

```bash
defaults delete org.marutan.rpcemu
```
