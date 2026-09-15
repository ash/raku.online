#!/usr/bin/env rakupp
# lemmatize — Two shapes to plan around
# https://raku.online/modules/lemmatize/#two-shapes-to-plan-around
#
# Install what it needs, then run it:
#     rakupp install lemmatize
#     rakupp 03-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use lemmatize;

my $csv = $*TMPDIR.add("lemma-m-{$*PID}.csv");
LEAVE $csv.unlink;
$csv.spurt(qq{run,"ran, runs"\n});
construct_hash($csv.Str);

my @in = <ran cats>;
lemmatize_array(@in);
say 'lemmatize_array MUTATES its caller`s array:';
say '  @in is now ', @in.raku;
say '';
say 'and construct_hash never CLEARS the table — calling it twice merges';
say 'both files into one module-level hash. There is no reset; start a';
say 'fresh process, or keep your own copy of what you loaded.';
say '';
say 'words_to_array writes into a module-level array and returns it, so';
say 'consecutive calls overwrite the same storage. Assigning copies:';
my @a = words_to_array('one two');
my @b = words_to_array('three four');
say '  @a = ', @a.raku, '   @b = ', @b.raku;
say '  (binding with := would NOT be safe here)';

# Output:
#     lemmatize_array MUTATES its caller`s array:
#       @in is now ["run", "cats"]
#     
#     and construct_hash never CLEARS the table — calling it twice merges
#     both files into one module-level hash. There is no reset; start a
#     fresh process, or keep your own copy of what you loaded.
#     
#     words_to_array writes into a module-level array and returns it, so
#     consecutive calls overwrite the same storage. Assigning copies:
#       @a = ["one", "two"]   @b = ["three", "four"]
#       (binding with := would NOT be safe here)
