---
name: TinyID
version: 1.0.6
auth: zef:bbkr
kind: Distribution · identifiers
summary: Positional base-N encoding where the alphabet and its order are the
  secret — and where many distinct strings decode to the same ID.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:bbkr/TinyID
source: git://github.com/bbkr/TinyID.git
---

## What it is for

Turning a database row id into a short URL slug, without leaking how many rows
you have. The encoding is plain base-N; the obfuscation is entirely in the
alphabet you supply and the order you shuffle it into.

## Encoding

```raku name="basics"
use TinyID;

my $t = TinyID.new(key => 'cbad');
say 'key "cbad" means digits c=0 b=1 a=2 d=3';
for 0, 1, 2, 3, 4, 7, 16, 255, 1000 -> $n {
    say sprintf('  %4d -> %-6s -> %d', $n, $t.encode($n), $t.decode($t.encode($n)));
}
say '';
say 'a longer, shuffled alphabet is what you would actually use:';
my $u = TinyID.new(key => 'qWeRtYuIoPaSdFgHjKlZxCvBnM1234567890');
say '  encode(12345) = ', $u.encode(12345);
say '  decode back   = ', $u.decode($u.encode(12345));
say '';
say 'Unicode keys work too:';
my $g = TinyID.new(key => "\c[GREEK SMALL LETTER ALPHA]\c[GREEK SMALL LETTER BETA]\c[GREEK SMALL LETTER GAMMA]\c[GREEK SMALL LETTER DELTA]\c[GREEK SMALL LETTER EPSILON]");
say '  encode(31)    = ', $g.encode(31), '   decode = ', $g.decode($g.encode(31));
```

```output
key "cbad" means digits c=0 b=1 a=2 d=3
     0 -> c      -> 0
     1 -> b      -> 1
     2 -> a      -> 2
     3 -> d      -> 3
     4 -> bc     -> 4
     7 -> bd     -> 7
    16 -> bcc    -> 16
   255 -> dddd   -> 255
  1000 -> ddaac  -> 1000

a longer, shuffled alphabet is what you would actually use:
  encode(12345) = Pl8
  decode back   = 12345

Unicode keys work too:
  encode(31)    = βββ   decode = 31
```

## The properties that hold

```raku name="properties"
use TinyID;

my @alphabet = ('a' .. 'z', 'A' .. 'Z', '0' .. '9').flat;
my $t = TinyID.new(key => @alphabet.pick(*).join);

say 'over a randomly shuffled 62-character key, for 0 .. 3000:';
say '  decode(encode(n)) == n : ',
    so (0 .. 3000).all.map({ $t.decode($t.encode($_)) == $_ });
say '  encode is injective    : ',
    (0 .. 3000).map({ $t.encode($_) }).unique.elems == 3001;
say '  output uses only the key`s characters : ',
    so (0 .. 3000).all.map({ $t.encode($_).comb ⊆ @alphabet });
say '';
say 'and the length boundaries are exactly base-62:';
say '  n < 62      all 1 char  : ', so (^62).all.map({ $t.encode($_).chars == 1 });
say '  62 <= n < 3844 all 2    : ', so (62 ..^ 3844).all.map({ $t.encode($_).chars == 2 });
say '';
say 'the module contains no randomness — encode and decode are pure';
say 'functions of (key, input). Only your CHOICE of key is usually random.';
```

```output
over a randomly shuffled 62-character key, for 0 .. 3000:
  decode(encode(n)) == n : True
  encode is injective    : True
  output uses only the key`s characters : True

and the length boundaries are exactly base-62:
  n < 62      all 1 char  : True
  62 <= n < 3844 all 2    : True

the module contains no randomness — encode and decode are pure
functions of (key, input). Only your CHOICE of key is usually random.
```

## The one thing to know

`decode ∘ encode` is the identity, but `encode ∘ decode` is not — there is a
"zero digit", leading zero digits are accepted and discarded, and the empty
string decodes to 0.

```raku name="canonical"
use TinyID;

my $t = TinyID.new(key => 'cbad');
say 'encode(0) = ', $t.encode(0).raku;
for '', 'c', 'cc', 'cccb', 'b' -> $s {
    say sprintf('  decode(%-8s) = %d', $s.raku, $t.decode($s));
}
say '';
say 'so "", "c", "cc" and "ccc…" are all ID 0, and "cccb" and "b" are';
say 'both ID 1.';
say '';
say 'if you use these as URL slugs or database keys, they are NOT';
say 'canonical: an attacker, or a careless cache, can mint unlimited';
say 'distinct strings for the same record.';
say '';
say 'the empty string is particularly easy to hit, because .comb of ""';
say 'is the empty set, which trivially satisfies the argument constraint.';
say '';
say 'check for canonicity yourself:';
sub canonical($t, Str $s) { $s.chars && $t.encode($t.decode($s)) eq $s }
for '', 'c', 'cccb', 'b', 'bd' -> $s {
    say sprintf('  canonical(%-8s) = %s', $s.raku, canonical($t, $s).so);
}
```

```output
encode(0) = "c"
  decode(""      ) = 0
  decode("c"     ) = 0
  decode("cc"    ) = 0
  decode("cccb"  ) = 1
  decode("b"     ) = 1

so "", "c", "cc" and "ccc…" are all ID 0, and "cccb" and "b" are
both ID 1.

if you use these as URL slugs or database keys, they are NOT
canonical: an attacker, or a careless cache, can mint unlimited
distinct strings for the same record.

the empty string is particularly easy to hit, because .comb of ""
is the empty set, which trivially satisfies the argument constraint.

check for canonicity yourself:
  canonical(""      ) = False
  canonical("c"     ) = True
  canonical("cccb"  ) = False
  canonical("b"     ) = True
  canonical("bd"    ) = True
```

## What it refuses

```raku name="refusals"
use TinyID;

for 'aba', 'a', '' -> $key {
    my $r = try TinyID.new(:$key);
    say sprintf('  new(key => %-8s) -> %s', $key.raku, $! ?? 'refused' !! 'built');
}
say '';
say 'the key must have at least two DISTINCT characters — the constraint';
say 'is  .chars >= 2 and not /(.).*$0/';
say '';
my $t = TinyID.new(key => 'cbad');
for -1, 'z' -> $bad {
    my $r = try $bad ~~ Int ?? $t.encode($bad) !! $t.decode($bad);
    say sprintf('  %-12s -> %s',
                $bad ~~ Int ?? "encode($bad)" !! "decode({$bad.raku})",
                $! ?? 'refused' !! $r);
}
say '';
say 'a character outside the key, and a negative id, are both binding';
say 'failures rather than wrong answers.';
```

```output
  new(key => "aba"   ) -> refused
  new(key => "a"     ) -> refused
  new(key => ""      ) -> refused

the key must have at least two DISTINCT characters — the constraint
is  .chars >= 2 and not /(.).*$0/

  encode(-1)   -> refused
  decode("z")  -> refused

a character outside the key, and a negative id, are both binding
failures rather than wrong answers.
```

## Where the two engines differ

Nothing in the encoding. Only the wording of the refusals: Raku++'s constraint
messages omit Rakudo's trailing `expected … but got …` clause, and a missing
`:key` raises a different exception class on each engine. Catch, do not match.

```raku name="portable"
use TinyID;

# a slug helper with the canonicity check the module does not do
class Slugs {
    has TinyID $.codec;
    method new(Str :$key) { self.bless(codec => TinyID.new(:$key)) }
    method encode(UInt $n) { $!codec.encode($n) }
    method decode(Str $s) {
        my $n = $!codec.decode($s);
        die "non-canonical slug: {$s.raku}" unless $!codec.encode($n) eq $s;
        $n
    }
}
my $s = Slugs.new(key => 'cbad');
say 'encode(1000)     : ', $s.encode(1000);
say 'decode it back   : ', $s.decode($s.encode(1000));
my $r = try $s.decode('cccb');
say 'decode("cccb")   : ', $! ?? $!.message !! $r;
```

```output
encode(1000)     : ddaac
decode it back   : 1000
decode("cccb")   : non-canonical slug: "cccb"
```
