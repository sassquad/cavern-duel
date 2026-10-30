#!/usr/bin/env python3
"""Check BBC BASIC programs for mistakes that only show up when run.

    lint.py <program.bas> [library.bas ...]

Reports:
  - PROC/FN calls with no DEF in the program or its libraries (only a
    warning when the call is in a routine that is never called)
  - user_ routines a library calls that the program doesn't define
  - routines defined more than once (BASIC silently uses the first; only a
    warning when both copies are identical)
  - global variables shared between the program and a library, which
    can corrupt each other (a name used as a parameter or LOCAL in every
    routine that sets it is not global)

Exits 1 if any errors are reported; warnings don't count.
"""
import re
import sys

ROUTINE = re.compile(r'\b((?:PROC|FN)[A-Za-z_][A-Za-z0-9_`]*)')
VAR = r'[A-Za-z_`][A-Za-z0-9_`]*[%$]?'


def code_lines(path):
    """Yield (line number, code) with strings, REMs and DATA removed."""
    for raw in open(path, encoding="utf-8").read().splitlines():
        m = re.match(r'(\d+) ?(.*)', raw)
        if not m:
            continue
        number, text = int(m.group(1)), m.group(2)
        text = re.sub(r'"[^"]*"?', '""', text)
        text = re.split(r'\b(?:REM|DATA)\b', text)[0]
        yield number, text


def routines(path):
    """Map each DEF name to (line, params, locals, assigned names)."""
    found, dups, current = {}, [], None
    for number, text in code_lines(path):
        for stmt in text.split(":"):
            d = re.match(r'\s*DEF\s*((?:PROC|FN)[A-Za-z_][A-Za-z0-9_`]*)\s*(?:\(([^)]*)\))?', stmt)
            if d:
                name = d.group(1)
                params = {re.sub(r'^\s*RETURN\s+', '', p).strip().split("(")[0]
                          for p in (d.group(2) or "").split(",") if p.strip()}
                if name in found:
                    dups.append((name, found[name][0], number))
                    current = None
                    continue
                current = found[name] = (number, params, set(), set())
                continue
            if current is None:
                continue
            for m in re.finditer(r'\bLOCAL\s+(.*)', stmt):
                for v in m.group(1).split(","):
                    current[2].add(v.strip().split("(")[0])
            for m in re.finditer(rf'(?:^|\bTHEN\b|\bELSE\b)\s*(?:LET\s+)?({VAR})\s*(?:\([^)]*\))?\s*(?:[-+]?=)', stmt):
                current[3].add(m.group(1))
            for m in re.finditer(rf'\bDIM\s+(.*)', stmt):
                for v in re.findall(rf'({VAR})\s*(?:\(|\s+[^,]*)', m.group(1)):
                    current[3].add(v)
            for m in re.finditer(rf'\bFOR\s+({VAR})\s*=', stmt):
                current[3].add(m.group(1))
            for m in re.finditer(r'\bTO\s*((?:\s*,?\s*' + VAR + r')+)\s*(?:;|$)', stmt):
                for v in re.findall(VAR, m.group(1)):
                    current[3].add(v)
    return found, dups


def owned_lines(path):
    """Yield (line number, code, routine the line belongs to or None)."""
    owner = None
    for number, text in code_lines(path):
        d = re.match(r'\s*DEF\s*((?:PROC|FN)[A-Za-z_][A-Za-z0-9_`]*)', text)
        if d:
            owner = (d.group(1), number)
        yield number, text, owner


def bodies(path):
    """Map (routine, DEF line) to its code, for comparing duplicates."""
    out = {}
    for number, text, owner in owned_lines(path):
        if owner and text.strip() not in ("", ":"):
            out.setdefault(owner, []).append(text.strip())
    return out


def calls(path):
    """List (called routine, line, calling routine or None)."""
    out = []
    for number, text, owner in owned_lines(path):
        for m in ROUTINE.finditer(text):
            if re.search(r'DEF\s*$', text[:m.start()]):
                continue
            out.append((m.group(1), number, owner[0] if owner else None))
    return out


def live_routines(path):
    """Routines reachable from the main program or from user_ hooks."""
    graph, roots = {}, set()
    for name, _, caller in calls(path):
        if caller is None:
            roots.add(name)
        else:
            graph.setdefault(caller, set()).add(name)
    roots |= {n for n in routines(path)[0] if re.match(r'(PROC|FN)user_', n)}
    live, todo = set(), list(roots)
    while todo:
        n = todo.pop()
        if n not in live:
            live.add(n)
            todo.extend(graph.get(n, ()))
    return live


def globals_of(found, top_level):
    names = set(top_level)
    for _, params, local, assigned in found.values():
        names |= assigned - params - local
    return {n for n in names if not n.startswith(("PROC", "FN")) and n not in ("TIME", "PTR", "PAGE", "LOMEM", "HIMEM")}


def top_level_assigned(path, found):
    """Names assigned outside any routine (the program's main code)."""
    first_def = min((line for line, *_ in found.values()), default=10**9)
    names = set()
    for number, text in code_lines(path):
        if number >= first_def:
            break
        for m in re.finditer(rf'(?:^|:)\s*(?:LET\s+)?({VAR})\s*=', text):
            names.add(m.group(1))
    return names


def main(argv):
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    program, libs = argv[1], argv[2:]
    problems = 0
    prog_defs, prog_dups = routines(program)
    all_defs = dict(prog_defs)
    lib_info = []
    for lib in libs:
        defs, dups = routines(lib)
        lib_info.append((lib, defs))
        for name, first, again in dups:
            print(f"{lib}:{again}: warning: {name} already defined at line {first}")
        all_defs.update({k: v for k, v in defs.items() if k not in all_defs})
    code = bodies(program)
    for name, first, again in prog_dups:
        if code.get((name, first)) == code.get((name, again)):
            print(f"{program}:{again}: warning: {name} is defined twice (identically, also at line {first})")
        else:
            print(f"{program}:{again}: error: {name} already defined at line {first}; BASIC uses the first")
            problems += 1
    live = live_routines(program)
    reported = set()
    for name, line, caller in calls(program):
        if name in all_defs or name in reported:
            continue
        reported.add(name)
        if caller is None or caller in live:
            print(f"{program}:{line}: error: {name} is called but never defined")
            problems += 1
        else:
            print(f"{program}:{line}: warning: {name} is never defined, but {caller} is never called")
    for lib, defs in lib_info:
        wanted = {}
        for name, line, _ in calls(lib):
            if re.match(r'(PROC|FN)user_', name):
                wanted.setdefault(name, line)
        for name, line in sorted(wanted.items(), key=lambda kv: kv[1]):
            if name not in prog_defs:
                print(f"{program}: error: {lib} calls {name} (line {line}) but the program doesn't define it")
                problems += 1
        shared = globals_of(prog_defs, top_level_assigned(program, prog_defs)) & globals_of(defs, set())
        for name in sorted(shared):
            print(f"{program}: error: global {name} is also used as a global by {lib}")
            problems += 1
    if not problems:
        print(f"ok    {program}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
