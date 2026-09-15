---
name: Unicode::PRECIS
version: 0.5.2
auth: none stated
kind: Distribution · Unicode
summary: The PRECIS framework of RFC 8264 — decide whether a string is
  acceptable as a username or a password, and normalise it for comparison.
status: partial
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Unicode::PRECIS
source: git://github.com/MARTIMM/unicode-precis.git
---

## What it is for

Two usernames that look identical should not be two accounts, and a password
typed on a phone keyboard should match the one typed on a laptop. Getting that
right across the whole of Unicode is a specification-sized problem, and PRECIS
is the specification: two base string classes and four profiles covering
case-mapped usernames, case-preserved usernames and opaque password strings.

This distribution implements them, over about ten thousand lines of generated
Unicode tables.

## Enforcing a profile

```raku name="enforce"
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;
use Unicode::PRECIS::Identifier::UsernameCasePreserved;
use Unicode::PRECIS::FreeForm::OpaqueString;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;
my $cp = Unicode::PRECIS::Identifier::UsernameCasePreserved.new;
my $op = Unicode::PRECIS::FreeForm::OpaqueString.new;

sub show($name, $obj, $in) {
    my $r = $obj.enforce($in);
    say sprintf('%-14s %-26s -> %s', $name, $in.raku,
        $r ~~ Str ?? $r.raku !! 'rejected');
}

show 'CaseMapped',    $cm, 'BobSmith';
show 'CasePreserved', $cp, 'BobSmith';
show 'CaseMapped',    $cm, 'correct horse battery';
show 'OpaqueString',  $op, 'correct horse battery';
show 'OpaqueString',  $op, '';
```

```output
CaseMapped     "BobSmith"                 -> "bobsmith"
CasePreserved  "BobSmith"                 -> "BobSmith"
CaseMapped     "correct horse battery"    -> rejected
OpaqueString   "correct horse battery"    -> "correct horse battery"
OpaqueString   ""                         -> rejected
```

The Identifier and FreeForm split is the point: a username may not contain a
space and a password may. `enforce` returns the canonical form on success and
`False` on rejection — the return is `Str | Bool`, not an enum.

## Comparison

```raku name="compare"
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;

say 'case folding:';
say '  compare("BobSmith", "bobsmith") : ', $cm.compare('BobSmith', 'bobsmith');
say '';
my $latin = 'paypal';
my $spoof = "p\c[CYRILLIC SMALL LETTER A]yp\c[CYRILLIC SMALL LETTER A]l";
say 'a Cyrillic homograph:';
say '  they render identically       : ', $latin.chars == $spoof.chars;
say '  codepoints differ             : ', $latin.ords ne $spoof.ords;
say '  compare says                  : ', $cm.compare($latin, $spoof);
```

```output
case folding:
  compare("BobSmith", "bobsmith") : True

a Cyrillic homograph:
  they render identically       : True
  codepoints differ             : True
  compare says                  : False
```

That last result is **correct** PRECIS behaviour, not a bug — PRECIS is not a
confusables defence, and the specification is explicit about it. It is worth
knowing that a comparison returning `False` for two strings that render
identically is the design.

## The one thing to know

`width-mapping-rule` returns the decimal codepoint **numbers** as text, and
`prepare` hands that back as a valid username.

```raku name="width-trap"
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;
my $fw = "\c[FULLWIDTH LATIN CAPITAL LETTER A]" ~ "\c[FULLWIDTH LATIN SMALL LETTER B]";

say 'input codepoints      : ', $fw.ords.List.raku;
say 'width-mapping-rule    : ', $cm.width-mapping-rule($fw).raku;
say 'which is just those numbers concatenated : ',
    $cm.width-mapping-rule($fw) eq $fw.ords.join('');
say 'a real width mapping would give          : ',
    $fw.comb.map({ my $o = .ord; 0xFF01 <= $o <= 0xFF5E ?? ($o - 0xFEE0).chr !! $_ }).join.raku;
say '';
say 'and prepare and enforce disagree about it:';
say '  prepare : ', $cm.prepare($fw).raku;
say '  enforce : ', $cm.enforce($fw) ~~ Str ?? $cm.enforce($fw).raku !! 'rejected';
```

```output
input codepoints      : (65313, 65346)
width-mapping-rule    : "6531365346"
which is just those numbers concatenated : True
a real width mapping would give          : "Ab"

and prepare and enforce disagree about it:
  prepare : "6531365346"
  enforce : rejected
```

Two failures at once. The mapping produces nonsense instead of folding
fullwidth `Ａ` to `A`, and `prepare` **accepts** what `enforce` rejects,
returning a plausible-looking ten-digit string that a caller would happily
store as a username.

ASCII passes through the rule untouched, which is why this survives casual
testing.

Use `enforce`, never `prepare`, and do not rely on width folding.

## Where the two engines differ

Only in how `TestValue` fails introspection: it is a `subset`, not an enum, so
`.^enum_value_list` throws on both engines with different type names in the
message. Treat the return as `Str | Bool`.

One trap that is the same on both and is worth a line of its own. The low-level
`PropValue` enum has **`PVALID` as 0 and `DISALLOWED` as 5** — so `PVALID` is
falsy and `DISALLOWED` is truthy. Any `if` test on a raw `PropValue` from the
low-level interface is inverted.

The distribution declares no `auth`, and ships one test file for a module of
this size and security purpose.
