#!/usr/bin/env python3
"""Tokenise and detokenise RISC OS BBC BASIC V programs.

Text format: one program line per text line, as "<number> <body>". The
single space after the number is a separator, so any further spaces are kept
as part of the line. A line with no number is given the previous number + 1.

Bytes are mapped to text as Latin-1, so top-bit characters inside strings
and REMs survive a round trip.

Usage:
    bbcbasic.py tokenise   <in.bas> <out,ffb>
    bbcbasic.py detokenise <in,ffb> <out.bas>
"""
import re
import sys

# Flags, as in Acorn's keyword table
C = 0x01  # conditional: not a keyword if followed by an identifier character
M = 0x02  # takes arguments (documentation only: every keyword without S
          # leaves the tokeniser mid-statement)
S = 0x04  # leaves the tokeniser at start of statement
F = 0x08  # FN/PROC: following name is not tokenised
L = 0x10  # line numbers may follow (GOTO 100)
R = 0x20  # rest of line is literal (REM, DATA)
P = 0x40  # pseudo-variable: token + 0x40 when at start of statement

# (keyword, token bytes, flags)
KEYWORDS = [
    ("AND", b"\x80", 0), ("DIV", b"\x81", 0), ("EOR", b"\x82", 0),
    ("MOD", b"\x83", 0), ("OR", b"\x84", 0), ("ERROR", b"\x85", S),
    ("LINE", b"\x86", 0), ("OFF", b"\x87", 0), ("STEP", b"\x88", 0),
    ("SPC", b"\x89", 0), ("TAB(", b"\x8a", 0), ("ELSE", b"\x8b", L | S),
    ("THEN", b"\x8c", L | S), ("OPENIN", b"\x8e", 0),
    ("PTR", b"\x8f", P | M | C), ("PAGE", b"\x90", P | M | C),
    ("TIME", b"\x91", P | M | C), ("LOMEM", b"\x92", P | M | C),
    ("HIMEM", b"\x93", P | M | C), ("ABS", b"\x94", 0), ("ACS", b"\x95", 0),
    ("ADVAL", b"\x96", 0), ("ASC", b"\x97", 0), ("ASN", b"\x98", 0),
    ("ATN", b"\x99", 0), ("BGET", b"\x9a", C), ("COS", b"\x9b", 0),
    ("COUNT", b"\x9c", C), ("DEG", b"\x9d", 0), ("ERL", b"\x9e", C),
    ("ERR", b"\x9f", C), ("EVAL", b"\xa0", 0), ("EXP", b"\xa1", 0),
    ("EXT", b"\xa2", C), ("FALSE", b"\xa3", C), ("FN", b"\xa4", F),
    ("GET", b"\xa5", 0), ("INKEY", b"\xa6", 0), ("INSTR(", b"\xa7", 0),
    ("INT", b"\xa8", 0), ("LEN", b"\xa9", 0), ("LN", b"\xaa", 0),
    ("LOG", b"\xab", 0), ("NOT", b"\xac", 0), ("OPENUP", b"\xad", 0),
    ("OPENOUT", b"\xae", 0), ("PI", b"\xaf", C), ("POINT(", b"\xb0", 0),
    ("POS", b"\xb1", C), ("RAD", b"\xb2", 0), ("RND", b"\xb3", C),
    ("SGN", b"\xb4", 0), ("SIN", b"\xb5", 0), ("SQR", b"\xb6", 0),
    ("TAN", b"\xb7", 0), ("TO", b"\xb8", 0), ("TRUE", b"\xb9", C),
    ("USR", b"\xba", 0), ("VAL", b"\xbb", 0), ("VPOS", b"\xbc", C),
    ("CHR$", b"\xbd", 0), ("GET$", b"\xbe", 0), ("INKEY$", b"\xbf", 0),
    ("LEFT$(", b"\xc0", 0), ("MID$(", b"\xc1", 0), ("RIGHT$(", b"\xc2", 0),
    ("STR$", b"\xc3", 0), ("STRING$(", b"\xc4", 0), ("EOF", b"\xc5", C),
    ("WHEN", b"\xc9", M), ("OF", b"\xca", S), ("ENDCASE", b"\xcb", C),
    ("ENDIF", b"\xcd", C), ("ENDWHILE", b"\xce", C),
    ("SOUND", b"\xd4", M), ("BPUT", b"\xd5", M | C), ("CALL", b"\xd6", M),
    ("CHAIN", b"\xd7", M), ("CLEAR", b"\xd8", C), ("CLOSE", b"\xd9", M | C),
    ("CLG", b"\xda", C), ("CLS", b"\xdb", C), ("DATA", b"\xdc", R),
    ("DEF", b"\xdd", 0), ("DIM", b"\xde", M), ("DRAW", b"\xdf", M),
    ("END", b"\xe0", C), ("ENDPROC", b"\xe1", C), ("ENVELOPE", b"\xe2", M),
    ("FOR", b"\xe3", M), ("GOSUB", b"\xe4", L | M), ("GOTO", b"\xe5", L | M),
    ("GCOL", b"\xe6", M), ("IF", b"\xe7", M), ("INPUT", b"\xe8", M),
    ("LET", b"\xe9", S), ("LOCAL", b"\xea", M), ("MODE", b"\xeb", M),
    ("MOVE", b"\xec", M), ("NEXT", b"\xed", M), ("ON", b"\xee", M),
    ("VDU", b"\xef", M), ("PLOT", b"\xf0", M), ("PRINT", b"\xf1", M),
    ("PROC", b"\xf2", F | M), ("READ", b"\xf3", M), ("REM", b"\xf4", R),
    ("REPEAT", b"\xf5", S), ("REPORT", b"\xf6", C), ("RESTORE", b"\xf7", L | M),
    ("RETURN", b"\xf8", C), ("RUN", b"\xf9", C), ("STOP", b"\xfa", C),
    ("COLOUR", b"\xfb", M), ("TRACE", b"\xfc", L | M), ("UNTIL", b"\xfd", M),
    ("WIDTH", b"\xfe", M), ("OSCLI", b"\xff", M), ("OTHERWISE", b"\x7f", S),
    # Two-byte tokens
    ("SUM", b"\xc6\x8e", 0), ("BEAT", b"\xc6\x8f", 0),
    ("APPEND", b"\xc7\x8e", M), ("AUTO", b"\xc7\x8f", L),
    ("CRUNCH", b"\xc7\x90", M), ("DELETE", b"\xc7\x91", L),
    ("EDIT", b"\xc7\x92", M), ("HELP", b"\xc7\x93", M),
    ("LIST", b"\xc7\x94", L), ("LOAD", b"\xc7\x95", M),
    ("LVAR", b"\xc7\x96", M), ("NEW", b"\xc7\x97", C),
    ("OLD", b"\xc7\x98", C), ("RENUMBER", b"\xc7\x99", L),
    ("SAVE", b"\xc7\x9a", M), ("TEXTLOAD", b"\xc7\x9b", M),
    ("TEXTSAVE", b"\xc7\x9c", M), ("TWIN", b"\xc7\x9d", M),
    ("TWINO", b"\xc7\x9e", M),
    ("CASE", b"\xc8\x8e", M), ("CIRCLE", b"\xc8\x8f", M),
    ("FILL", b"\xc8\x90", M), ("ORIGIN", b"\xc8\x91", M),
    ("POINT", b"\xc8\x92", M), ("RECTANGLE", b"\xc8\x93", M),
    ("SWAP", b"\xc8\x94", M), ("WHILE", b"\xc8\x95", M),
    ("WAIT", b"\xc8\x96", M), ("MOUSE", b"\xc8\x97", M),
    ("QUIT", b"\xc8\x98", M), ("SYS", b"\xc8\x99", M),
    ("INSTALL", b"\xc8\x9a", M), ("LIBRARY", b"\xc8\x9b", M),
    ("TINT", b"\xc8\x9c", M), ("ELLIPSE", b"\xc8\x9d", M),
    ("BEATS", b"\xc8\x9e", M), ("TEMPO", b"\xc8\x9f", M),
    ("VOICES", b"\xc8\xa0", M), ("VOICE", b"\xc8\xa1", M),
    ("STEREO", b"\xc8\xa2", M), ("OVERLAY", b"\xc8\xa3", M),
    ("MANDEL", b"\xc8\xa4", M), ("PRIVATE", b"\xc8\xa5", M),
    ("EXIT", b"\xc8\xa6", M),
]

# Longest first, so ENDPROC wins over END
_BY_LENGTH = sorted(KEYWORDS, key=lambda k: -len(k[0]))

# Token bytes -> keyword, including the start-of-statement forms
DETOKENS = {tok: name for name, tok, _ in KEYWORDS}
DETOKENS[b"\xc7\x9f"] = "INSTALL"
DETOKENS[b"\xcc"] = "ELSE"
for _name, _tok, _flags in KEYWORDS:
    if _flags & P:
        DETOKENS[bytes([_tok[0] + 0x40])] = _name

LINE_NUMBER_TOKEN = 0x8D
IDENT = re.compile(r"[A-Za-z0-9_`]")


class BasicError(Exception):
    pass


def encode_line_number(n):
    lo, hi = n & 0xFF, n >> 8
    b1 = (((lo & 0xC0) >> 2) | ((hi & 0xC0) >> 4)) ^ 0x54
    return bytes([LINE_NUMBER_TOKEN, b1, (lo & 0x3F) | 0x40, (hi & 0x3F) | 0x40])


def decode_line_number(b1, b2, b3):
    lo = b2 ^ ((b1 << 2) & 0xC0)
    hi = b3 ^ ((b1 << 4) & 0xC0)
    return lo + hi * 256


def _match_keyword(text, i):
    for name, tok, flags in _BY_LENGTH:
        if text.startswith(name, i):
            after = i + len(name)
            if flags & C and after < len(text) and IDENT.match(text[after]):
                continue
            return name, tok, flags
    return None


def tokenise_line(text):
    """Tokenise the body of one line (without its line number)."""
    out = bytearray()
    i, n = 0, len(text)
    start = True        # at start of statement
    line_numbers = False
    while i < n:
        ch = text[i]

        if line_numbers:
            if ch in " ,":
                out.append(ord(ch))
                i += 1
                continue
            if ch.isdigit():
                j = i
                while j < n and text[j].isdigit():
                    j += 1
                out += encode_line_number(int(text[i:j]))
                i = j
                continue
            line_numbers = False

        if ch == '"':
            j = text.find('"', i + 1)
            j = n if j < 0 else j + 1
            out += text[i:j].encode("latin-1")
            i = j
            start = False
        elif ch == ":":
            out.append(0x3A)
            i += 1
            start = True
        elif ch == "*" and start:
            out += text[i:].encode("latin-1")
            break
        elif ch == "&":
            j = i + 1
            while j < n and text[j] in "0123456789ABCDEFabcdef":
                j += 1
            out += text[i:j].encode("latin-1")
            i = j
            start = False
        elif ch.isdigit() or ch == ".":
            j = i + 1
            while j < n and (text[j].isdigit() or text[j] == "."):
                j += 1
            out += text[i:j].encode("latin-1")
            i = j
        elif IDENT.match(ch):
            kw = _match_keyword(text, i) if "A" <= ch <= "Z" else None
            if kw is None:
                j = i
                while j < n and IDENT.match(text[j]):
                    j += 1
                out += text[i:j].encode("latin-1")
                i = j
                start = False
                continue
            name, tok, flags = kw
            if name == "ELSE" and not text[:i].strip():
                tok = b"\xcc"
            elif flags & P and start:
                tok = bytes([tok[0] + 0x40])
            out += tok
            i += len(name)
            if flags & R:
                out += text[i:].encode("latin-1")
                break
            if flags & F:
                j = i
                while j < n and IDENT.match(text[j]):
                    j += 1
                out += text[i:j].encode("latin-1")
                i = j
            start = bool(flags & S)
            if flags & L:
                line_numbers = True
        else:
            out += ch.encode("latin-1")
            i += 1
    return bytes(out)


def tokenise(source):
    """Turn program text into a tokenised BASIC file."""
    out = bytearray()
    previous = -1
    lines = source.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    for lineno, raw in enumerate(lines, 1):
        raw = raw.rstrip("\r")
        m = re.match(r"(\d+) ?", raw)
        if m:
            number = int(m.group(1))
            body = raw[m.end():]
        else:
            number = previous + 1
            body = raw
        if number <= previous:
            raise BasicError(f"text line {lineno}: line number {number} "
                             f"is not greater than {previous}")
        if number > 65279:
            raise BasicError(f"text line {lineno}: line number {number} too big")
        try:
            tokens = tokenise_line(body)
        except UnicodeEncodeError as e:
            raise BasicError(f"text line {lineno}: character not in Latin-1: "
                             f"{body[e.start]!r}")
        if len(tokens) > 251:
            raise BasicError(f"text line {lineno} (BASIC line {number}) "
                             f"is too long once tokenised")
        out += bytes([0x0D, number >> 8, number & 0xFF, len(tokens) + 4])
        out += tokens
        previous = number
    out += b"\x0d\xff"
    return bytes(out)


def detokenise(data):
    """Turn a tokenised BASIC file into program text."""
    lines = []
    i = 0
    while True:
        if i >= len(data) or data[i] != 0x0D:
            raise BasicError(f"offset {i}: not a BBC BASIC program")
        if data[i + 1] == 0xFF:
            break
        number = data[i + 1] * 256 + data[i + 2]
        length = data[i + 3]
        body = data[i + 4:i + length]
        i += length
        out = []
        j = 0
        quoted = literal = False
        while j < len(body):
            c = body[j]
            if quoted or literal or (c < 0x80 and c != 0x7F):
                if c == 0x22:
                    quoted = not quoted
                out.append(chr(c))
                j += 1
            elif c == LINE_NUMBER_TOKEN:
                out.append(str(decode_line_number(*body[j + 1:j + 4])))
                j += 4
            elif c in (0xC6, 0xC7, 0xC8):
                tok = body[j:j + 2]
                if tok not in DETOKENS:
                    raise BasicError(f"line {number}: unknown token {tok.hex()}")
                out.append(DETOKENS[tok])
                j += 2
            else:
                tok = bytes([c])
                if tok not in DETOKENS:
                    raise BasicError(f"line {number}: unknown token {tok.hex()}")
                out.append(DETOKENS[tok])
                literal = c in (0xF4, 0xDC)  # REM, DATA
                j += 1
        text = "".join(out)
        lines.append(f"{number} {text}" if text else str(number))
    return "\n".join(lines) + "\n"


def main(argv):
    if len(argv) != 4 or argv[1] not in ("tokenise", "detokenise"):
        print(__doc__, file=sys.stderr)
        return 2
    mode, src, dst = argv[1:]
    try:
        if mode == "tokenise":
            with open(src, encoding="utf-8") as f:
                data = tokenise(f.read())
            with open(dst, "wb") as f:
                f.write(data)
        else:
            with open(src, "rb") as f:
                text = detokenise(f.read())
            with open(dst, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
    except BasicError as e:
        print(f"{src}: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
