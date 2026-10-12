#!/usr/bin/env python3
"""Regenerate assets/flags/ — one small PNG flag per country.

The people-group cards show the country's flag beside its name. The flags are
bundled rather than fetched at runtime, so they appear instantly, work offline
and never need re-downloading.

Files are named by the ISO 3166-1 alpha-3 code the API sends in
`country_code.value` ("MYS.png"), so the app needs no code conversion. Each
flag is 20 px tall, with 2.0x/3.0x variants for high-density screens.

Sources: country codes from the world-countries package (ODbL), flag images
from flagcdn.com (public-domain flag artwork).

Usage:  python3 tool/fetch_flags.py
"""
import json
import sys
import time
import urllib.request
from pathlib import Path

COUNTRIES_URL = 'https://cdn.jsdelivr.net/npm/world-countries@5/countries.json'
FLAG_URL = 'https://flagcdn.com/h{height}/{iso2}.png'

# Display height 20 logical px: 1x, 2x and 3x variants.
VARIANTS = {'': 20, '2.0x/': 40, '3.0x/': 60}

# Codes the API uses that aren't ISO alpha-3. Kosovo has no official code;
# the API sends "KOS", world-countries calls it "UNK".
ALIASES = {'KOS': 'xk'}

OUT = Path(__file__).resolve().parent.parent / 'assets' / 'flags'


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={'User-Agent': 'doxa-fetch-flags'})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.read()
        except Exception:
            if attempt == 2:
                raise
            time.sleep(1 + attempt)
    raise AssertionError


def main() -> int:
    countries = json.loads(fetch(COUNTRIES_URL))
    codes = {c['cca3'].upper(): c['cca2'].lower() for c in countries}
    codes.update(ALIASES)
    for prefix in VARIANTS:
        (OUT / prefix).mkdir(parents=True, exist_ok=True)
    failed = []
    for iso3, iso2 in sorted(codes.items()):
        for prefix, height in VARIANTS.items():
            try:
                data = fetch(FLAG_URL.format(height=height, iso2=iso2))
            except Exception as e:
                failed.append(f'{iso3} ({iso2}) h{height}: {e}')
                continue
            if not data.startswith(b'\x89PNG'):
                failed.append(f'{iso3} ({iso2}) h{height}: not a PNG')
                continue
            (OUT / prefix / f'{iso3}.png').write_bytes(data)
    print(f'{len(codes)} countries written to {OUT}')
    for f in failed:
        print('FAILED', f, file=sys.stderr)
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
