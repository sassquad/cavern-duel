#!/usr/bin/env python3
"""Tests for tools/relay.py: python3 tools/test_relay.py"""
import asyncio
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import relay  # noqa: E402


class Quick(relay.Limits):
    hello_seconds = 0.3
    room_seconds = 0.6
    idle_seconds = 0.5
    poll_seconds = 0.05


class RelayTest(unittest.IsolatedAsyncioTestCase):
    limits = Quick

    async def asyncSetUp(self):
        self.relay = relay.Relay(self.limits)
        self.server = await asyncio.start_server(self.relay.handle, "127.0.0.1", 0)
        self.port = self.server.sockets[0].getsockname()[1]
        self.opened = []

    async def asyncTearDown(self):
        for _, writer in self.opened:
            writer.close()
        self.server.close()
        await self.server.wait_closed()

    async def connect(self):
        pair = await asyncio.open_connection("127.0.0.1", self.port)
        self.opened.append(pair)
        return pair

    async def read(self, reader, n):
        return await asyncio.wait_for(reader.readexactly(n), 2)

    async def closed(self, reader):
        """True if the relay closes this connection, after any data it's sending."""
        return await asyncio.wait_for(reader.read(), 3) is not None

    async def host(self):
        r, w = await self.connect()
        w.write(b"CDRH\x01")
        self.assertEqual(await self.read(r, 4), b"CDRC")
        return r, w, (await self.read(r, 4)).decode()

    async def join(self, code):
        r, w = await self.connect()
        w.write(b"CDRJ\x01" + code.encode())
        return r, w, await self.read(r, 4)

    async def test_code_uses_clear_letters(self):
        _, _, code = await self.host()
        self.assertEqual(len(code), 4)
        self.assertTrue(set(code) <= set(relay.LETTERS))
        self.assertFalse(set(code) & set("IO"))

    async def test_pairs_and_passes_both_ways(self):
        hr, hw, code = await self.host()
        jr, jw, answer = await self.join(code)
        self.assertEqual(answer, b"CDRY")
        hw.write(b"from host")
        self.assertEqual(await self.read(jr, 9), b"from host")
        jw.write(b"from join")
        self.assertEqual(await self.read(hr, 9), b"from join")

    async def test_what_the_host_sent_first_arrives_in_order(self):
        hr, hw, code = await self.host()
        hw.write(b"CDH\x03seed")
        await hw.drain()
        await asyncio.sleep(0.1)
        jr, jw, answer = await self.join(code)
        self.assertEqual(answer, b"CDRY")
        hw.write(b"after")
        self.assertEqual(await self.read(jr, 13), b"CDH\x03seedafter")

    async def test_wrong_code(self):
        _, _, code = await self.host()
        wrong = "AAAA" if code != "AAAA" else "BBBB"
        r, _, answer = await self.join(wrong)
        self.assertEqual(answer, b"CDRN")
        self.assertTrue(await self.closed(r))

    async def test_a_room_takes_one_guest(self):
        _, _, code = await self.host()
        _, _, first = await self.join(code)
        _, _, second = await self.join(code)
        self.assertEqual((first, second), (b"CDRY", b"CDRN"))

    async def test_room_goes_when_host_leaves(self):
        _, hw, code = await self.host()
        hw.close()
        await asyncio.sleep(0.2)
        self.assertEqual(self.relay.rooms, {})
        _, _, answer = await self.join(code)
        self.assertEqual(answer, b"CDRN")

    async def test_room_expires(self):
        hr, _, code = await self.host()
        self.assertTrue(await self.closed(hr))
        self.assertEqual(self.relay.rooms, {})

    async def test_leaving_ends_the_game_for_both(self):
        hr, _, code = await self.host()
        _, jw, _ = await self.join(code)
        jw.close()
        self.assertTrue(await self.closed(hr))

    async def test_idle_game_is_dropped(self):
        hr, _, code = await self.host()
        jr, _, _ = await self.join(code)
        self.assertTrue(await self.closed(hr))
        self.assertTrue(await self.closed(jr))

    async def test_active_game_is_kept(self):
        hr, hw, code = await self.host()
        jr, jw, _ = await self.join(code)
        for _ in range(12):  # longer than the idle limit
            hw.write(b"ab")
            jw.write(b"cd")
            await asyncio.sleep(0.1)
            await self.read(jr, 2)
            await self.read(hr, 2)

    async def test_silent_connection_is_dropped(self):
        r, _ = await self.connect()
        self.assertTrue(await self.closed(r))
        await asyncio.sleep(0.05)
        self.assertEqual(self.relay.open_connections, 0)

    async def test_not_a_game_is_dropped(self):
        r, w = await self.connect()
        w.write(b"GET / HTTP/1.1\r\n")
        self.assertEqual(await asyncio.wait_for(r.read(), 2), b"")

    async def test_other_version_is_told(self):
        r, w = await self.connect()
        w.write(b"CDRH\x63")
        self.assertEqual(await self.read(r, 4), b"CDRV")

    async def test_guessing_codes_is_limited(self):
        answers = []
        for _ in range(relay.Limits.bad_codes_per_minute + 1):
            r, w = await self.connect()
            w.write(b"CDRJ\x01QQQQ")
            answers.append(await self.read(r, 4))
            w.close()
            await asyncio.sleep(0.01)
        self.assertEqual(answers[-2:], [b"CDRN", b"CDRB"])

    async def test_rooms_per_address_are_limited(self):
        for _ in range(relay.Limits.rooms_per_ip):
            await self.host()
        r, w = await self.connect()
        w.write(b"CDRH\x01")
        self.assertEqual(await self.read(r, 4), b"CDRB")

    async def test_connections_per_address_are_limited(self):
        for _ in range(relay.Limits.connections_per_ip):
            await self.connect()
        r, _ = await self.connect()
        self.assertEqual(await self.read(r, 4), b"CDRB")

    async def test_a_host_cant_store_much_before_a_guest_comes(self):
        hr, hw, _ = await self.host()
        hw.write(bytes(relay.Limits.held_bytes + 1))
        self.assertTrue(await self.closed(hr))

    async def test_a_cave_fits_the_burst_but_flooding_is_dropped(self):
        hr, hw, code = await self.host()
        jr, jw, _ = await self.join(code)
        cave = bytes(16404)
        hw.write(cave)
        self.assertEqual(await self.read(jr, len(cave)), cave)
        hw.write(bytes(relay.Limits.burst_bytes))
        await asyncio.wait_for(jr.read(), 3)
        self.assertEqual(await asyncio.wait_for(jr.read(), 3), b"")

    async def test_counts_return_to_zero(self):
        _, hw, code = await self.host()
        _, jw, _ = await self.join(code)
        hw.close()
        jw.close()
        await asyncio.sleep(0.2)
        self.assertEqual(self.relay.open_connections, 0)
        self.assertEqual(dict(self.relay.per_ip), {})
        self.assertEqual(dict(self.relay.rooms_per_ip), {})


if __name__ == "__main__":
    unittest.main()
