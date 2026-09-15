---
name: Algorithm::Manacher
version: 0.0.1
auth: none stated
kind: Distribution · algorithms
summary: Manacher's linear scan for palindromic substrings — every maximal
  palindrome and its position, computed once at construction.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Algorithm::Manacher
source: git://github.com/titsuki/p6-Algorithm-Manacher.git
---

## What it is for

Finding the longest palindromic substring by checking every substring is
cubic. Manacher's algorithm does it in one linear pass, by remembering the
widest palindrome found so far and using its symmetry to skip comparisons it
has already made implicitly.

This distribution runs that scan once, in `BUILD`, and the three query methods
read the result. Construction costs are proportional to the text; the queries
are cheap.

## Finding palindromes

```raku name="find"
use Algorithm::Manacher;

sub dump(%h) {
    %h.keys.sort.map({
        "$_ => " ~ (%h{$_} ~~ Positional
            ?? '[' ~ %h{$_}.list.map(*.Int).sort.join(',') ~ ']'
            !! %h{$_}.Int)
    }).join('  ')
}

for 'banana', 'abacaba', 'aabb', 'noon', 'abc' -> $t {
    my $m = Algorithm::Manacher.new(text => $t);
    say "text '$t'";
    say '  is-palindrome           : ', $m.is-palindrome;
    say '  find-longest-palindrome : ', dump($m.find-longest-palindrome);
    say '  find-all-palindrome     : ', dump($m.find-all-palindrome);
}
```

```output
text 'banana'
  is-palindrome           : False
  find-longest-palindrome : anana => 1
  find-all-palindrome     : a => [1,5]  ana => [1,3]  anana => 1  b => 0
text 'abacaba'
  is-palindrome           : True
  find-longest-palindrome : abacaba => 0
  find-all-palindrome     : a => [0,2,4,6]  aba => [0,4]  abacaba => 0
text 'aabb'
  is-palindrome           : False
  find-longest-palindrome : aa => 0  bb => 2
  find-all-palindrome     : a => [0,1]  aa => 0  b => [2,3]  bb => 2
text 'noon'
  is-palindrome           : True
  find-longest-palindrome : noon => 0
  find-all-palindrome     : n => [0,3]  noon => 0  o => [1,2]
text 'abc'
  is-palindrome           : False
  find-longest-palindrome : a => 0  b => 1  c => 2
  find-all-palindrome     : a => 0  b => 1  c => 2
```

`find-longest-palindrome` returns *every* joint-longest palindrome when there
is a tie, so `aabb` gives you two entries.

## The edges

```raku name="edges"
use Algorithm::Manacher;

say 'empty text ""  : is-palindrome=', Algorithm::Manacher.new(text => '').is-palindrome;
say 'one char  "x"  : is-palindrome=', Algorithm::Manacher.new(text => 'x').is-palindrome;
say 'two same  "xx" : is-palindrome=', Algorithm::Manacher.new(text => 'xx').is-palindrome;
say '';
my $jp = Algorithm::Manacher.new(text => "たけやぶやけた");
say 'non-ASCII      : is-palindrome=', $jp.is-palindrome;
my $comb = Algorithm::Manacher.new(text => "e\x[301]e\x[301]");
say 'combining mark : chars=', "e\x[301]e\x[301]".chars, ' is-palindrome=', $comb.is-palindrome;
```

```output
empty text ""  : is-palindrome=False
one char  "x"  : is-palindrome=True
two same  "xx" : is-palindrome=True

non-ASCII      : is-palindrome=True
combining mark : chars=2 is-palindrome=True
```

The empty string is **not** a palindrome here; a single character is.
Palindromes are grapheme-based, so a combining acute counts as one character,
which is the right answer.

## The one thing to know

`find-all-palindrome` does not return every palindromic substring — only the
maximal one per centre.

```raku name="maximal-trap"
use Algorithm::Manacher;

my $t = 'banana';
my %all = Algorithm::Manacher.new(text => $t).find-all-palindrome;

my @every = gather for 0 ..^ $t.chars -> $i {
    for $i ..^ $t.chars -> $j {
        my $s = $t.substr($i, $j - $i + 1);
        take $s if $s eq $s.flip;
    }
};

say "text                        : $t";
say 'find-all-palindrome keys    : ', %all.keys.sort.join(' ');
say 'every palindromic substring : ', @every.unique.sort.join(' ');
say 'missing from find-all       : ', (@every.unique (-) %all.keys).keys.sort.join(' ');
say '';
say "'a' occurs at indices       : ",
    (0 ..^ $t.chars).grep({ $t.substr($_, 1) eq 'a' }).join(',');
say "find-all says 'a' is at     : ", %all<a>.list.map(*.Int).sort.join(',');
```

```output
text                        : banana
find-all-palindrome keys    : a ana anana b
every palindromic substring : a ana anana b n nan
missing from find-all       : n nan

'a' occurs at indices       : 1,3,5
find-all says 'a' is at     : 1,5
```

`n` and `nan` are genuine palindromic substrings of `banana` and are absent,
because the maximal palindrome at each of their centres is something longer.
The `a` at index 3 is absent for the same reason: the maximal palindrome
centred there is `anana`.

For "find every palindrome in this text", expand each returned maximal
palindrome inward yourself. For "find the longest", which is what Manacher is
for, this is exactly right.

## Where the two engines differ

Only on the constructor with no argument at all. Rakudo enforces the `Str:D`
constraint even when the named argument is absent, giving `Parameter '$!text'
of routine 'BUILD' must be an object instance`; Raku++ lets the omission
through and fails later inside `BUILD` on a `.split` of an undefined value.
Both die; the message differs.

Two things that are not engine differences. Positions come back as **`Rat`**,
not `Int` — `0.0`, `1.0` — because the scan uses half-integer centres to
handle even and odd lengths uniformly. They work as `substr` offsets and
compare numerically, but `.WHAT` is `Rat`, which is why every example above
coerces with `.Int`. And both hash-returning methods are built with
`%result.push`, so a key seen once maps to a **bare scalar** and a key seen
twice maps to an **Array**; `.list` and `[0]` work for either shape, but
`.elems` and anything type-dispatched will not.

Correctness was cross-checked against brute force over all 254 binary strings
of length one to seven, with zero mismatches on either engine.
