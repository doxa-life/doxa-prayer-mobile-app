#!/usr/bin/env python3
"""Parity/hygiene checks across lib/l10n/*.arb. Exit 1 on any failure."""
import glob, json, re, sys, collections, unicodedata

ARB = 'lib/l10n/app_{}.arb'
# Every translation file, so a new language is checked without editing this list.
LOCALES = sorted(
    re.search(r'app_(\w+)\.arb$', p).group(1)
    for p in glob.glob(ARB.format('*'))
    if not p.endswith('app_en.arb')
)
fail = []

def load(code):
    raw = open(ARB.format(code), encoding='utf-8').read()
    d = json.loads(raw, object_pairs_hook=lambda p: _dupcheck(p, code))
    return raw, d

def _dupcheck(pairs, code):
    seen = collections.Counter(k for k, _ in pairs)
    for k, n in seen.items():
        if n > 1:
            fail.append(f'{code}: duplicate top-level key {k!r} ({n}x)')
    return dict(pairs)

def placeholders(s):
    """Argument names in an ICU message: '{name}' and '{name, plural, ...}'.

    Walks the message structure rather than pattern-matching braces, so the text
    of a plural/select branch ('=0{没有族群}', 'other{Keine}') is never mistaken
    for a placeholder, whatever the language or script.
    """
    found = set()
    _message(s, 0, found)
    return found

def _message(s, i, found):
    """Scans message text from i to its closing '}' (or the end); returns the
    index just past it. Each '{' in message text opens an argument."""
    while i < len(s):
        if s[i] == '}':
            return i + 1
        if s[i] == '{':
            i = _argument(s, i + 1, found)
        else:
            i += 1
    return i

def _argument(s, i, found):
    """Parses '{name}' or '{name, type, ...}' starting after the '{'."""
    end = i
    while end < len(s) and s[end] not in ',}':
        end += 1
    name = s[i:end].strip()
    if name:
        found.add(name)
    if end >= len(s) or s[end] == '}':
        return end + 1
    # '{name, type' or '{name, type, branches}'
    i = end + 1
    end = i
    while end < len(s) and s[end] not in ',}':
        end += 1
    kind = s[i:end].strip()
    if end >= len(s) or s[end] == '}':
        return end + 1
    i = end + 1
    if kind not in ('plural', 'select', 'selectordinal'):
        return _skip_group(s, i)
    # Branches: a selector ('=0', 'one', 'other', 'offset:1' is skipped) then a
    # '{message}' body, repeated until the argument's closing '}'.
    while i < len(s):
        if s[i] == '}':
            return i + 1
        if s[i] == '{':
            i = _message(s, i + 1, found)
        else:
            i += 1
    return i

def _skip_group(s, i):
    """Skips to just past the '}' closing the group we are inside."""
    depth = 1
    while i < len(s):
        if s[i] == '{': depth += 1
        elif s[i] == '}':
            depth -= 1
            if depth == 0: return i + 1
        i += 1
    return i

def braces_balanced(s):
    d = 0
    for ch in s:
        if ch == '{': d += 1
        elif ch == '}':
            d -= 1
            if d < 0: return False
    return d == 0

en_raw, en = load('en')
en_keys = {k for k in en if not k.startswith('@')}
print(f'en: {len(en_keys)} keys')

for code in LOCALES:
    raw, d = load(code)
    keys = {k for k in d if not k.startswith('@')}
    meta = {k[1:] for k in d if k.startswith('@') and not k.startswith('@@')}

    missing, extra = en_keys - keys, keys - en_keys
    if missing: fail.append(f'{code}: MISSING keys: {sorted(missing)}')
    if extra:   fail.append(f'{code}: EXTRA keys: {sorted(extra)}')

    no_meta = keys - meta
    if no_meta: fail.append(f'{code}: keys without @meta: {sorted(no_meta)}')
    orphan = meta - keys
    if orphan: fail.append(f'{code}: orphan @meta: {sorted(orphan)}')

    for k in sorted(keys & en_keys):
        ep = placeholders(en[k])
        lp = placeholders(d[k])
        if ep != lp:
            fail.append(f'{code}.{k}: placeholder mismatch en={sorted(ep)} {code}={sorted(lp)}')
        if not braces_balanced(d[k]):
            fail.append(f'{code}.{k}: unbalanced braces')

    if '�' in raw: fail.append(f'{code}: contains U+FFFD replacement char')
    if raw.startswith('﻿'): fail.append(f'{code}: has BOM')
    if '\r' in raw: fail.append(f'{code}: has CRLF')
    if '\t' in raw: fail.append(f'{code}: has tabs')

    doxa_bad = [k for k, v in d.items() if isinstance(v, str) and 'دوكسا' in v]
    if doxa_bad: fail.append(f'{code}: Doxa transliterated in {doxa_bad}')

    print(f'{code}: {len(keys)} keys, {len(meta)} @meta  '
          f'{"OK" if not missing and not extra and not no_meta else "PROBLEM"}')

print()
if fail:
    print(f'FAILED ({len(fail)}):')
    for f in fail: print('  -', f)
    sys.exit(1)
print('ALL CHECKS PASSED')
