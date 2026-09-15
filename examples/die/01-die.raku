#!/usr/bin/env rakupp
# Die — The convention
# https://raku.online/modules/die/#the-convention
#
# Install what it needs, then run it:
#     rakupp install Die
#     rakupp 01-die.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Die;

# a message with no trailing newline is still an ordinary exception
my $r = try { die 'plain' };
say 'die("plain") -> caught ', $!.^name, ': ', $!.message;
say '';
say 'a message WITH a trailing newline does not come back here at all —';
say 'it is printed to stderr and the process exits 1.';

# Output:
#     die("plain") -> caught X::AdHoc: plain
#     
#     a message WITH a trailing newline does not come back here at all —
#     it is printed to stderr and the process exits 1.
