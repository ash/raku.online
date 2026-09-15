#!/usr/bin/env rakupp
# NativeLibs — Probing for the right ABI version
# https://raku.online/modules/nativelibs/#probing-for-the-right-abi-version
#
# Install what it needs, then run it:
#     rakupp install NativeLibs
#     rakupp 03-searcher.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeLibs;

say 'try-versions opens each candidate in turn and returns the first whose';
say 'name resolves the well-known symbol you name:';
say '  try-versions("m", "cos")       = ',
    NativeLibs::Searcher.try-versions('m', 'cos').raku;
say '  try-versions("m", "cos", 6, 5) = ',
    NativeLibs::Searcher.try-versions('m', 'cos', 6, 5).raku;
say '  try-versions("zzznope", "cos") = ',
    NativeLibs::Searcher.try-versions('zzznope', 'cos').defined
        ?? 'a name' !! 'undefined';
say '';
say 'at-runtime wraps that in a Block you can hand to `is native`:';
my &name = NativeLibs::Searcher.at-runtime('m', 'cos');
say '  at-runtime("m", "cos").()      = ', name().raku;
say '';
say 'note what happens when nothing is found: at-runtime returns the BARE';
say 'library name rather than failing, deliberately, so that NativeCall';
say 'dies later with its own message:';
my &nope = NativeLibs::Searcher.at-runtime('zzznope', 'cos');
say '  at-runtime("zzznope", "cos").() = ', nope().raku;
say '';
say 'so your `is native(…)` will fail at the first CALL, not at load, and';
say 'the message will be NativeCall`s rather than "cannot locate library".';

# Output:
#     try-versions opens each candidate in turn and returns the first whose
#     name resolves the well-known symbol you name:
#       try-versions("m", "cos")       = "libm.dylib"
#       try-versions("m", "cos", 6, 5) = Any
#       try-versions("zzznope", "cos") = undefined
#     
#     at-runtime wraps that in a Block you can hand to `is native`:
#       at-runtime("m", "cos").()      = "libm.dylib"
#     
#     note what happens when nothing is found: at-runtime returns the BARE
#     library name rather than failing, deliberately, so that NativeCall
#     dies later with its own message:
#       at-runtime("zzznope", "cos").() = "zzznope"
#     
#     so your `is native(…)` will fail at the first CALL, not at load, and
#     the message will be NativeCall`s rather than "cannot locate library".
