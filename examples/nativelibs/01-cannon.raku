#!/usr/bin/env rakupp
# NativeLibs — Naming a library
# https://raku.online/modules/nativelibs/#naming-a-library
#
# Install what it needs, then run it:
#     rakupp install NativeLibs
#     rakupp 01-cannon.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeLibs;

say 'is-win : ', NativeLibs::is-win;
say '';
for 'm', 'ssl', 'foo.so' -> $lib {
    say sprintf('  cannon-name(%-8s)          = %s', $lib.raku,
                NativeLibs::cannon-name($lib));
}
say '  cannon-name("m", v6)           = ', NativeLibs::cannon-name('m', v6);
say '  cannon-name("m", "6")          = ', NativeLibs::cannon-name('m', '6');
say '';
say 'a name that already carries an extension is passed through untouched,';
say 'so cannon-name will not version a path you resolved yourself.';

# Output:
#     is-win : False
#     
#       cannon-name("m"     )          = libm.dylib
#       cannon-name("ssl"   )          = libssl.dylib
#       cannon-name("foo.so")          = foo.so
#       cannon-name("m", v6)           = libm.6.dylib
#       cannon-name("m", "6")          = libm.6.dylib
#     
#     a name that already carries an extension is passed through untouched,
#     so cannon-name will not version a path you resolved yourself.
