#!/usr/bin/env python3
"""Test Cavern Duel's network play from the Mac.

    netpeer.py relay [--port 30123]
        Wait for two copies of the game to connect, then pass everything
        between them. For machines that can't accept connections, such as
        two RPCEmu machines: on one, set CavernDuel$Relay to 100.64.0.1 and
        click Host; on the other, click Join and type 100.64.0.1.

    netpeer.py host [address[:port]] [--port 30123] [--frames N]
    netpeer.py join address[:port] [--frames N]
        Play against one copy of the game with a pretend opponent that
        wanders about and fires now and then, printing what the game sends.
        "host" with no address waits for the game to connect (click Join and
        type 100.64.0.1 in RPCEmu); with an address it connects out, to a relay
        or to a game behind a port forward. It sends the Default cave and the
        menu's starting settings.

The protocol is described at the top of src/!CavenDuel/Net.bas.
"""
import argparse
import os
import random
import select
import socket
import struct
import sys

PORT = 30123
VERSION = 2
DELAY = 2  # frames; must match net_delay% in Net.bas
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


def recv_exact(conn, n):
    data = b""
    while len(data) < n:
        more = conn.recv(n - len(data))
        if not more:
            return None
        data += more
    return data


def relay(port):
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
        sent = {a: len(held), b: 0}
        other = {a: b, b: a}
        try:
            b.sendall(held)
            while True:
                ready, _, _ = select.select([a, b], [], [])
                data = b""
                for s in ready:
                    data = s.recv(4096)
                    if not data:
                        break
                    other[s].sendall(data)
                    sent[s] += len(data)
                if not data:
                    break
        except OSError as e:  # a player hung up mid-game
            print(f"connection lost: {e}", flush=True)
        print(f"game over: {sent[a]} and {sent[b]} bytes passed on", flush=True)
        a.close()
        b.close()


def describe(bits):
    return "+".join(n for i, n in enumerate(NAMES) if bits & (1 << i)) or "-"


def opponent(role, conn, frames):
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
    if player == 1:
        with open(CAVE, "rb") as f:
            cave = f.read()
        conn.sendall(struct.pack("<5I", len(cave), *SETTINGS) + cave)
    else:
        head = recv_exact(conn, 20)
        if not head or recv_exact(conn, struct.unpack("<I", head[:4])[0]) is None:
            sys.exit("the game closed the connection before sending its cave")
        print("settings from the game: food {}, weapons {}, teleports {}, shields {}".format(*struct.unpack("<4I", head[4:])), flush=True)
    conn.sendall(bytes(2 * DELAY))

    rng = random.Random(seed)
    move = 0
    frame = -DELAY  # the game's first DELAY frames are padding
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
    parser.add_argument("--port", type=int, default=PORT)
    parser.add_argument("--frames", type=int)
    args = parser.parse_args(argv[1:])
    try:
        if args.role == "relay":
            relay(args.port)
        elif args.address:
            opponent(args.role, connect(address(args.address)), args.frames)
        elif args.role == "host":
            server = listen(args.port)
            print(f"waiting for the game on port {args.port}", flush=True)
            opponent("host", accept(server), args.frames)
        else:
            parser.error("join needs an address")
    except KeyboardInterrupt:
        pass
    except OSError as e:
        sys.exit(str(e))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
