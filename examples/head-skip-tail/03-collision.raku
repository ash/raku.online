#!/usr/bin/env rakupp
# head-skip-tail — The one thing to know
# https://raku.online/modules/head-skip-tail/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install head-skip-tail
#     rakupp 03-collision.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use head-skip-tail;

my @a = ^10;
say 'with the use in place, all three are the iterable ones:';
say '  head(4, @a) = ', head(4, @a);
say '  skip(8, @a) = ', skip(8, @a);
say '  tail(2, @a) = ', tail(2, @a);
say '';
say 'without it, on Raku++, `skip` is Test::skip — it prints ten "ok"';
say 'lines to stdout and returns Bool::True. head and tail still resolve';
say 'to the setting`s own subs there, so only skip is affected, which is';
say 'exactly the kind of thing that survives a quick test.';
say '';
say 'Test`s routines are visible without `use Test` on Raku++ at all —';
say 'ok, plan, is, todo and done-testing are all callable in a bare';
say 'script there and undeclared on Rakudo.';

# Output:
#     with the use in place, all three are the iterable ones:
#       head(4, @a) = (0 1 2 3)
#       skip(8, @a) = (8 9)
#       tail(2, @a) = (8 9)
#     
#     without it, on Raku++, `skip` is Test::skip — it prints ten "ok"
#     lines to stdout and returns Bool::True. head and tail still resolve
#     to the setting`s own subs there, so only skip is affected, which is
#     exactly the kind of thing that survives a quick test.
#     
#     Test`s routines are visible without `use Test` on Raku++ at all —
#     ok, plan, is, todo and done-testing are all callable in a bare
#     script there and undeclared on Rakudo.
