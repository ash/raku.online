#!/usr/bin/env rakupp
# lemmatize — Where the two engines differ
# https://raku.online/modules/lemmatize/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install lemmatize
#     rakupp 04-duplicates.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use lemmatize;

my $csv = $*TMPDIR.add("lemma-dup-{$*PID}.csv");
LEAVE $csv.unlink;
# `do` appears twice in the shipped en.csv, exactly like this
$csv.spurt(qq{do,"did, does"\ndo,"doing, done"\ncome,"came"\n});
construct_hash($csv.Str);

say 'a table with ONE row per lemma is safe on both engines.';
say 'a DUPLICATED lemma is not — under Rakudo the second row nests and';
say 'stops matching, so "does" can come back as "doe" instead of "do".';
say '';
say 'the fix is to deduplicate the CSV before you load it:';
my %seen;
for $csv.Str.IO.lines -> $line {
    my ($lemma, $rest) = $line.split(',', 2);
    %seen{$lemma}.push($rest.subst('"', '', :g).split(/\s* ',' \s*/).Slip);
}
say '  merged table : ', %seen.keys.sort.map({ "$_=>" ~ %seen{$_}.sort.join('|') }).join('  ');

# Output:
#     a table with ONE row per lemma is safe on both engines.
#     a DUPLICATED lemma is not — under Rakudo the second row nests and
#     stops matching, so "does" can come back as "doe" instead of "do".
#     
#     the fix is to deduplicate the CSV before you load it:
#       merged table : come=>came  do=>did|does|doing|done
