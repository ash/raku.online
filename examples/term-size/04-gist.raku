#!/usr/bin/env rakupp
# Term::Size — Where the two engines differ
# https://raku.online/modules/term-size/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Term::Size
#     rakupp 04-gist.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Term::Size;

my $ts = Term::Size.new;
my $r = $ts.populate;
$r.so if $r ~~ Failure;

say 'the overridden .raku is a REPORT, identical on both engines:';
print $ts.raku;
say '';
say 'but `say $ts` is not. Rakudo falls back to the overridden .raku for';
say '.gist and prints the same six lines; Raku++ prints the structural';
say 'gist. Anything logging $ts, or using dd, differs.';
say '';
say 'print the accessors, not the object.';
say '';
say 'the other difference: after `use Term::Size` alone, Raku++ leaks';
say 'Term::Size::Native`s exports into your scope, so `my TermSize $x .= new`';
say 'compiles there and is "Type TermSize is not declared" on Rakudo.';
say 'Use the qualified name, or `use Term::Size::Native` explicitly.';

# Output:
#     the overridden .raku is a REPORT, identical on both engines:
#     Terminal width (px):     Not Detected
#     Terminal height (px):    Not Detected
#     Terminal width (cells):  Not Detected
#     Terminal height (cells): Not Detected
#     Cell width (px):         Not Detected
#     Cell height (px):        Not Detected
#     but `say $ts` is not. Rakudo falls back to the overridden .raku for
#     .gist and prints the same six lines; Raku++ prints the structural
#     gist. Anything logging $ts, or using dd, differs.
#     
#     print the accessors, not the object.
#     
#     the other difference: after `use Term::Size` alone, Raku++ leaks
#     Term::Size::Native`s exports into your scope, so `my TermSize $x .= new`
#     compiles there and is "Type TermSize is not declared" on Rakudo.
#     Use the qualified name, or `use Term::Size::Native` explicitly.
