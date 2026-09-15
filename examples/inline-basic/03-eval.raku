#!/usr/bin/env rakupp
# Inline::BASIC — The one thing to know
# https://raku.online/modules/inline-basic/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 03-eval.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

basic(q:to/END/);
10 PRINT 7 / 2
20 PRINT 2 ** 10
30 PRINT 2 ^ 10
40 PRINT 1 / 3
END
say '';
say 'line 30 is the one to look at. BASIC`s exponent operator becomes';
say 'Raku`s one() junction constructor, and PRINT autothreads it — so';
say 'both operands come out in sequence and 2^10 prints 210.';
say '';
say 'a user writing 2^10 gets a plausible-looking number that is neither';
say '1024 nor an error. Write ** instead.';
say '';
say 'and because expressions go through EVAL, arbitrary Raku runs from';
say 'what looks like BASIC source. Do not feed this untrusted input.';

# Output:
#     3.5
#     1024
#     210
#     0.333333
#     
#     line 30 is the one to look at. BASIC`s exponent operator becomes
#     Raku`s one() junction constructor, and PRINT autothreads it — so
#     both operands come out in sequence and 2^10 prints 210.
#     
#     a user writing 2^10 gets a plausible-looking number that is neither
#     1024 nor an error. Write ** instead.
#     
#     and because expressions go through EVAL, arbitrary Raku runs from
#     what looks like BASIC source. Do not feed this untrusted input.
