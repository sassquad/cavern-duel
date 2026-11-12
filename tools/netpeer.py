#!/usr/bin/env python3
"""Test Cavern Duel's network play from the Mac.

    netpeer.py relay [--port 30200] [--lag MS] [--jitter MS] [--spike MS]
        Wait for two copies of the game to connect, then pass everything
        between them. For machines that can't accept connections, such as
        two RPCEmu machines: on one, set CavernDuel$Relay to 100.64.0.1:30200
        and click Host; on the other, click Join and type 100.64.0.1:30200.
        To imitate the internet, each direction can be held up by --lag, up to
        --jitter more at random, and --spike more on 5% of its traffic.

    netpeer.py host [address[:port]] [--port 30200] [--frames N] [--cave FILE] [--settings F,W,T,S] [--room]
    netpeer.py join address[:port] [--frames N] [--room CODE]
        Play against one copy of the game with a pretend opponent that
        wanders about and fires now and then, printing what the game sends.
        "host" with no address waits for the game to connect (click Join and
        type 100.64.0.1:30200 in RPCEmu); with an address it connects out, to a relay
        or to a game behind a port forward. It sends the Default cave and the
        menu's starting settings unless given others, which can be used to
        try sending the game bad ones. With --room, the address is a relay.py,
        and it prints the room code to join with.

The protocol is described at the top of src/!CavenDuel/Net.bas.
"""
import argparse
import collections
import os
import random
import select
import socket
import struct
import sys
import time

PORT = 30123  # the game's, when connecting to a game or relay
# Listening on the Mac, keep clear of 30123: each emulated machine forwards it
LISTEN_PORT = 30200
VERSION = 3
REPORT = 5  # seconds between the relay's reports of the game's speed
CAVE = os.path.join(os.path.dirname(__file__), "..", "app", "!CavenDuel", "Screens", "Default,022")
SETTINGS = (50, 20, 5, 10)  # food, weapons, teleports, shields
NAMES = ["left", "right", "up", "down", "fire", "quit", "skip"]


def address(text):
    host, _, port = text.partition(":")
    return host, int(port) if port else PORT


def listen(port):
    server = socket.socket()
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("", port))
    server.listen(2)
    return server


def accept(server):
    conn, peer = server.accept()
    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    print(f"connection from {peer[0]}:{peer[1]}", flush=True)
    return conn


def connect(addr):
    conn = socket.create_connection(addr)
    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    print(f"connected to {addr[0]}:{addr[1]}", flush=True)
    return conn


def enter_room(conn, code):
    """Say hello to relay.py: code is a room to join, or None to host one."""
    if code is None:
        conn.sendall(b"CDRH\x01")
    else:
        conn.sendall(b"CDRJ\x01" + code.upper().encode())
    answer = recv_exact(conn, 4)
    if code is None and answer == b"CDRC":
        print(f"room code {recv_exact(conn, 4).decode()}", flush=True)
    elif answer != b"CDRY":
        sys.exit(f"the relay said {answer}")


def recv_exact(conn, n):
    data = b""
    while len(data) < n:
        more = conn.recv(n - len(data))
        if not more:
            return None
        data += more
    return data


def relay(port, lag=0, jitter=0, spike=0):
    def hold_up():  # seconds
        extra = lag + random.uniform(0, jitter)
        if random.random() < 0.05:
            extra += spike
        return extra / 1000

    server = listen(port)
    print(f"relay waiting on port {port}", flush=True)
    while True:
        a = accept(server)
        held = b""  # what the first player sends before the second arrives
        while True:
            ready, _, _ = select.select([a, server], [], [])
            if a in ready:
                try:
                    data = a.recv(4096)
                except OSError:
                    data = b""
                if not data:  # they gave up: don't pair the next player with them
                    print("the first player left; waiting again", flush=True)
                    a.close()
                    a = accept(server)
                    held = b""
                held += data
            elif server in ready:
                break
        b = accept(server)
        print("passing the game between them", flush=True)
        sent = {a: 0, b: 0}
        other = {a: b, b: a}
        waiting = {a: collections.deque(), b: collections.deque()}  # (when to pass on, data)
        started = reported = time.monotonic()
        shown = dict(sent)
        if held:
            waiting[a].append((started + hold_up(), held))
        try:
            finished = False
            while not finished:
                due = [w[0][0] for w in waiting.values() if w]
                pause = max(0, min(due) - time.monotonic()) if due else 1
                ready, _, _ = select.select([a, b], [], [], pause)
                now = time.monotonic()
                for s in ready:
                    data = s.recv(4096)
                    if not data:
                        finished = True
                        break
                    # Traffic stays in order, so nothing overtakes a held-up packet
                    last = waiting[s][-1][0] if waiting[s] else now
                    waiting[s].append((max(last, now + hold_up()), data))
                for s, queue in waiting.items():
                    while queue and queue[0][0] <= now:
                        data = queue.popleft()[1]
                        other[s].sendall(data)
                        sent[s] += len(data)
                if now - reported >= REPORT:  # each frame is two bytes
                    print("frames a second: {:.1f} and {:.1f}".format(
                        *((sent[s] - shown[s]) / 2 / (now - reported) for s in (a, b))), flush=True)
                    shown = dict(sent)
                    reported = now
        except OSError as e:  # a player hung up mid-game
            print(f"connection lost: {e}", flush=True)
        seconds = time.monotonic() - started
        print(f"game over after {seconds:.1f}s: {sent[a]} and {sent[b]} bytes passed on", flush=True)
        a.close()
        b.close()


def describe(bits):
    return "+".join(n for i, n in enumerate(NAMES) if bits & (1 << i)) or "-"


def set_delay(player, conn):
    """Time five round trips and agree the delay, as PROCnet_setdelay does."""
    worst = 0
    for _ in range(5):
        started = time.monotonic()
        if player == 1:
            conn.sendall(b"\0")
            recv_exact(conn, 1)
        else:
            recv_exact(conn, 1)
            conn.sendall(b"\0")
        worst = max(worst, int((time.monotonic() - started) * 100))
    if player == 2:
        got = recv_exact(conn, 1)
        if not got:
            sys.exit("the game closed the connection before agreeing a delay")
        return got[0]
    delay = min(6, max(2, (worst + 14) // 10 - 1))
    conn.sendall(bytes([delay]))
    return delay


def opponent(role, conn, frames, cave_file=CAVE, settings=SETTINGS):
    player = 1 if role == "host" else 2
    seed = random.getrandbits(32)
    if player == 1:
        conn.sendall(b"CDH" + bytes([VERSION]) + struct.pack("<I", seed))
        hello = recv_exact(conn, 4)
    else:
        conn.sendall(b"CDJ" + bytes([VERSION]))
        hello = recv_exact(conn, 8)
    if not hello or hello[:2] != b"CD":
        sys.exit("the other end isn't Cavern Duel")
    if hello[2:3] == (b"H" if player == 1 else b"J"):
        sys.exit(f"both sides are set to {role}")
    if hello[3] != VERSION:
        sys.exit(f"the game speaks protocol version {hello[3]}, not {VERSION}")
    if player == 2:
        seed = struct.unpack("<I", hello[4:8])[0]
    print(f"playing as player {player}, seed {seed}", flush=True)
    delay = set_delay(player, conn)
    print(f"input delay {delay} frames", flush=True)
    if player == 1:
        with open(cave_file, "rb") as f:
            cave = f.read()
        conn.sendall(struct.pack("<5I", len(cave), *settings) + cave)
    else:
        head = recv_exact(conn, 20)
        if not head or recv_exact(conn, struct.unpack("<I", head[:4])[0]) is None:
            sys.exit("the game closed the connection before sending its cave")
        print("settings from the game: food {}, weapons {}, teleports {}, shields {}".format(*struct.unpack("<4I", head[4:])), flush=True)
    conn.sendall(bytes(2 * delay))

    rng = random.Random(seed)
    move = 0
    frame = -delay  # the game's first delay frames are padding
    while frames is None or frame < frames:
        got = recv_exact(conn, 2)
        if got is None:
            print(f"the game closed the connection after frame {frame}", flush=True)
            return
        if frame % 10 == 0:
            move = rng.choice([0, 1, 2, 4, 8])
        fire = 16 if rng.random() < 0.1 else 0
        conn.sendall(bytes([move | fire, 0]))  # check 0: we don't run the game
        if frame % 20 == 0 or got[0] & 96:
            print(f"frame {frame:5}: game sent {describe(got[0]):20} check {got[1]}", flush=True)
        frame += 1
    print(f"stopped after {frames} frames", flush=True)


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("role", choices=["relay", "host", "join"])
    parser.add_argument("address", nargs="?")
    parser.add_argument("--port", type=int, default=LISTEN_PORT)
    parser.add_argument("--frames", type=int)
    parser.add_argument("--lag", type=int, default=0)
    parser.add_argument("--jitter", type=int, default=0)
    parser.add_argument("--spike", type=int, default=0)
    parser.add_argument("--room", nargs="?", const="", default=None)
    parser.add_argument("--cave", default=CAVE)
    parser.add_argument("--settings", type=lambda s: tuple(int(n) for n in s.split(",")), default=SETTINGS)
    args = parser.parse_args(argv[1:])
    try:
        if args.role == "relay":
            relay(args.port, args.lag, args.jitter, args.spike)
        elif args.address:
            conn = connect(address(args.address))
            if args.room is not None:
                enter_room(conn, args.room or None)
            opponent(args.role, conn, args.frames, args.cave, args.settings)
        elif args.role == "host":
            server = listen(args.port)
            print(f"waiting for the game on port {args.port}", flush=True)
            opponent("host", accept(server), args.frames, args.cave, args.settings)
        else:
            parser.error("join needs an address")
    except KeyboardInterrupt:
        pass
    except OSError as e:
        sys.exit(str(e))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
