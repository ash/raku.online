#!/usr/bin/env rakupp
# lemmatize — Loading a table and using it
# https://raku.online/modules/lemmatize/#loading-a-table-and-using-it
#
# Install what it needs, then run it:
#     rakupp install lemmatize
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use lemmatize;

my $csv = $*TMPDIR.add("lemma-{$*PID}.csv");
LEAVE $csv.unlink;
$csv.spurt(qq{run,"ran, runs, running"\nbe,"was, were, is, am"\ngood,"better, best"\n});

my %h = construct_hash($csv.Str);
say 'table keys  : ', %h.keys.sort.join(' ');
say '';
say 'words_to_array   : ', words_to_array("The dogs ran and it wasn't good").raku;
say 'lemmatize_string : ', lemmatize_string('She ran and it was good').raku;
say 'lemmatize_array  : ', lemmatize_array(['ran', 'was', 'better', 'cat']).raku;

# Output:
#     table keys  : be good run
#     
#     words_to_array   : ["the", "dogs", "ran", "and", "it", "wasn", "t", "good"]
#     lemmatize_string : ["she", "run", "and", "it", "be", "good"]
#     lemmatize_array  : ["run", "be", "good", "cat"]
