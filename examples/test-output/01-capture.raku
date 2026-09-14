#!/usr/bin/env rakupp
# Test::Output — Capture, or assert
# https://raku.online/modules/test-output/#capture-or-assert
#
# Install what it needs, then run it:
#     rakupp install Test::Output
#     rakupp 01-capture.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Test::Output;

sub greet($name) { print "hello, $name"; note "greeted $name" }

my $out = stdout-from { greet('world') };
my $err = stderr-from { greet('world') };

say "out: $out.raku()";
say "err: $err.raku()";

# Output:
#     out: "hello, world"
#     err: "greeted world\n"
