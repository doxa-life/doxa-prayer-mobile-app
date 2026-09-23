#!/usr/bin/env python3
"""Parity/hygiene checks across lib/l10n/*.arb. Exit 1 on any failure."""
import glob, json, re, sys, collections, unicodedata

ARB = 'lib/l10n/app_{}.arb'
LOCALES = sorted(re.fullmatch(r'lib/l10n/app_(\w+)\.arb', p).group(1)
                 for p in glob.glob(ARB.format("*")))
LOCALES.remove('en')
# A real ICU placeholder/arg is '{name}' or '{name,' — not a branch body like '=0{No ...}'
# ASCII-only: placeholder names are Dart identifiers, and a Han branch body has no spaces.
PH = re.compile(r'\{(\w+)\s*[,}]', re.ASCII)
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
    return set(PH.findall(s))

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
        kw = {'plural','select','zero','one','two','few','many','other'}
        ep = placeholders(en[k]) - kw
        lp = placeholders(d[k]) - kw
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
