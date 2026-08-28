#!/usr/bin/env rakupp
# App::Rakus — `Content-Type` by extension — or honestly not
# https://raku.online/modules/app-rakus/#content-type-by-extension-or-honestly-not
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 03-mime.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use App::Rakus;

say mime-for($_) for <page.html app.wasm chart.svg data.json notes.md movie.mkv>;

# Output:
#     text/html; charset=utf-8
#     application/wasm
#     image/svg+xml
#     application/json; charset=utf-8
#     text/markdown; charset=utf-8
#     application/octet-stream
