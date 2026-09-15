---
name: wordfinder
version: 0.0.1
auth: zef:ian-nai
kind: Distribution · word games
summary: Words whose distinct-letter set equals your query's — an anagram-set
  match, not a "contains", behind a bundled dictionary you cannot reach.
status: full
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:ian-nai/wordfinder
source: https://github.com/ian-nai/wordfinder.git
---

## What it is for

Given a handful of letters, which words can you make from them? That is the
Scrabble-rack question, the crossword question and the word-game question, and
this distribution answers a particular version of it: return the words whose
*set of distinct characters* is identical to the query's, optionally filtered
to an exact length.

## Matching against a list

```raku name="array"
use wordfinder;

my @words = <eat ate tea eaten tar teal late>;
say 'check_array("tea", @words)     : ', check_array('tea', @words).raku;
say 'check_array("tea", @words, 3)  : ', check_array('tea', @words, 3).raku;
say '';
say 'the primitive underneath:';
for <abc cab>, <abc cabbage>, <abc abcd>, <aabbcc abc>, <ABC abc> -> ($a, $b) {
    say sprintf('  check_strings(%-10s, %-10s) = %s',
                $a.raku, $b.raku, check_strings($a, $b).raku);
}
```

```output
check_array("tea", @words)     : ["eat", "ate", "tea"]
check_array("tea", @words, 3)  : ["eat", "ate", "tea"]

the primitive underneath:
  check_strings("abc"     , "cab"     ) = "cab"
  check_strings("abc"     , "cabbage" ) = Empty
  check_strings("abc"     , "abcd"    ) = Empty
  check_strings("aabbcc"  , "abc"     ) = "abc"
  check_strings("ABC"     , "abc"     ) = Empty
```

A miss returns `Empty` — a `Slip`, not `Nil` and not `False`. It is falsy and
undefined, so `if` behaves, but it vanishes into any list you interpolate it
into.

## Matching against a file

```raku name="file"
use wordfinder;

my $dict = $*TMPDIR.add("wordfinder-{$*PID}.txt");
LEAVE $dict.unlink;
$dict.spurt("eat\nate\ntea\neaten\ntar\n");

say 'check_file("tea", $path)    : ', check_file('tea', $dict.Str).raku;
say 'check_file("tea", $path, 3) : ', check_file('tea', $dict.Str, 3).raku;
say '';
say 'read_dict returns the lines: ', read_dict($dict.Str).elems, ' of them';
```

```output
check_file("tea", $path)    : ["eat", "ate", "tea"]
check_file("tea", $path, 3) : ["eat", "ate", "tea"]

read_dict returns the lines: 5 of them
```

## The one thing to know

`check_file` with one argument — the "use the bundled dictionary" call, the
module's headline feature — can never work from an installed distribution. It
opens the literal relative path `resources/en_dict.txt`, resolved against the
process's current directory, and never touches the installed resource.

```raku name="bundled"
use wordfinder;

my $r = try check_file('tea');
say 'check_file("tea") with no path -> ', $! ?? 'threw' !! $r.raku;
say '';
say 'it is CWD-relative, not missing: create ./resources/en_dict.txt in';
say 'whatever directory you run from and the same call starts working.';
say '';
my $dir = $*TMPDIR.add("wf-{$*PID}");
LEAVE { $dir.add('resources/en_dict.txt').unlink; $dir.add('resources').rmdir; $dir.rmdir }
$dir.add('resources').mkdir;
$dir.add('resources/en_dict.txt').spurt("eat\nate\ntea\ntar\n");
my $old = $*CWD;
indir $dir, { say '  from inside such a directory: ', check_file('tea').raku };
say '';
say 'the two-argument (letters, Int) form has the same defect. Only the';
say 'forms where you pass a path yourself, and check_array, are usable.';
```

```output
check_file("tea") with no path -> threw

it is CWD-relative, not missing: create ./resources/en_dict.txt in
whatever directory you run from and the same call starts working.

  from inside such a directory: ["eat", "ate", "tea"]

the two-argument (letters, Int) form has the same defect. Only the
forms where you pass a path yourself, and check_array, are usable.
```

## The matcher is not "contains"

```raku name="semantics"
use wordfinder;

say 'check_strings compares the DISTINCT-letter sets for equality:';
say '  "abc" vs "cabbage" : ', check_strings('abc', 'cabbage').raku, '  <- not a subset test';
say '  "abc" vs "abcd"    : ', check_strings('abc', 'abcd').raku,    '  <- nor a prefix test';
say '  "aabbcc" vs "abc"  : ', check_strings('aabbcc', 'abc').raku,  '  <- repetition ignored';
say '  "ABC" vs "abc"     : ', check_strings('ABC', 'abc').raku,     '  <- case-SENSITIVE';
say '';
say 'so what you get is "words that are anagram-set-equal to the query".';
say 'lower-case your input yourself.';
```

```output
check_strings compares the DISTINCT-letter sets for equality:
  "abc" vs "cabbage" : Empty  <- not a subset test
  "abc" vs "abcd"    : Empty  <- nor a prefix test
  "aabbcc" vs "abc"  : "abc"  <- repetition ignored
  "ABC" vs "abc"     : Empty  <- case-SENSITIVE

so what you get is "words that are anagram-set-equal to the query".
lower-case your input yourself.
```

## Where the two engines differ

Nothing in the matching. Only how the missing-dictionary failure is raised:
Raku++ throws `X::IO::Open` where Rakudo throws `X::AdHoc`, so catch the
exception rather than matching its class — which is what the example above
does, and why it prints the same word on both engines.

One shape to guard against on both engines — the argument-count checks `say`
a message and then return `True`:

```raku name="arity"
use wordfinder;

my $r = check_array('tea');
say 'check_array with one argument returned : ', $r.raku;
say '';
say 'so `for check_array($x) { … }` iterates over True rather than over';
say 'nothing. The same is true for four or more arguments. Check the';
say 'result type, or wrap the call.';
say '';
say 'a dictionary word that is falsy as a string is dropped by the';
say 'internal `if $checked_var` filter:';
say '  check_array("0", ["0"]) = ', check_array('0', ['0']).raku;
```

```output
Please supply a string of letters and a list of words!
check_array with one argument returned : Bool::True

so `for check_array($x) { … }` iterates over True rather than over
nothing. The same is true for four or more arguments. Check the
result type, or wrap the call.

a dictionary word that is falsy as a string is dropped by the
internal `if $checked_var` filter:
  check_array("0", ["0"]) = ["0"]
```

Two costs worth knowing, identical on both engines. `check_file` reads the
whole dictionary with `.lines` into an array on every call — the bundled one
is 466 548 lines. And a non-`Int` length argument dies with a binding failure
rather than being caught by the `|args` dispatcher.
