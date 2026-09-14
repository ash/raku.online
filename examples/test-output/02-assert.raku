#!/usr/bin/env rakupp
# Test::Output — Capture, or assert
# https://raku.online/modules/test-output/#capture-or-assert
#
# Install what it needs, then run it:
#     rakupp install Test::Output
#     rakupp 02-assert.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Test;
use Test::Output;

sub banner($t) { say '== ' ~ $t ~ ' ==' }

plan 3;
stdout-is   { banner('hi') }, "== hi ==\n", 'banner frames its title';
stdout-like { banner('hi') }, /^ '==' /,    'and starts with the rule';
stderr-is   { note 'warned' }, "warned\n",  'note goes to stderr';

# Output:
#     1..3
#     ok 1 - banner frames its title
#     ok 2 - and starts with the rule
#     ok 3 - note goes to stderr
