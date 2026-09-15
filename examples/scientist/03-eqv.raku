#!/usr/bin/env rakupp
# Scientist — The one thing to know
# https://raku.online/modules/scientist/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Scientist
#     rakupp 03-eqv.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Scientist;

sub compare($label, &a, &b) {
    my $s = Scientist.new(experiment => $label, use => &a, try => &b);
    $s.run;
    sprintf('  %-28s mismatched = %s', $label, $s.result<mismatched>)
}
say compare('Int 42 vs Rat 42.0',  { 42 },        { 42.0 });
say compare('Int 42 vs Num 42e0',  { 42 },        { 42e0 });
say compare('Int 42 vs Str "42"',  { 42 },        { '42' });
say compare('List vs Array',       { (1, 2, 3) }, { [1, 2, 3] });
say compare('List vs Seq',         { (1, 2, 3) }, { (1, 2, 3).Seq });
say compare('Hash vs Map',         { %( a => 1 ) }, { Map.new(('a', 1)) });
say compare('identical Ints',      { 42 },        { 42 });
say compare('both return Nil',     { Nil },       { Nil });
say '';
say '42 versus 42.0 is a mismatch; (1,2,3) versus [1,2,3] is a mismatch.';
say 'In a real refactor those are the COMMON cases, and there is no hook';
say 'to supply your own comparator.';
say '';
say 'normalise inside the two callables:';
my $s = Scientist.new(experiment => 'normalised',
                      use => sub { (1, 2, 3).List },
                      try => sub { [1, 2, 3].List });
$s.run;
say '  both .List-ed -> mismatched = ', $s.result<mismatched>;

# Output:
#       Int 42 vs Rat 42.0           mismatched = True
#       Int 42 vs Num 42e0           mismatched = True
#       Int 42 vs Str "42"           mismatched = True
#       List vs Array                mismatched = True
#       List vs Seq                  mismatched = True
#       Hash vs Map                  mismatched = True
#       identical Ints               mismatched = False
#       both return Nil              mismatched = False
#     
#     42 versus 42.0 is a mismatch; (1,2,3) versus [1,2,3] is a mismatch.
#     In a real refactor those are the COMMON cases, and there is no hook
#     to supply your own comparator.
#     
#     normalise inside the two callables:
#       both .List-ed -> mismatched = False
