---
name: Mortgage
version: *
auth: github:teodozjan
kind: Distribution · finance
summary: The standard annuity formulas plus a month-by-month amortisation —
  correct arithmetic behind a parameter named `$p` that is not a payment.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:teodozjan/Mortgage
source: git://github.com/teodozjan/mortage6.git
---

## What it is for

A level-payment loan has four closed-form answers: what you pay each month,
what you still owe after *p* payments, what a lump sum grows to, and how the
three rate conventions relate. This distribution has all four as free
functions, plus a class that runs the amortisation month by month and
accumulates recurring annual costs.

## The formulas

```raku name="basics"
use Mortgage;

my $L = 300_000;
my $c = rate-monthly(4.8);       # the ANNUAL PERCENT, not a fraction
my $n = 360;

say 'percent(4.8)       = ', percent(4.8);
say 'rate-monthly(4.8)  = ', $c;
say 'basis-point(164)   = ', basis-point(164);
say '';
my $payment = calculate-payment($c, $n, $L);
say 'monthly payment    = ', $payment.round(0.01);
say '  closed form      = ', ($L * $c / (1 - (1 + $c) ** -$n)).round(0.01);
say '';
say 'remaining balance after p payments:';
for 0, 1, 180, 359, 360 -> $p {
    say sprintf('  p=%-4d %12.2f', $p, calculate-balance($c, $n, $L, $p));
}
say '';
say 'future value : ', calculate-fvalue(1000, 0.05, 10).round(0.0001);
say '  1000 * 1.05**10 = ', (1000 * 1.05 ** 10).round(0.0001);
```

```output
percent(4.8)       = 0.048
rate-monthly(4.8)  = 0.004
basis-point(164)   = 0.0164

monthly payment    = 1574
  closed form      = 1574

remaining balance after p payments:
  p=0       300000.00
  p=1       299626.00
  p=180     201687.21
  p=359       1567.73
  p=360          0.00

future value : 1628.8946
  1000 * 1.05**10 = 1628.8946
```

The numbers are right: the payment matches `L·c/(1−(1+c)⁻ⁿ)` to thirteen
decimal places, and hand-simulating 360 payments of it lands the balance on
zero.

## The one thing to know

`calculate-balance($c, $n, $L, $p)`'s fourth argument is a **period number**,
not a payment — despite being named `$p`, described as the payment in the
source comments, and sitting exactly where a payment amount belongs in every
other amortisation API.

```raku name="period"
use Mortgage;

my ($L, $c, $n) = 300_000, rate-monthly(4.8), 360;
my $payment = calculate-payment($c, $n, $L);

say 'monthly payment                     : ', $payment.round(0.01);
say '';
say 'calculate-balance(c, n, L, 180)     : ',
    calculate-balance($c, $n, $L, 180).round(0.01), '   <- p = period number';
say 'calculate-balance(c, n, L, $payment): ',
    calculate-balance($c, $n, $L, $payment).round(0.01), '   <- p = the payment';
say '';
say 'that second line computes (1+c)**1574 and answers a NEGATIVE balance';
say 'over a hundred times the size of the loan, with no exception and no';
say 'warning. The proof that p is a period: p=0 returns the full loan and';
say 'p=n returns zero.';
```

```output
monthly payment                     : 1574

calculate-balance(c, n, L, 180)     : 201687.21   <- p = period number
calculate-balance(c, n, L, $payment): -49686484.24   <- p = the payment

that second line computes (1+c)**1574 and answers a NEGATIVE balance
over a hundred times the size of the loan, with no exception and no
warning. The proof that p is a period: p=0 returns the full loan and
p=n returns zero.
```

There is a second naming trap in the same family: `rate-monthly` wants the
annual **percent**, so the natural-looking `rate-monthly(percent(4.8))` is a
hundred times too small.

```raku name="rate-trap"
use Mortgage;

my ($L, $n) = 300_000, 360;
for 'rate-monthly(4.8)'          => rate-monthly(4.8),
    'rate-monthly(percent(4.8))' => rate-monthly(percent(4.8)) -> $p {
    say sprintf('  %-28s = %-10s -> payment %s',
                $p.key, $p.value, calculate-payment($p.value, $n, $L).round(0.01));
}
say '';
say 'percent and rate-monthly look like a matched pair and must never be';
say 'composed. rate-monthly is `annual percent / 1200`, nothing else.';
```

```output
  rate-monthly(4.8)            = 0.004      -> payment 1574
  rate-monthly(percent(4.8))   = 0.00004    -> payment 839.36

percent and rate-monthly look like a matched pair and must never be
composed. rate-monthly is `annual percent / 1200`, nothing else.
```

## The class

```raku name="class"
use Mortgage;

my $c = rate-monthly(4.8);
my $m = Mortgage.new(
    currency       => 'EUR',
    bank           => 'BANK',
    loan-left      => 300_000,
    interest_rate  => $c,
    mortages       => 360,
    mortage        => calculate-payment($c, 360, 300_000),
    total_interest => 0,
    total_cost     => 0,
);
$m.add(Mortgage::AnnualCostConst.new(from => 1, to => 360, value => 10));
$m.calc;
print $m.gist;
say '';
say 'note the four extra constructor arguments. `calc` reads $!mortage,';
say '$!total_interest and $!total_cost before it ever writes them, and';
say 'none of the three has a default — so the documented three-argument';
say 'construction leaves them as Numeric type objects and the run is';
say 'silently wrong (Raku++) or dies in `gist` (Rakudo). Seed all four.';
say '';
say 'calc is DESTRUCTIVE and not idempotent — a second call resumes from';
say 'the mutated balance rather than restarting. There is no reset.';
say '';
say 'the three concrete cost classes are AnnualCostPercentage (balance x';
say 'rate), AnnualCostMort (payment x rate) and AnnualCostConst (a fixed';
say 'value). The base AnnualCost.get is a `!!!` stub.';
```

```output
BANK
Mortgage 1574 EUR
Balance: 0 EUR
Basic interests: 266638.58 EUR
Other costs: 3600 EUR
Total cost: 270238.58
Type used for cost (Int)
Type used for calculation (Num)
note the four extra constructor arguments. `calc` reads $!mortage,
$!total_interest and $!total_cost before it ever writes them, and
none of the three has a default — so the documented three-argument
construction leaves them as Numeric type objects and the run is
silently wrong (Raku++) or dies in `gist` (Rakudo). Seed all four.

calc is DESTRUCTIVE and not idempotent — a second call resumes from
the mutated balance rather than restarting. There is no reset.

the three concrete cost classes are AnnualCostPercentage (balance x
rate), AnnualCostMort (payment x rate) and AnnualCostConst (a fixed
value). The base AnnualCost.get is a `!!!` stub.
```

## Where the two engines differ

`gist` dies under Rakudo unless at least one cost has been added: `total_cost`
has no default, so on a cost-free mortgage it is still the `Numeric` type
object when `gist` calls `.round(0.01)`. Raku++ masks that — `Numeric.round`
answers `0` there — and prints `Other costs: 0`.

```raku name="portable"
use Mortgage;

# the constructor shape that behaves the same on both engines
sub mortgage($principal, $annual-percent, $months) {
    my $c = rate-monthly($annual-percent);
    Mortgage.new(
        currency       => 'EUR',
        bank           => 'BANK',
        loan-left      => $principal,
        interest_rate  => $c,
        mortages       => $months,
        mortage        => calculate-payment($c, $months, $principal),
        total_interest => 0,
        total_cost     => 0,
    )
}

my $m = mortgage(300_000, 4.8, 360);
$m.add(Mortgage::AnnualCostConst.new(from => 1, to => 360, value => 10));
say 'monthly : ', $m.mortage.round(0.01);
$m.calc;
say 'balance : ', $m.loan-left.round(0.01);
say 'interest: ', $m.total_interest.round(0.01);
say 'cost    : ', $m.total_cost.round(0.01);
say '';
say 'without the three zero seeds, `say $mortgage` raises "No such method';
say 'round for invocant of type Numeric" on Rakudo and prints 0 on Raku++ —';
say 'and `say $m` is the first thing anyone does.';
```

```output
monthly : 1574
balance : 0
interest: 266638.58
cost    : 3600

without the three zero seeds, `say $mortgage` raises "No such method
round for invocant of type Numeric" on Rakudo and prints 0 on Raku++ —
and `say $m` is the first thing anyone does.
```

One numeric note, identical on both engines: `rate-monthly(4.8)` is an exact
`Rat` (1/250), but `(1+$c)**$n` returns a `Num`, so every result is floating
point unless you build the inputs as `FatRat` yourself. `gist` says so on its
last line. And `calculate-fvalue-series` is declared in the file with no
`is export`, so it is unreachable from a `use`.
