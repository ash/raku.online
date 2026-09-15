#!/usr/bin/env rakupp
# Config::INI — The one thing to know
# https://raku.online/modules/config-ini/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Config::INI
#     rakupp 04-newline-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::INI;

say 'with a trailing newline    : ', Config::INI::parse("a=b\n").defined;
say 'without one                : ', Config::INI::parse("a=b").defined;
say 'a section without one      : ', Config::INI::parse("[s]\nk=v").defined;
say '';
say 'the grammar\'s keyval token ends in <.eol>+, and eol requires a literal';
say 'newline — so the last line of a trimmed file is unmatchable.';
say '';
say 'and the failure is not an exception:';
my $r = Config::INI::parse("a=b");
say '  the return value is defined : ', $r.defined;

# Output:
#     with a trailing newline    : True
#     without one                : False
#     a section without one      : False
#     
#     the grammar's keyval token ends in <.eol>+, and eol requires a literal
#     newline — so the last line of a trimmed file is unmatchable.
#     
#     and the failure is not an exception:
#       the return value is defined : False
