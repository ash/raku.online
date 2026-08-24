#!/usr/bin/env rakupp
# URI — Where the two engines differ
# https://raku.online/ecosystem/uri/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 11-where-the-two-engines-differ.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

class C {
    proto method m(|) { * }
    multi method m(C:D: |c) { 'capture' }
    multi method m()        { 'empty'   }
}
say C.new.m;      # Rakudo: empty      Raku++: capture
