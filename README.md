# Cavern Duel

A two-player maze game for RISC OS, by Graeme and Stephen Scott (1994–2011).
This repository is set up for development in VS Code on a Mac, testing under
RPCEmu and on real RISC OS 5 hardware.

More about the game, including the latest release to download, is at
<https://www.sassquad.net/cavernduel>.

## Layout

```
src/                    BBC BASIC as plain text – edit these
  !CavenDuel/!RunImage.bas
  !CavenDuel/Game.bas
  !CavernEd/!RunImage.bas
  shared/DrWimp.bas     Dr Wimp 5.04 library (third-party), built into
                        both !CavenDuel and !CavernEd
app/                    the RISC OS applications, in HostFS format
  !CavenDuel/           the game
  !CavernEd/            the cave editor
tools/
  bbcbasic.py           tokeniser / detokeniser for BBC BASIC V
  build.py              build, pull, check, deploy
  lint.py               finds calls to missing routines and variable
                        clashes with libraries (run by check)
  import_zip.py         unpacks a RISC OS zip into app/ + src/
  test_bbcbasic.py      tokeniser tests
  setup_rpcemu.sh       installs RPCEmu and the Easy Start machines
  rpcemu.sh             starts RPCEmu on RISC OS 5 or 3.71
docs/rpcemu-setup.md    RPCEmu installation guide
reference/              the original v1.271 release zip
```

Files in `app/` carry their RISC OS file type as a suffix, which is what
RPCEmu's HostFS expects: `,ffb` BASIC, `,feb` Obey, `,ff9` Sprite, `,ffa`
Module, `,fec` Template, `,022` Cavern Duel cave file. The `,ffb` files are
built from `src/` and are not committed.

The application folder really is called `!CavenDuel` (no "r"); `!Run` and
`!Boot` depend on that name, so it has been left alone.

## One-time setup

1. Install Python 3 (the Xcode command line tools' `python3` is fine) and
   VS Code. Optionally add a BBC BASIC syntax extension from the Marketplace.
2. Install RPCEmu with a RISC OS 5 and a RISC OS 3.71 machine, each of which
   sees `app/` as a disc called **CavernDuel**:

   ```bash
   tools/setup_rpcemu.sh
   ```

   [docs/rpcemu-setup.md](docs/rpcemu-setup.md) explains each step, the
   by-hand route, and troubleshooting.
3. Run the **Build** task once (⇧⌘B) to create the `,ffb` files.

## Everyday workflow

1. Edit `src/**/*.bas` in VS Code.
2. ⇧⌘B (**Build**). Errors such as an over-long line appear in the
   Problems panel.
3. Run the **Run on RISC OS 5** (or **3.71**) task, or start RPCEmu with
   `tools/rpcemu.sh direct`. Open the **CavernDuel** disc from the icon bar
   and double-click `!CavenDuel`.

If you edit BASIC inside RISC OS (with StrongED, Zap or `EDIT`), run
**Pull BASIC from app** to bring the changes back into `src/` before
committing.

Other tasks: **Check sources** and **Test tokeniser**. **Check sources**
confirms every file round-trips, then lints each program against the
libraries it loads. BASIC only reports a call to a missing routine, or a
misspelt one, when that line runs, so this catches them before you do.
Warnings (an identical duplicate routine, or a missing routine called only
from dead code) don't fail the check.

Dr Wimp is kept once, in `src/shared/`, and built into both apps. If you
edit it inside RISC OS, make the same change in the other app's copy (or
copy one over the other) before **Pull**, which refuses to choose between
two different copies.

### Source format

One BASIC line per text line: `<line number> <statement>`. Everything after
the single space following the number is kept exactly, so indentation
survives. A line with no number is numbered one more than the line before
it, which makes inserting lines easy; `RENUMBER` inside RISC OS and a
**Pull** tidies them up. Characters are Latin-1, which is what RISC OS uses.

## Testing on real hardware

A Raspberry Pi 4 (or 3B+/400) running RISC OS 5 is the best check, as
screen modes and speed differ from the emulator. Copy `app/` across on a USB
stick, or mount a Mac file share on the Pi with LanMan98.

## Porting notes

The code is already 32-bit safe: the only assembler (the palette fader in
`PROCinitfader`) returns with `LDMFD …,PC`, and the sound modules in
`Sounds/` (Voice Generator 2.05) are flagged 32-bit compatible. Remaining
work for modern RISC OS 5 machines:

- **Screen mode.** The game uses MODE 12 (16 colours, 640×256), palette
  fades via OS_Word 11/12 and screen banks via OS_Byte 112/113. Low-colour
  rectangular-pixel modes may not be available on newer hardware such as the
  Raspberry Pi; moving to a 256-colour mode string is the likely fix.
- **Timing.** Game speed relies on `TIME` busy-waits (e.g. `Game` line
  646), so it varies with machine speed; a fixed frame rate would help.
- **Dr Wimp.** Both apps use Dr Wimp 5.04, the latest release. The
  launcher moved from 4.70 with one change; `!CavernEd`, which had its own
  1995 desktop code, was rewritten onto Dr Wimp.
- **Future 64-bit RISC OS.** Rewriting the fader in BASIC would remove the
  only ARM assembler.
