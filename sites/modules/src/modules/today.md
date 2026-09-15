---
name: Today
version: 0.0.8
auth: zef:lizmat
kind: Distribution · time
summary: One term, `today`, that evaluates to `Date.today` — five lines, and
  a sharp lesson about what a term is.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Today
source: https://github.com/lizmat/Today.git
---

## What it is for

`Date.today` is nine characters of ceremony around an idea that deserves one
word. This distribution adds that word as a **term**, so `today` reads like a
literal wherever a `Date` belongs.

That is the entire module: a `sub today(--> Date:D)` and a custom `sub EXPORT`
that publishes it under the single key `'&term:<today>'`.

## Using it

```raku name="basics"
use Today;

say 'today ~~ Date            : ', today ~~ Date;
say 'today == Date.today      : ', today == Date.today;
say 'today.^name              : ', today.^name;
say 'yesterday                : ', (today - 1) == Date.today.earlier(:1day);
say 'a week out               : ', (today.later(:7days) - today) == 7;
say 'two reads agree          : ', today == today;
say '';
say 'it reads like a literal, which is the point:';
say '  days left in the month : ',
    today.later(:1month).truncated-to('month') - today;
```

```output
today ~~ Date            : True
today == Date.today      : True
today.^name              : Date
yesterday                : True
a week out               : True
two reads agree          : True

it reads like a literal, which is the point:
  days left in the month : 16
```

Nothing is asserted about the *value* here, because the value is a clock read.
Every line above is a property that holds whatever day you run it on.

## What it is not

```raku name="not-a-package"
use Today;

say 'what the module publishes : one term, evaluating to ', today.WHAT.^name;
say '';
say '`Today` itself is not a type, not a class and not a package —';
say 'naming it is an error on both engines (at compile time on Rakudo,';
say 'at run time on Raku++). The distribution name and the symbol it';
say 'installs have nothing to do with each other.';
```

```output
what the module publishes : one term, evaluating to Date

`Today` itself is not a type, not a class and not a package —
naming it is an error on both engines (at compile time on Rakudo,
at run time on Raku++). The distribution name and the symbol it
installs have nothing to do with each other.
```

## The one thing to know

`today` is a term, not a sub. `&today` and `today()` are not part of what the
module publishes — and that is exactly where the two engines part company.

```raku name="term"
use Today;

say 'the term evaluates to a Date : ', today.WHAT.^name;
say '';
say 'these two spellings are NOT part of the API:';
say '  &today      — a code object under that name';
say '  today()     — a call with empty parentheses';
say '';
say 'Raku++ accepts both; Rakudo refuses both at COMPILE time with';
say '"Undeclared routine: today". Code written and tested on Raku++ that';
say 'stores &today in a variable, passes it to map, or writes today() out';
say 'of habit does not compile on Rakudo at all.';
```

```output
the term evaluates to a Date : Date

these two spellings are NOT part of the API:
  &today      — a code object under that name
  today()     — a call with empty parentheses

Raku++ accepts both; Rakudo refuses both at COMPILE time with
"Undeclared routine: today". Code written and tested on Raku++ that
stores &today in a variable, passes it to map, or writes today() out
of habit does not compile on Rakudo at all.
```

Because the failure is at compile time, no `try` will save you and no test
run on the permissive engine will find it. Write the bare term.

## Where the two engines differ

Exactly the gap above, and it is a Raku++ permissiveness, not a module bug:
the module publishes only the `&term:<today>` key, and Rakudo honours that
strictly. Raku++ additionally makes the name visible as an ordinary routine.

```raku name="portable"
use Today;

# the portable spelling, if you need a callable: wrap the term yourself
my &right-now = { today };
say 'a wrapper block   : ', right-now() ~~ Date;
say 'mapped over a list: ', (^3).map({ today.later(:days($_)) }).map(*.day-of-week).elems;
say '';
say 'without the `use`, the term is not there — it is properly lexical';
say 'on both engines, so importing it does not leak into your callers.';
```

```output
a wrapper block   : True
mapped over a list: 3

without the `use`, the term is not there — it is properly lexical
on both engines, so importing it does not leak into your callers.
```

One thing that is the same on both and worth not over-reading: `today ===
today` is `True`. That is value identity of `Date`, not caching — the term
calls `Date.today` afresh every time it appears.
