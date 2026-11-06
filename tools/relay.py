#!/usr/bin/env python3
"""Pair Cavern Duel players by room code, for games over the internet.

    relay.py [--port 30123] [--address 0.0.0.0]

Both players connect out to this, so neither needs a port forwarded. The host
gets a four-letter code to give the other player. Once they're paired, the
relay passes everything between them without looking at it, so a new version of
the game doesn't need a new relay. It keeps nothing on disc and logs no
addresses. See docs/network-play.md for the protocol.

Needs only Python 3.8 or later.
"""
import argparse
import asyncio
import collections
import secrets
import time

PORT = 30123
VERSION = 1
LETTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ"  # no I or O, which look like 1 and 0


class Limits:
    hello_seconds = 10       # to say whether you're hosting or joining
    room_seconds = 15 * 60   # for the other player to arrive
    idle_seconds = 30        # with nothing from either player, once paired
    game_seconds = 4 * 3600  # for one game
    connections = 500        # at once, from everyone
    connections_per_ip = 6
    rooms_per_ip = 3
    bad_codes_per_minute = 10  # per address, so codes can't be guessed
    burst_bytes = 64 * 1024  # for the cave at the start of a game
    bytes_per_second = 1024  # a game sends about 40
    held_bytes = 1024        # from a host, before the other player arrives
    poll_seconds = 5         # how often to look at the time limits


class Connection:
    def __init__(self, reader, writer, limits):
        self.reader = reader
        self.writer = writer
        self.peer = None
        self.held = bytearray()
        self.allowance = limits.burst_bytes
        self.topped_up = self.last_heard = time.monotonic()
        self.limits = limits

    def within_rate(self, n):
        now = time.monotonic()
        self.allowance = min(self.limits.burst_bytes,
                             self.allowance + (now - self.topped_up) * self.limits.bytes_per_second)
        self.topped_up = now
        self.allowance -= n
        return self.allowance >= 0

    def close(self):
        self.writer.close()


class Relay:
    def __init__(self, limits=Limits):
        self.limits = limits
        self.rooms = {}  # code -> the host's Connection
        self.open_connections = 0
        self.per_ip = collections.Counter()
        self.rooms_per_ip = collections.Counter()
        self.bad_codes = {}  # address -> when its recent wrong codes were tried
        self.games = 0

    async def handle(self, reader, writer):
        ip = (writer.get_extra_info("peername") or ("?",))[0]
        conn = Connection(reader, writer, self.limits)
        self.open_connections += 1
        self.per_ip[ip] += 1
        try:
            if (self.open_connections > self.limits.connections
                    or self.per_ip[ip] > self.limits.connections_per_ip):
                writer.write(b"CDRB")
                await writer.drain()
                return
            hello = await asyncio.wait_for(reader.readexactly(5), self.limits.hello_seconds)
            if hello[:3] != b"CDR" or hello[3:4] not in (b"H", b"J"):
                return
            if hello[4] != VERSION:
                writer.write(b"CDRV")
                await writer.drain()
            elif hello[3:4] == b"H":
                await self.host(conn, ip)
            else:
                await self.join(conn, ip)
        except (asyncio.TimeoutError, asyncio.IncompleteReadError, OSError):
            pass
        finally:
            self.open_connections -= 1
            self.per_ip[ip] -= 1
            if not self.per_ip[ip]:
                del self.per_ip[ip]
            conn.close()

    async def host(self, conn, ip):
        if self.rooms_per_ip[ip] >= self.limits.rooms_per_ip:
            conn.writer.write(b"CDRB")
            await conn.writer.drain()
            return
        while True:
            code = "".join(secrets.choice(LETTERS) for _ in range(4))
            if code not in self.rooms:
                break
        self.rooms[code] = conn
        self.rooms_per_ip[ip] += 1
        try:
            conn.writer.write(b"CDRC" + code.encode())
            await conn.writer.drain()
            await self.pump(conn, time.monotonic() + self.limits.room_seconds)
        finally:
            if self.rooms.get(code) is conn:
                del self.rooms[code]
            self.rooms_per_ip[ip] -= 1
            if not self.rooms_per_ip[ip]:
                del self.rooms_per_ip[ip]

    async def join(self, conn, ip):
        code = (await asyncio.wait_for(conn.reader.readexactly(4), self.limits.hello_seconds)).decode("latin-1")
        now = time.monotonic()
        tries = [t for t in self.bad_codes.pop(ip, ()) if now - t <= 60]
        if tries:
            self.bad_codes[ip] = tries
        if len(tries) >= self.limits.bad_codes_per_minute:
            conn.writer.write(b"CDRB")
            await conn.writer.drain()
            return
        host = self.rooms.get(code)
        if host is None:
            self.bad_codes[ip] = tries + [now]
            conn.writer.write(b"CDRN")
            await conn.writer.drain()
            return
        del self.rooms[code]
        conn.peer, host.peer = host, conn
        conn.last_heard = host.last_heard = now
        self.games += 1
        print(f"game {self.games} started, {len(self.rooms)} rooms waiting", flush=True)
        conn.writer.write(b"CDRY" + bytes(host.held))
        host.held.clear()
        await conn.writer.drain()
        await self.pump(conn, None)

    async def pump(self, conn, room_ends):
        """Pass on what this connection sends until it, or the other player, stops."""
        limits = self.limits
        started = time.monotonic()
        try:
            while True:
                try:
                    data = await asyncio.wait_for(conn.reader.read(4096), limits.poll_seconds)
                except asyncio.TimeoutError:
                    data = None
                now = time.monotonic()
                if data == b"":
                    return
                if data is None:
                    if conn.peer is None:
                        if room_ends is not None and now > room_ends:
                            return
                    elif now - max(conn.last_heard, conn.peer.last_heard) > limits.idle_seconds:
                        return
                    if now - started > limits.room_seconds + limits.game_seconds:
                        return
                    continue
                conn.last_heard = now
                if not conn.within_rate(len(data)):
                    return
                if conn.peer is None:
                    conn.held += data
                    if len(conn.held) > limits.held_bytes:
                        return
                else:
                    conn.peer.writer.write(data)
                    await asyncio.wait_for(conn.peer.writer.drain(), limits.idle_seconds)
        finally:
            if conn.peer is not None:
                conn.peer.close()


async def serve(address, port):
    server = await asyncio.start_server(Relay().handle, address, port)
    print(f"relay waiting on port {port}", flush=True)
    async with server:
        await server.serve_forever()


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--port", type=int, default=PORT)
    parser.add_argument("--address", default=None, help="the address to listen on (default all)")
    args = parser.parse_args()
    try:
        asyncio.run(serve(args.address, args.port))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
