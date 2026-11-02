# Network play

Work in progress: two players on two machines, each seeing the usual split
screen. This is step 3 of the plan below. Steps 1 and 2 are done.

1. Read every key once a frame into `pad%()` and `ctl%` (`PROCreadkeys`).
2. Use the game's own seeded random numbers (`FNrnd`) instead of `RND`.
3. **The network library, `src/!CavenDuel/Net.bas`, and `tools/netpeer.py`
   for testing from the Mac.**
4. A Host/Join option on the menu, with an address box, and the host's
   menu settings and cave sent to the other player.
5. Testing on two RPCEmu machines, then real machines on a LAN, then over
   the internet.

## How it works

Both machines run the whole game. Each frame, each sends the other two
bytes: its player's controls and a check of the game's state. Because the
game makes the same moves from the same controls and the same random seed,
both screens stay identical. The host plays player 1 and picks the seed;
whoever joins plays player 2. On either machine you can use either set of
keys.

Controls take effect two frames (a tenth of a second) after they're sent,
on both machines at once, so ordinary network lag doesn't slow the game
down. If the checks ever differ, the games have drifted apart, and both stop
with a message saying so.

In a network game, pause is switched off (it would freeze the other player
too). The sound keys only affect your own machine. Tab or a mouse click
(skip the winner screen) acts on both.

## Choosing host or join, for now

Until step 4 adds it to the menu, set a system variable before starting the
game. Press F12, type one of these, then press Return on an empty line to
get back to the desktop:

| Command | Means |
|---|---|
| `*Set CavernDuel$Net host` | Wait for the other player on port 30123 |
| `*Set CavernDuel$Net join 192.168.1.20` | Connect to the host at that address |
| `*Set CavernDuel$Net host 10.10.10.2` | Connect out to a relay as player 1 |
| `*Unset CavernDuel$Net` | Back to two players on one keyboard |

Add `:port` to an address if it isn't 30123. Addresses must be numbers for
now. Both players should leave the menu settings at the same values and use
the same cave, until step 4 sends them across.

Clicking **Play** (or pressing Space) connects first. Messages appear in a
strip along the bottom of the menu, and Tab cancels. A player who joins
before the host is ready keeps trying every second.

## Testing with RPCEmu Extended

Inside RPCEmu Extended the Mac is at **100.64.0.1**. RISC OS can connect out to
the Mac without any setup.

### One machine against a pretend player

1. In a Mac terminal, start a pretend host:

   ```bash
   python3 tools/netpeer.py host
   ```

2. Start RISC OS 5 (**Run on RISC OS 5**) and set `CavernDuel$Net` to
   `join 100.64.0.1`.
3. Run Cavern Duel and click **Play**. You're player 2. Player 1 wanders
   about and fires now and then. The terminal shows what your machine sends
   every 20 frames, and whenever you press Tab or skip.

### Two machines through a relay

Both machines connect out to a relay on the Mac, which passes everything
between them:

```bash
python3 tools/netpeer.py relay
```

Set `CavernDuel$Net` to `host 100.64.0.1` on one machine and
`join 100.64.0.1` on the other. The same relay, run on a machine with a public
address, would let two players behind home routers play over the internet.

Connecting one emulated machine straight to another's address, without the
relay, was refused when tried. RPCEmu Extended's own notes say a guest
operating system using that link hasn't been demonstrated.

A game between RISC OS 5 and RISC OS 3.71 through the relay stayed in step for
about 1,150 frames with both players moving and firing.

## The protocol

TCP, port 30123 by default.

1. Greeting. The host sends `CDH`, the version (1) and the seed as 4 bytes
   little-endian. The joiner sends `CDJ` and the version. Each checks the
   other's greeting.
2. Each side sends two empty frames, the padding for the two-frame delay.
3. Every frame, each side sends two bytes:
   - **Controls:** 1 left, 2 right, 4 up, 8 down, 16 fire, 32 quit,
     64 skip winner.
   - **Check:** 1–128 from the game's state, or 0 for no check.

   The frame each side receives is the other's frame from two frames ago.
   That is the one both machines play now.

The connection closes when the game ends.
