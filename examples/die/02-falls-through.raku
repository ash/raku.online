#!/usr/bin/env rakupp
# Die — What still throws
# https://raku.online/modules/die/#what-still-throws
#
# Install what it needs, then run it:
#     rakupp install Die
#     rakupp 02-falls-through.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Die;

for 'no newline', 42, 42.5 -> $arg {
    my $r = try { die $arg };
    say sprintf('%-14s -> threw %s', $arg.gist, $!.^name);
}
my $e = try { die X::AdHoc.new(payload => 'an object') };
say sprintf('%-14s -> threw %s', 'an exception', $!.^name);

# Output:
#     no newline     -> threw X::AdHoc
#     42             -> threw X::AdHoc
#     42.5           -> threw X::AdHoc
#     an exception   -> threw X::AdHoc
