---
name: Lingua::EN::Stopwords
version: 0.0.2
auth: unstated in META
kind: Distribution · linguistics
summary: Three fixed English stop-word lists in three separate units — and
  the exported hash is the module's own, not a copy.
status: divergent
suite: 3 files, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/?/Lingua::EN::Stopwords
source: git://github.com/kmwallio/p6-Lingua-EN-Stopwords.git
---

## What it is for

Stop words are the high-frequency function words you strip before indexing,
counting or clustering text: *the*, *of*, *and*. Which words belong on the
list is a judgement call, and it depends on the corpus — so this distribution
ships three lists of different sizes and lets you pick.

There is no algorithm here. `is-stop-word` lower-cases its argument and does
an `:exists` lookup.

## The three lists

`Lingua::EN::Stopwords` itself does not exist — the units are the three
variants, and each exports the same two names.

```raku name="short"
use Lingua::EN::Stopwords::Short;

say 'Short list   : ', %stop-words.elems, ' entries';
for 'the', 'THE', 'The', "aren't", 'frobnicate', '' -> $w {
    say sprintf('  is-stop-word(%-12s) = %s', $w.raku, is-stop-word($w));
}
say '';
say 'the lookup lower-cases, so case does not matter — but punctuation';
say 'does: is-stop-word("the.") = ', is-stop-word('the.');
```

```output
Short list   : 174 entries
  is-stop-word("the"       ) = True
  is-stop-word("THE"       ) = True
  is-stop-word("The"       ) = True
  is-stop-word("aren't"    ) = True
  is-stop-word("frobnicate") = False
  is-stop-word(""          ) = False

the lookup lower-cases, so case does not matter — but punctuation
does: is-stop-word("the.") = False
```

```raku name="sizes"
use Lingua::EN::Stopwords::Long;

say 'Long list : ', %stop-words.elems, ' entries';
say '';
say 'it is not a general English list — it is a biomedical-abstract one:';
for <able value important significant research zero nine> -> $w {
    say sprintf('  %-12s -> %s', $w, is-stop-word($w));
}
say '';
my $letters = ('a' .. 'z').grep({ is-stop-word($_) }).join;
say 'single letters on the list : ', $letters;
say '';
say 'run general prose through Long and you delete the content words.';
```

```output
Long list : 667 entries

it is not a general English list — it is a biomedical-abstract one:
  able         -> True
  value        -> True
  important    -> True
  significant  -> True
  research     -> True
  zero         -> True
  nine         -> True

single letters on the list : abcdefghijklmnopqrstuvwxyz

run general prose through Long and you delete the content words.
```

All three lists drop `not`, `no`, `nor` and `never`, which inverts the meaning
of any sentence you then classify.

## The one thing to know

The exported `%stop-words` is the very container `is-stop-word` reads. Writing
to it rewrites the module's behaviour for the whole process.

```raku name="mutable"
use Lingua::EN::Stopwords::Short;

say 'before : is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
%stop-words<frobnicate> = 1;
say 'after  : is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
%stop-words<frobnicate>:delete;
say 'removed: is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
say '';
say 'it is exported as a mutable `our` variable, not a copy. Convenient';
say 'if you want to extend a list; a trap if two parts of one program';
say 'both "customise" it. Take a copy: my %mine = %stop-words;';
```

```output
before : is-stop-word("frobnicate") = False
after  : is-stop-word("frobnicate") = True
removed: is-stop-word("frobnicate") = False

it is exported as a mutable `our` variable, not a copy. Convenient
if you want to extend a list; a trap if two parts of one program
both "customise" it. Take a copy: my %mine = %stop-words;
```

## Where the two engines differ

The three units export *identical* symbol names, so using two of them together
is a compile error under Rakudo and a silent merge under Raku++.

```raku name="one-list"
use Lingua::EN::Stopwords::Short;

# to compare two lists, load one and read the other through its package
my %short = %stop-words;
say 'Short loaded here : ', %short.elems;
say '';
say 'loading a SECOND variant into the same scope is a compile error on';
say 'Rakudo — "Cannot import the following symbols … because they already';
say 'exist in this lexical scope". Raku++ merges the two `our` hashes into';
say 'one instead, so the union silently becomes the list you are using.';
say '';
say 'If you need two, load them in separate scopes or separate files.';
```

```output
Short loaded here : 174

loading a SECOND variant into the same scope is a compile error on
Rakudo — "Cannot import the following symbols … because they already
exist in this lexical scope". Raku++ merges the two `our` hashes into
one instead, so the union silently becomes the list you are using.

If you need two, load them in separate scopes or separate files.
```

Under Raku++ the merge produces 700 entries, the union of Short's 174 and
Long's 667 — and `is-stop-word` then answers for both, which is not what
either `use` asked for.

One further note that is the same on both engines: `Short` (174 entries) is
the conventional list; `SQL` (543) keeps apostrophe forms like `a's` and has
no single letters; `Long` is the one to be careful with.
