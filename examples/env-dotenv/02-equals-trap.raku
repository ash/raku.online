#!/usr/bin/env rakupp
# Env::Dotenv — The one thing to know
# https://raku.online/modules/env-dotenv/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Env::Dotenv
#     rakupp 02-equals-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Env::Dotenv :values;

my $dir = $*TMPDIR.add("dotenv2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

$dir.add('.env').spurt: q:to/ENV/;
BASE64=aGVsbG8=
URL=https://example.com/?a=1&b=2
QUOTED="double quoted"
SPACED = padded
EXPORTED=plain
ENV

indir $dir, {
    my %v = dotenv_values();
    for %v.keys.sort -> $k {
        say sprintf('%-12s => %s', $k.raku, %v{$k}.raku);
    }
}

# Output:
#     "BASE64"     => "aGVsbG8"
#     "EXPORTED"   => "plain"
#     "QUOTED"     => "\"double quoted\""
#     "SPACED "    => " padded"
#     "URL"        => "https://example.com/?a"
