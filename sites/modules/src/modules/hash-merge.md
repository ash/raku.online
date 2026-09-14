---
name: Hash::Merge
version: 2.0.0
auth: cpan:TYIL
kind: Distribution · data
summary: Deep-merges hashes into a new one — nested hashes combined key by key,
  arrays appended rather than replaced, and the later argument winning every
  collision.
status: full
suite: 3 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/cpan:TYIL/Hash::Merge
source: https://git.sr.ht/~tyil/raku-hash-merge
---

## What it is for

Layered configuration is the case this exists for: a hash of defaults, a hash
read from a file, and a hash built from the command line, each meant to
override the one before it — but only at the leaves. Raku's own `%a, %b` in
list context flattens both and lets the later key win, which is right at the
top level and wrong one level down, where it discards the whole nested hash
instead of merging into it.

Two exported subs, both returning a new `Hash` and leaving their arguments
alone.

## Merging, and who wins

`merge-hash` takes exactly two; `merge-hashes` takes any number and folds them
left to right. In both, **later beats earlier** — so the defaults go first and
the overrides go last:

```raku name="precedence"
use Hash::Merge;

my %defaults = server => { host => 'localhost', port => 8080 }, debug => False;
my %config   = server => { port => 9000 },                      debug => True;

my %merged = merge-hash(%defaults, %config);
say %merged<server><host>, ' ', %merged<server><port>, ' ', %merged<debug>;
```

```output
localhost 9000 True
```

`port` and `debug` came from the override, and `host` survived from the
defaults even though `%config` has a `server` key of its own — which is the
behaviour the plain flattening would have lost.

Arrays are the other half of the story. By default they are *appended*, not
replaced, and `:!positional-append` switches that off:

```raku name="arrays"
use Hash::Merge;

my %a = tags => ['red', 'green'];
my %b = tags => ['blue'];

say merge-hash(%a, %b)<tags>.join(',');
say merge-hash(%a, %b, :!positional-append)<tags>.join(',');
say merge-hash(%a, %b, :!deep)<tags>.join(',');
```

```output
red,green,blue
blue
red,green,blue
```

## The one thing to know

Two defaults will surprise you, and they surprise in opposite directions.

Argument order reads backwards from how most people say it out loud. The
signature names the parameters `%first` and `%second`, and it is `%second`
that wins — so "merge my overrides into the defaults" is written
`merge-hash(%defaults, %overrides)`, with the thing you are merging *in*
written last. Get it the wrong way round and your defaults quietly win instead,
which is the kind of bug that only shows up for the one user who set the
option.

And `:!deep` does not turn appending off. As the third line above shows, an
array is still appended when deep merging is disabled: `:deep` governs whether
nested *hashes* are recursed into, and `:positional-append` independently
governs arrays. If what you want is "the later value replaces the earlier one,
whatever it is", you need `:!positional-append` as well.
