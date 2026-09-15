#!/usr/bin/env rakupp
# lemmatize — The one thing to know
# https://raku.online/modules/lemmatize/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install lemmatize
#     rakupp 02-pronouns.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use lemmatize;

my $csv = $*TMPDIR.add("lemma-en-{$*PID}.csv");
LEAVE $csv.unlink;
# these three rows are copied verbatim from the shipped en.csv
$csv.spurt(qq{it,"its, they"\ni,"my, me, we, is"\nbe,"was, were, am, are"\n});
construct_hash($csv.Str);

say 'lemmatize_string("They ran and he was better than we were"):';
say '  ', lemmatize_string('They ran and he was better than we were').join(' ');
say '';
for <they we is his her> -> $w {
    say sprintf('  %-6s -> %s', $w, lemmatize_array([$w]).raku);
}
say '';
say 'en.csv has  it,"its, they"  and  i,"my, me, we, is"  — so *they*';
say 'becomes *it* and *we* becomes *i*. Any downstream count of pronouns,';
say 'any coreference heuristic, any "who is this text about" measure is';
say 'now wrong, and nothing in the API signals it.';

# Output:
#     lemmatize_string("They ran and he was better than we were"):
#       it ran and he be better than i be
#     
#       they   -> ["it"]
#       we     -> ["i"]
#       is     -> ["i"]
#       his    -> ["his"]
#       her    -> ["her"]
#     
#     en.csv has  it,"its, they"  and  i,"my, me, we, is"  — so *they*
#     becomes *it* and *we* becomes *i*. Any downstream count of pronouns,
#     any coreference heuristic, any "who is this text about" measure is
#     now wrong, and nothing in the API signals it.
