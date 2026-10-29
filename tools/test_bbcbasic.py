#!/usr/bin/env python3
"""Unit tests for bbcbasic.py: python3 tools/test_bbcbasic.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bbcbasic import BasicError, detokenise, tokenise, tokenise_line  # noqa: E402


class TokeniseLine(unittest.TestCase):
    def test_keywords(self):
        self.assertEqual(tokenise_line('PRINT "HI"'), b'\xf1 "HI"')

    def test_strings_are_literal(self):
        self.assertEqual(tokenise_line('PRINT "PRINT"'), b'\xf1 "PRINT"')

    def test_rem_is_literal(self):
        self.assertEqual(tokenise_line("REM PRINT"), b"\xf4 PRINT")

    def test_line_numbers(self):
        self.assertEqual(tokenise_line("GOTO 100"), b"\xe5 \x8d\x44\x64\x40")

    def test_pseudo_variable_forms(self):
        self.assertEqual(tokenise_line("TIME=0"), b"\xd1=0")
        self.assertEqual(tokenise_line("T%=TIME"), b"T%=\x91")
        self.assertEqual(tokenise_line("END=HIMEM"), b"\xe0=\x93")

    def test_conditional_keywords(self):
        self.assertEqual(tokenise_line("TIMER=1"), b"TIMER=1")
        self.assertEqual(tokenise_line("PRINTER"), b"\xf1ER")

    def test_proc_name_not_tokenised(self):
        self.assertEqual(tokenise_line("PROCPRINT"), b"\xf2PRINT")

    def test_else_at_line_start(self):
        self.assertEqual(tokenise_line("  ELSE"), b"  \xcc")
        self.assertEqual(tokenise_line("IF A ELSE B"), b"\xe7 A \x8b B")

    def test_two_byte_tokens(self):
        self.assertEqual(tokenise_line('SYS "OS_Byte"'), b'\xc8\x99 "OS_Byte"')


class Program(unittest.TestCase):
    def test_round_trip(self):
        text = '10 PRINT "Hello £"\n20 GOTO 10\n30\n'
        self.assertEqual(detokenise(tokenise(text)), text)

    def test_auto_numbering(self):
        self.assertEqual(detokenise(tokenise("10 A=1\nB=2\n")), "10 A=1\n11 B=2\n")

    def test_line_order(self):
        with self.assertRaises(BasicError):
            tokenise("20 A=1\n10 B=2\n")


if __name__ == "__main__":
    unittest.main()
