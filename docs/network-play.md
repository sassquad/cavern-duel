# Network play

Two players on two machines, each seeing the usual split screen. Steps 1 to 4 of
the plan are done.

1. Read every key once a frame into `pad%()` and `ctl%` (`PROCreadkeys`).
2. Use the game's own seeded random numbers (`FNrnd`) instead of `RND`.
3. The network library, `src/!CavenDuel/Net.bas`, and `tools/netpeer.py`
   for testing from the Mac.
4. Host and Join buttons on the menu, with the host's settings and cave sent
   to the other player.
5. **Still to do:** testing on real machines on a LAN, then over the internet.

## Playing

1. One player sets up the menu and cave as they like, then clicks **Host**. The
   strip along the bottom of the menu shows their address.
2. The other player clicks **Join**, types that address and presses Return.

The game starts on both machines with the host's settings and cave, after a
message saying which player you are: the host plays Player 1, the other player
Player 2. Tab cancels
at any point before then. Join remembers the address until the machine restarts,
and keeps trying every second if the host isn't ready yet. Addresses must be
numbers; add `:port` if the host isn't on port 30123.

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

## Testing with RPCEmu Extended

Inside RPCEmu Extended the Mac is at **100.64.0.1**. RISC OS can connect out to
the Mac without any setup.

### One machine against a pretend player

1. In a Mac terminal, start a pretend host:

   ```bash
   python3 tools/netpeer.py host
   ```

2. Start RISC OS 5 (**Run on RISC OS 5**) and run Cavern Duel.
3. Click **Join** and type `100.64.0.1`. You're player 2. Player 1 wanders
   about and fires now and then. The terminal shows what your machine sends
   every 20 frames, and whenever you press Tab or skip.

### Two machines through a relay

Both machines connect out to a relay on the Mac, which passes everything
between them:

```bash
python3 tools/netpeer.py relay
```

On one machine, press F12 and type `*Set CavernDuel$Relay 100.64.0.1`, then run
the game and click **Host**: it connects out to the relay instead of waiting for
a connection. On the other, click **Join** and type `100.64.0.1`. They can connect
in either order, and the first waits for the second. The same relay,
run on a machine with a public address, would let two players behind home routers
play over the internet.

### Hosting inside the emulator

An emulated machine can't accept connections unless its port is forwarded. In
the host's emulator, use **Settings > NAT Port Forwarding Rules** to send a Mac
port, such as 30124, to port 30123. Another machine on the same Mac then joins
`100.64.0.1:30124`.

The address the host shows is its address inside the emulator, so it isn't the
one to give the other player: use the Mac's address, or `100.64.0.1` on the same
Mac. Connecting one emulated machine straight to another's address, without a
relay or a forward, was refused when tried. RPCEmu Extended's own notes say a
guest operating system using that link hasn't been demonstrated.

A game between RISC OS 5 and RISC OS 3.71 through the relay stayed in step for
about 1,150 frames with both players moving and firing.

## The protocol

TCP, port 30123 by default.

1. Greeting. The host sends `CDH`, the version (2) and the seed as 4 bytes
   little-endian. The joiner sends `CDJ` and the version. Each checks the
   other's greeting.
2. The host sends five 4-byte little-endian numbers (the length of the cave
   file, then food, weapons, teleports and shields), then the cave file. Both
   machines then load that cave afresh.
3. Each side sends two empty frames, the padding for the two-frame delay.
4. Every frame, each side sends two bytes:
   - **Controls:** 1 left, 2 right, 4 up, 8 down, 16 fire, 32 quit,
     64 skip winner.
   - **Check:** 1–128 from the game's state, or 0 for no check.

   The frame each side receives is the other's frame from two frames ago.
   That is the one both machines play now.

The connection closes when the game ends.
