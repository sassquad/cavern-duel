# Network play

Two players on two machines, each seeing the usual split screen, on a home
network or over the internet. Steps 1 to 4 of the plan are done.

1. Read every key once a frame into `pad%()` and `ctl%` (`PROCreadkeys`).
2. Use the game's own seeded random numbers (`FNrnd`) instead of `RND`.
3. The network library, `src/!CavenDuel/Net.bas`, and `tools/netpeer.py`
   for testing from the Mac.
4. Host and Join buttons on the menu, with the host's settings and cave sent
   to the other player.
5. **Still to do:** testing on real machines, on a LAN and over the internet.

## Playing

1. One player sets up the menu and cave as they like, then clicks **Host**, and
   presses H for the home network or I for the internet. On a home network, the
   strip along the bottom of the menu shows their address. Over the internet, it
   shows a four-letter room code.
2. The other player clicks **Join**, types that address or room code and presses
   Return.

The game starts on both machines with the host's settings and cave, after a
message saying which player you are: the host plays Player 1, the other player
Player 2. Tab cancels
at any point before then. Join remembers what was typed until the machine
restarts, and keeps trying every second if the host isn't ready yet. An address can
be numbers or a name; add `:port` if the host isn't on port 30123. Four letters on
their own are taken as a room code, in either case.

Over the internet, both machines connect out to the relay at
`relay.sassquad.net`, so neither player needs to forward a port. To use
another relay, set `CavernDuel$Server` to its address before running the game.
The relay closes a room if nobody joins within 15 minutes.

## How it works

Both machines run the whole game. Each frame, each sends the other two
bytes: its player's controls and a check of the game's state. Because the
game makes the same moves from the same controls and the same random seed,
both screens stay identical. The host plays player 1 and picks the seed;
whoever joins plays player 2. On either machine you can use either set of
keys.

Controls take effect a few frames after they're sent, on both machines at once,
so ordinary network lag doesn't slow the game down. The host times the connection
before the game and picks this delay for both machines: two frames (a tenth of a
second) on a good connection, up to six on a slow one. A connection too slow even
for that slows the game down rather than stopping it. If the checks ever differ, the games have drifted apart, and both stop
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

### Imitating the internet

The relay can hold up the game's traffic, to try it on a poor connection. Each
direction is held up by `--lag` milliseconds, up to `--jitter` more at random, and
`--spike` more on 5% of its traffic:

```bash
python3 tools/netpeer.py relay --lag 150 --jitter 30 --spike 200
```

Every 5 seconds the relay prints the game's speed in frames a second, which should
stay at about 20.

## The internet relay

`tools/relay.py` is the program for playing over the internet: it runs on a server
with a public address, and needs only Python 3.8 or later. Both players connect
out to it, so neither needs a port forwarded. The game looks for it at
`relay.sassquad.net`, or at `CavernDuel$Server` if that's set.
[relay-server.md](relay-server.md) explains how to set it up on a server.

Through the relay at `relay.sassquad.net`, a game in RPCEmu on RISC OS 5.27 played
one on 5.30, and another played 3.71, with both screens staying identical. Both
emulators were on the same Mac, connecting out to the VPS, about 20 ms there and
back.

A game hosted by RISC OS 5.30 in RPCEmu on Windows 11 (ARM, in Parallels), and
joined from RISC OS 5.27 on the Mac, also stayed in step: the two screens were
pixel-for-pixel identical. Tab on Windows ended the game on both.

The relay pairs players by a four-letter room code, then passes everything between
them without looking at it. It keeps nothing on disc and logs no addresses. So that
it's safe to leave running, it has these limits, set at the top of the file:

| Limit | Value |
|---|---|
| Time to say whether you're hosting or joining | 10 seconds |
| Time for the other player to arrive | 15 minutes |
| Silence from both players before a game is dropped | 30 seconds |
| Length of one game | 4 hours |
| Connections at once, from everyone | 500 |
| Connections at once, from one address | 6 |
| Rooms waiting, from one address | 3 |
| Wrong codes a minute, from one address | 10 |
| Data from one player | 64 KB at once, then 1 KB a second |

To try it with pretend players, start the relay and a host, which prints a code:

```bash
python3 tools/relay.py
```

```bash
python3 tools/netpeer.py host 127.0.0.1 --room
```

Then join with that code:

```bash
python3 tools/netpeer.py join 127.0.0.1 --room ABCD
```

To try it with the game in RPCEmu, start the relay on the Mac, and on each
machine press F12 and type `*Set CavernDuel$Server 100.64.0.1` before running the
game. Host with I on one, and join with the room code on the other. A game between
RISC OS 5.27 and 3.71 this way stayed in step, and a wrong code, a cancelled room
and a server that isn't a relay each gave a clear message.

The **Test relay** task in VS Code runs its tests. A hundred pretend games at once
took about 20% of one Mac Studio core, including the pretend players, and under 30
MB of memory.

### Talking to the relay

This comes before the game's own protocol, below, which then runs unchanged.

1. A host sends `CDRH` and the relay protocol's version, 1, as one byte. The relay
   answers `CDRC` and the room code. Anything the host sends next waits for the
   other player, up to 1 KB.
2. A joiner sends `CDRJ`, the version and the four letters of the code. The relay
   answers `CDRY`, and from then on passes everything between them.

Instead of those answers, the relay can send `CDRN` (no such room), `CDRB` (too
busy, or a limit has been reached) or `CDRV` (a version it doesn't know), and it
closes the connection. It also closes a connection to end a game, and when a room
runs out of time.

## The protocol

TCP, port 30123 by default.

1. Greeting. The host sends `CDH`, the version (3) and the seed as 4 bytes
   little-endian. The joiner sends `CDJ` and the version. Each checks the
   other's greeting.
2. Five times, the host sends one byte and the joiner sends one back. From the
   slowest of these, in centiseconds, the host works out the delay:
   `(slowest + 14) DIV 10 - 1`, kept between 2 and 6 frames. It sends the delay as
   one byte.
3. The host sends five 4-byte little-endian numbers (the length of the cave
   file, then food, weapons, teleports and shields), then the cave file. The
   joiner checks them against the menu's limits and the cave format, and leaves
   the game if they aren't valid. Both machines then load that cave afresh.
4. Each side sends as many empty frames as the delay, as padding.
5. Every frame, each side sends two bytes:
   - **Controls:** 1 left, 2 right, 4 up, 8 down, 16 fire, 32 quit,
     64 skip winner.
   - **Check:** 1–128 from the game's state, or 0 for no check.

   The frame each side receives is the other's frame from that many frames ago.
   That is the one both machines play now.

The connection closes when the game ends.
