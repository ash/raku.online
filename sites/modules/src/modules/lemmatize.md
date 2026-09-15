---
name: lemmatize
version: 0.0.3
auth: zef:ian-nai
kind: Distribution · linguistics
summary: Dictionary-driven lemmatisation with 24 bundled language tables —
  and its English table folds the plural pronouns onto the singular ones.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:ian-nai/lemmatize
source: https://github.com/ian-nai/raku_lemmatize/
---

## What it is for

Where a stemmer chops suffixes, a lemmatiser looks the word up: *ran* becomes
*run*, *better* becomes *good*, *was* becomes *be*. It needs a table, and this
distribution ships 24 of them, one per language, as CSV resources.

You load a table, then replace every word in a string or array with its lemma.

## Loading a table and using it

```raku name="basics"
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
```

```output
table keys  : be good run

words_to_array   : ["the", "dogs", "ran", "and", "it", "wasn", "t", "good"]
lemmatize_string : ["she", "run", "and", "it", "be", "good"]
lemmatize_array  : ["run", "be", "good", "cat"]
```

Note `wasn't` becoming two tokens: the tokenizer lower-cases, splits on
whitespace **and on apostrophes**, and deletes punctuation. The orphaned `t`
will never lemmatise.

Nothing works until `construct_hash` has been called — on a fresh process
`lemmatize_string('She ran')` returns the words unchanged.

## The one thing to know

With the bundled English dataset, `lemmatize` collapses the plural pronouns
onto the singular ones.

```raku name="pronouns"
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
```

```output
lemmatize_string("They ran and he was better than we were"):
  it ran and he be better than i be

  they   -> ["it"]
  we     -> ["i"]
  is     -> ["i"]
  his    -> ["his"]
  her    -> ["her"]

en.csv has  it,"its, they"  and  i,"my, me, we, is"  — so *they*
becomes *it* and *we* becomes *i*. Any downstream count of pronouns,
any coreference heuristic, any "who is this text about" measure is
now wrong, and nothing in the API signals it.
```

## Two shapes to plan around

```raku name="shapes"
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
```

```output
lemmatize_array MUTATES its caller`s array:
  @in is now ["run", "cats"]

and construct_hash never CLEARS the table — calling it twice merges
both files into one module-level hash. There is no reset; start a
fresh process, or keep your own copy of what you loaded.

words_to_array writes into a module-level array and returns it, so
consecutive calls overwrite the same storage. Assigning copies:
  @a = ["one", "two"]   @b = ["three", "four"]
  (binding with := would NOT be safe here)
```

## Where the two engines differ

The shipped `en.csv` has 84 486 rows but only 84 384 distinct keys — 71 lemmas
are duplicated (`do`, `come`, `box`, `chute` and others). A duplicated key is
accumulated with `Hash.push`, and that is where the engines part: pushing a
`List` onto a fresh key coerces it to an `Array` under Raku++ and leaves it a
`List` under Rakudo, so the second push appends on one engine and nests on the
other. The flat form still matches; the nested one stops matching.

```raku name="duplicates"
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
```

```output
a table with ONE row per lemma is safe on both engines.
a DUPLICATED lemma is not — under Rakudo the second row nests and
stops matching, so "does" can come back as "doe" instead of "do".

the fix is to deduplicate the CSV before you load it:
  merged table : come=>came  do=>did|does|doing|done
```

One further cost, identical on both: the implementation scans the whole table
once per lemma, so a single call is `O(lemmas × words)` regardless of input
size. Loading the full `en.csv` and lemmatising one word takes seconds.
