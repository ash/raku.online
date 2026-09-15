#!/usr/bin/env rakupp
# UK::Sort — Where the two engines differ
# https://raku.online/modules/uk-sort/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install UK::Sort
#     rakupp 05-types.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UK::Sort;

# coerce at the call site and both engines agree
my @numbers = 10, 2, 33;
say 'numbers, stringified then sorted : ',
    sortuk(@numbers.map(*.Str)).join(' ');
say '';
say 'cmp_uk(10, 2) without the .Str is a run-time X::TypeCheck on Raku++';
say 'and "===SORRY!=== Calling cmp_uk(Int, Int) will never work" on Rakudo,';
say 'which no `try` can catch. Stringify before you sort.';
say '';
say 'the two shipped scripts, sortuk and sortuk-lib.raku, take the words';
say 'as arguments or a single argument that is an existing file. Note that';
say 'sortuk-lib.raku begins with `use lib "lib"`, so running it creates a';
say 'lib/.precomp directory wherever you happen to be.';

# Output:
#     numbers, stringified then sorted : 10 2 33
#     
#     cmp_uk(10, 2) without the .Str is a run-time X::TypeCheck on Raku++
#     and "===SORRY!=== Calling cmp_uk(Int, Int) will never work" on Rakudo,
#     which no `try` can catch. Stringify before you sort.
#     
#     the two shipped scripts, sortuk and sortuk-lib.raku, take the words
#     as arguments or a single argument that is an existing file. Note that
#     sortuk-lib.raku begins with `use lib "lib"`, so running it creates a
#     lib/.precomp directory wherever you happen to be.
