---
name: Haikunator
version: 0.1.0
auth: none stated
kind: Distribution · identifiers
summary: Generate a random adjective-noun-number label in the Heroku style —
  a throwaway name a person can read aloud and remember.
status: full
suite: 2 files, green
tested: 2026-09-15
license: BSD-3-Clause
depends: none beyond the core
raku-land: https://raku.land/?/Haikunator
source: git://github.com/Atrox/haikunatorperl.git
---

## What it is for

A UUID is unique and unsayable. When a human has to read a name off a screen,
repeat it over the phone, or find it again in a list tomorrow, something like
`purple-unit-5091` beats `f47ac10b-58cc-4372-a567-0e02b2c3d479` every time.
Heroku named applications this way; so do a good many staging environments,
build slots and test fixtures.

This distribution is the one sub that mints those names, with the adjective
and noun lists baked in.

## Minting a name

The values are random, so what an example can show is their **shape**:

```raku name="shape"
use Haikunator;

my @names = (^300).map({ haikunate() });

say 'all match adjective-noun-NNNN : ',
    ?all(@names.map({ so $_ ~~ /^ <[a..z]>+ '-' <[a..z]>+ '-' \d ** 4 $/ }));
say 'distinct adjectives seen      : ', @names.map(*.split('-')[0]).unique.elems > 60;
say 'distinct nouns seen           : ', @names.map(*.split('-')[1]).unique.elems > 60;
say 'token is always four digits   : ',
    ?all(@names.map({ .split('-')[2] ~~ /^ \d ** 4 $/ }));
```

```output
all match adjective-noun-NNNN : True
distinct adjectives seen      : True
distinct nouns seen           : True
token is always four digits   : True
```

## Changing the shape

```raku name="options"
use Haikunator;

sub shape($s) { $s.subst(/<[a..z]>+/, 'W', :g).subst(/<[0..9a..fA..Z]>+$/, 'T') }

say 'default       : ', shape(haikunate());
say 'delimiter "." : ', shape(haikunate(:delimiter('.')));
say 'delimiter ""  : ', haikunate(:delimiter('')) ~~ /^ <[a..z]>+ \d ** 4 $/ ?? 'no separators' !! '?';
say 'tokenLength 0 : ', haikunate(:tokenLength(0)) ~~ /^ <[a..z]>+ '-' <[a..z]>+ $/ ?? 'no token at all' !! '?';
say 'tokenLength 8 : ', haikunate(:tokenLength(8)).split('-')[2].chars;
say 'tokenHex      : ', ?so haikunate(:tokenHex).split('-')[2] ~~ /^ <[0..9a..f]> ** 4 $/;
say 'tokenChars    : ', ?so haikunate(:tokenChars('ABC')).split('-')[2] ~~ /^ <[ABC]> ** 4 $/;
```

```output
default       : W-W-T
delimiter "." : W.W.T
delimiter ""  : no separators
tokenLength 0 : no token at all
tokenLength 8 : 8
tokenHex      : True
tokenChars    : True
```

The option names are **camelCase**, not Raku's usual kebab-case, and a
kebab-case spelling is rejected loudly rather than ignored:
`haikunate(:token-length(6))` dies with `Unexpected named argument
'token-length' passed`. That is the good outcome; the next section is the
other one.

`:tokenLength(0)` drops the token *and* the delimiter before it, so you get a
bare `adjective-noun`. A negative length does the same.

## The one thing to know

`:tokenHex` silently overrides `:tokenChars`. The alphabet you asked for is
discarded with no warning and no error.

```raku name="hex-trap"
use Haikunator;

my @t = (^400).map({ haikunate(:tokenHex, :tokenChars('XYZ')).split('-')[*-1] });
say 'asked for an alphabet of XYZ, with :tokenHex also set';
say '  tokens containing X, Y or Z : ', @t.grep(/<[XYZ]>/).elems;
say '  tokens made only of hex     : ', @t.grep(/^ <[0..9a..f]>+ $/).elems, ' of 400';

my @u = (^400).map({ haikunate(:tokenChars('XYZ'), :tokenHex).split('-')[*-1] });
say '  argument order reversed, X/Y/Z tokens : ', @u.grep(/<[XYZ]>/).elems;
```

```output
asked for an alphabet of XYZ, with :tokenHex also set
  tokens containing X, Y or Z : 0
  tokens made only of hex     : 400 of 400
  argument order reversed, X/Y/Z tokens : 0
```

Argument order makes no difference. `:tokenHex` does honour `:tokenLength`,
so the two options interact inconsistently — one is respected and the other
dropped, from the same call. Pass one or the other, never both.

## Where the two engines differ

Nowhere in behaviour. The names themselves differ between engines and between
runs, as they must; every shape assertion in this page holds identically on
Raku++ and Rakudo.

The thing to size before you rely on it: the adjective and noun lists hold 93
and 104 entries, so there are **9,672 distinct word pairs**. In 20,000 draws
the pair collided about 11,600 times. Uniqueness rests entirely on the
four-digit token, which puts the practical space near 96.7 million and the
birthday bound near 11,600 names — Rakudo already produced one complete
duplicate in 20,000 draws. Use it for readability and check uniqueness
separately, or raise `:tokenLength`.
