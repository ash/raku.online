---
name: Brazilian::FederalDocuments
version: 0.1.1
auth: zef:raku-community-modules
kind: Distribution · validation
summary: CPF and CNPJ check-digit validation — missing the official 10→0 fold,
  so it rejects one in six well-formed documents and accepts every repdigit.
status: divergent
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Brazilian::FederalDocuments
source: https://github.com/raku-community-modules/Brazilian-FederalDocuments.git
---

## What it is for

Brazil's two taxpayer identifiers carry check digits: the CPF for a person
(eleven digits) and the CNPJ for a company (fourteen). A weighted-modulus sum
over the leading digits reproduces the trailing ones, which lets a form reject
a typo before it reaches a database.

## Using it

```raku name="basics"
use Brazilian::FederalDocuments;

for '12345678909', '00000000000', '191' -> $n {
    my $cpf = FederalDocuments::CPF.new(number => $n);
    say sprintf('  CPF  %-14s -> %s', $n.raku, $cpf.is-valid);
}
say '';
say 'note the class name: `use Brazilian::FederalDocuments` installs NO';
say 'symbol of that name. What you get is FederalDocuments::CPF and';
say 'FederalDocuments::CNPJ, so the first line of your program does not';
say 'match the one above it.';
say '';
say 'the role behind them:';
say '  is-valid : caches the answer computed at construction';
say '  verify   : public and re-runnable — but $.number cannot change,';
say '             so it can only ever produce the same answer.';
```

```output
  CPF  "12345678909"  -> False
  CPF  "00000000000"  -> True
  CPF  "191"          -> True

note the class name: `use Brazilian::FederalDocuments` installs NO
symbol of that name. What you get is FederalDocuments::CPF and
FederalDocuments::CNPJ, so the first line of your program does not
match the one above it.

the role behind them:
  is-valid : caches the answer computed at construction
  verify   : public and re-runnable — but $.number cannot change,
             so it can only ever produce the same answer.
```

## The padding

The number is left-zero-padded to length, which makes several surprising
inputs valid:

```raku name="padding"
use Brazilian::FederalDocuments;

for 0, '', 191, '000.000.001-91' -> $n {
    my $cpf = FederalDocuments::CPF.new(number => $n);
    say sprintf('  %-18s -> is-valid %-5s   .number reads back as %s',
                $n.raku, $cpf.is-valid, $cpf.number.raku);
}
say '';
say 'an empty string is a valid CPF. A formatted one is 14 characters,';
say 'over the 11-character ceiling, so it is rejected as invalid rather';
say 'than cleaned — strip the punctuation yourself.';
say '';
say 'and .number is stored verbatim, so the accessor and the value the';
say 'validator actually checked disagree.';
```

```output
  0                  -> is-valid True    .number reads back as 0
  ""                 -> is-valid True    .number reads back as ""
  191                -> is-valid True    .number reads back as 191
  "000.000.001-91"   -> is-valid False   .number reads back as "000.000.001-91"

an empty string is a valid CPF. A formatted one is 14 characters,
over the 11-character ceiling, so it is rejected as invalid rather
than cleaned — strip the punctuation yourself.

and .number is stored verbatim, so the accessor and the value the
validator actually checked disagree.
```

## The one thing to know

The check-digit arithmetic is missing the official `10 → 0` fold, so it
rejects about one in six genuinely well-formed documents — and it accepts
every one of the repdigit numbers Brazil rejects outright.

```raku name="checkdigits"
use Brazilian::FederalDocuments;

# the published rule: r = sum % 11; digit = r < 2 ?? 0 !! 11 - r
sub cpf-digits(@base) {
    my @d = @base;
    for 0, 1 -> $round {
        my $w = 10 + $round;
        my $sum = [+] @d.kv.map(-> $i, $v { $v * ($w - $i) });
        my $r = $sum % 11;
        @d.push($r < 2 ?? 0 !! 11 - $r);
    }
    @d.join
}

my $good = cpf-digits([1,2,3,4,5,6,7,8,9]);
say 'the published algorithm turns 123456789 into ', $good;
say '  the module says is-valid = ',
    FederalDocuments::CPF.new(number => $good).is-valid;
say '';
say 'the repdigits, which the real specification blacklists by name:';
for <00000000000 11111111111 55555555555 99999999999> -> $n {
    say sprintf('  %-14s -> %s', $n, FederalDocuments::CPF.new(number => $n).is-valid);
}
say '';
say 'the formula genuinely self-satisfies for those, which is exactly why';
say 'the specification carries an explicit blacklist. This module has none.';
```

```output
the published algorithm turns 123456789 into 12345678909
  the module says is-valid = False

the repdigits, which the real specification blacklists by name:
  00000000000    -> True
  11111111111    -> True
  55555555555    -> True
  99999999999    -> True

the formula genuinely self-satisfies for those, which is exactly why
the specification carries an explicit blacklist. This module has none.
```

The module computes `sum * 10 % 11` and compares that directly, which agrees
with the official rule everywhere except where the official rule folds a 10
down to 0 — about 17% of well-formed documents.

## Where the two engines differ

Two things, both about inputs you should be rejecting before they get this
far. Calling the class as if it were a sub works under Raku++ and dies under
Rakudo, and a number with a trailing non-digit throws on one engine and
answers `False` on the other.

```raku name="portable"
use Brazilian::FederalDocuments;

# the portable shape: validate the string yourself, then construct
sub cpf-valid(Str $raw) {
    my $digits = $raw.subst(/<-[0..9]>/, '', :g);
    return False unless $digits.chars <= 11;
    return False if $digits.comb.unique.elems == 1;   # the blacklist the module lacks
    FederalDocuments::CPF.new(number => $digits).is-valid
}

for '000.000.001-91', '0000000019a', '11111111111', '' -> $raw {
    say sprintf('  %-18s -> %s', $raw.raku, cpf-valid($raw));
}
say '';
say 'without that guard, "0000000019a" throws X::Str::Numeric on Raku++';
say 'and returns False on Rakudo, and `FederalDocuments::CPF(number => 191)`';
say 'builds an instance on Raku++ and raises "No such method CALL-ME" on';
say 'Rakudo. Always write .new, and always sanitise first.';
```

```output
  "000.000.001-91"   -> True
  "0000000019a"      -> False
  "11111111111"      -> False
  ""                 -> True

without that guard, "0000000019a" throws X::Str::Numeric on Raku++
and returns False on Rakudo, and `FederalDocuments::CPF(number => 191)`
builds an instance on Raku++ and raises "No such method CALL-ME" on
Rakudo. Always write .new, and always sanitise first.
```
