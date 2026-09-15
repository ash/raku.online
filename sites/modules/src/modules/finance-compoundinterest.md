---
name: Finance::CompoundInterest
version: 0.1.0
auth: none stated
kind: Distribution · finance
summary: Four time-value-of-money formulas — future value of a lump sum or a
  payment stream, and the two inverses that solve for periods or payment size.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Finance::CompoundInterest
source: git://github.com/peelle/Finance-CompoundInterest.git
---

## What it is for

Four questions come up constantly in anything that touches money over time.
What will this lump sum be worth? What will these regular payments add up to?
How long until they reach a target? How large must each one be?

They are four rearrangements of the same formula, and this distribution is
seventeen lines that provide all four.

## The four formulas

```raku name="finance"
use Finance::CompoundInterest;

say '1000 at 5% compounded monthly for 10 years:';
say '  ', compound_interest(1000.0, 0.05, 12.0, 10.0).round(0.01);
say '';
say '200 a month for 60 months at 0.5% a month:';
my $fv = compound_interest_with_payments(200.0, 0.005, 60.0);
say '  ', $fv.round(0.01);
say '';
say 'the two inverses of that same stream:';
say '  periods needed for 13954.01 : ', ciwp_payment_period(13954.01, 0.005, 200.0).round(0.0001);
say '  payment size for 13954.01   : ', ciwp_payment_size(13954.01, 0.005, 60.0).round(0.01);
```

```output
1000 at 5% compounded monthly for 10 years:
  1647.01

200 a month for 60 months at 0.5% a month:
  13954.01

the two inverses of that same stream:
  periods needed for 13954.01 : 60
  payment size for 13954.01   : 200
```

The three payment-stream results are mutually consistent, which is the check
worth running: 200 a month for 60 months at half a percent is 13,954.01, and
both inverses recover 60 and 200.

## A case you can verify by hand

```raku name="simple"
use Finance::CompoundInterest;

say '1000 at 10% compounded once a year for 3 years:';
say '  computed : ', compound_interest(1000.0, 0.10, 1.0, 3.0).round(0.01);
say '  by hand  : ', (1000 * 1.1 ** 3).round(0.01);
say '';
say 'return type : ', compound_interest(1000.0, 0.10, 1.0, 3.0).^name;
```

```output
1000 at 10% compounded once a year for 3 years:
  computed : 1331
  by hand  : 1331

return type : Num
```

Note the return type. Every parameter is a `Rat()` coercion and every result
is a **`Num`**, because raising to a rational power leaves the rational
domain. Do not expect exact decimal money out of this; round at the point of
display.

## The one thing to know

One parameter out of thirteen is not a coercion type, and only that one
refuses an `Int` or a `Num`.

```raku name="rat-trap"
use Finance::CompoundInterest;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-58s %s', $label, $! ?? 'refused' !! 'ok -> ' ~ $r.round(0.0001));
}

attempt 'compound_interest(1000, 1/20, 12, 10)  — Int and Rat',
        { compound_interest(1000, 1/20, 12, 10) };
attempt 'compound_interest(1000e0, 0.05e0, 12e0, 10e0)  — all Num',
        { compound_interest(1000e0, 0.05e0, 12e0, 10e0) };
attempt 'ciwp_payment_size(13954.01, 0.005e0, 60)  — Num rate',
        { ciwp_payment_size(13954.01, 0.005e0, 60) };
attempt 'ciwp_payment_period(13954.01, 0.005e0, 200)  — Num rate',
        { ciwp_payment_period(13954.01, 0.005e0, 200) };
attempt 'compound_interest_with_payments(200, 0.005, 60)  — Int and Rat',
        { compound_interest_with_payments(200, 0.005, 60) };
attempt 'compound_interest_with_payments(200, 0.005e0, 60)  — Num rate',
        { compound_interest_with_payments(200, 0.005e0, 60) };
attempt 'compound_interest_with_payments(200, 1, 60)  — Int rate',
        { compound_interest_with_payments(200, 1, 60) };
```

```output
compound_interest(1000, 1/20, 12, 10)  — Int and Rat       ok -> 1647.0095
compound_interest(1000e0, 0.05e0, 12e0, 10e0)  — all Num   ok -> 1647.0095
ciwp_payment_size(13954.01, 0.005e0, 60)  — Num rate       ok -> 200.0001
ciwp_payment_period(13954.01, 0.005e0, 200)  — Num rate    ok -> 60
compound_interest_with_payments(200, 0.005, 60)  — Int and Rat ok -> 13954.0061
compound_interest_with_payments(200, 0.005e0, 60)  — Num rate refused
compound_interest_with_payments(200, 1, 60)  — Int rate    refused
```

Twelve parameters are declared `Rat()`. `compound_interest_with_payments`'s
`$interest_rate` is declared plain `Rat`. So a rate arriving as a `Num` — from
JSON, from a division by a `Num`, from any `.Num` upstream — or as a
whole-number `Int` works in three of the four subs and is a binding failure in
the fourth.

Nothing in the shape of the interface hints at it. Coerce every rate with
`.Rat` before it gets here.

## Where the two engines differ

In one introspection answer, which matters only if you go poking at the
result. Raku++ answers `.numerator` and `.denominator` on the returned `Num`;
Rakudo correctly refuses, since a `Num` has neither. That is an extra method
on one engine's `Num`, not something the module does, but it will mislead
anyone probing the return value.

Every number in this page was identical on both engines.

Two more things to watch, neither engine-related. The argument **orders differ
between siblings**: `compound_interest_with_payments(payment, rate, periods)`
against `ciwp_payment_size(final_value, rate, periods)`, both three positionals
of the same types — so a transposition binds cleanly and gives you a confident
wrong number. And the distribution states no `auth`, so it has no canonical
raku.land path.
