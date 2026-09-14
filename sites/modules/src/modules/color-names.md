---
name: Color::Names
version: 2.0.0
auth: zef:thundergnat
kind: Distribution · graphics
summary: Named colours as data — CSS3, Crayola, X11 and more, each name paired
  with its RGB triple, plus a substring search and a nearest-match by distance.
status: full
suite: 3 files, green
tested: 2026-09-14
license: BSD-2-Clause
raku-land: https://raku.land/zef:thundergnat/Color::Names
source: https://github.com/thundergnat/Color-Names
---

## What it is for

"Rebecca purple" is a colour a person can say and a computer cannot, until
something maps the name onto `102, 51, 153`. That mapping is pure reference
data, it is bigger than you want to paste into a program, and there is more
than one of it — CSS3's list, Crayola's crayon names, the X11 set that ships
with every window system, and several others besides.

This distribution is those lists, as hashes. Nothing is computed at load time
beyond building the table you ask for, and the sets are separate units so a
program pulling in CSS3 does not pay for Crayola.

## Looking a colour up, and finding one

Each palette is its own unit, imported with `:colors`, and
`Color::Names.color-data` assembles the hash — the keys carry the palette name
as a suffix, so several sets can be merged without collisions:

```raku name="lookup"
use Color::Names;
use Color::Names::CSS3 :colors;

my %css = Color::Names.color-data('CSS3');
say %css.elems, ' CSS3 colours';

my %c = %css<rebeccapurple-CSS3>;
say %c<name>, ' = ', %c<rgb>.join(', ');

for find-color(%css, 'slate').sort(*.key) -> $p {
    say $p.key, ' — ', $p.value<name>;
}
```

```output
141 CSS3 colours
Rebecca Purple = 102, 51, 153
darkslateblue-CSS3 — Dark Slate Blue
darkslategray-CSS3 — Dark Slate Gray
lightslategray-CSS3 — Light Slate Gray
mediumslateblue-CSS3 — Medium Slate Blue
slateblue-CSS3 — Slate Blue
slategray-CSS3 — Slate Gray
```

Every entry is a hash of `name` — the human spelling, capitalised — and `rgb`,
an array of three integers. `find-color` is a substring search over the keys
returning a `Seq` of `Pair`s, which is the right shape for offering a user the
six things they might have meant. Its `:ex` adverb narrows it to an exact
match. `nearest` answers the other question: given an arbitrary RGB triple,
which named colour is closest.

## The one thing to know

The key is not the name. `%css<rebeccapurple-CSS3>` works and
`%css<rebeccapurple>` gives an undefined value, because every key has its
palette appended — and that is a deliberate feature rather than an
inconvenience. It is what lets you merge CSS3 and Crayola into one table and
still tell a CSS "Green" from a Crayola "Green", which are not the same colour.

The consequence is that a name arriving from outside your program — typed by a
user, read from a config file — is never a key on its own. Either append the
palette you decided on, or put the name through `find-color` with `:ex` and
handle the empty result. Reaching straight into the hash with user input gets
you `Any` and, one line later, a failure somewhere that has nothing to do with
the lookup.
