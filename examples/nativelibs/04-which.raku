#!/usr/bin/env rakupp
# NativeLibs — The one thing to know
# https://raku.online/modules/nativelibs/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install NativeLibs
#     rakupp 04-which.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeLibs;

say 'the tie between two same-version distributions is broken differently:';
say '';
say '  Raku++ loads zef:raku-community-modules (lib/NativeLibs.rakumod)';
say '  Rakudo loads github:salortiz            (lib/NativeLibs.pm6)';
say '';
say 'the two sources are near-identical, mostly reformatting. The one real';
say 'code difference is a signature:';
say '';
say '  community-modules : multi cannon-name(Str:D $libname, Version $version?)';
say '  salortiz          : multi cannon-name(Str $libname, Version $version = Version)';
say '';
say 'so the first undefined library name you pass behaves differently.';
say 'Pin the auth in your `use` if you care which one you get:';
say '  use NativeLibs:auth<zef:raku-community-modules>;';
say '';
say 'and note the module re-exports the whole of NativeCall, so';
say '`use NativeLibs` alone gives you is native, Pointer, CArray and';
say 'nativecast.';

# Output:
#     the tie between two same-version distributions is broken differently:
#     
#       Raku++ loads zef:raku-community-modules (lib/NativeLibs.rakumod)
#       Rakudo loads github:salortiz            (lib/NativeLibs.pm6)
#     
#     the two sources are near-identical, mostly reformatting. The one real
#     code difference is a signature:
#     
#       community-modules : multi cannon-name(Str:D $libname, Version $version?)
#       salortiz          : multi cannon-name(Str $libname, Version $version = Version)
#     
#     so the first undefined library name you pass behaves differently.
#     Pin the auth in your `use` if you care which one you get:
#       use NativeLibs:auth<zef:raku-community-modules>;
#     
#     and note the module re-exports the whole of NativeCall, so
#     `use NativeLibs` alone gives you is native, Pointer, CArray and
#     nativecast.
