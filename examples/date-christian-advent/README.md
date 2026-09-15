# Date::Christian::Advent — the examples

Every example from [the Date::Christian::Advent page](https://raku.online/modules/date-christian-advent/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Christian::Advent   # or: zef install Date::Christian::Advent
rakupp 01-advent.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-advent.raku`](01-advent.raku) | Finding Advent Sunday | checked |
| [`02-three.raku`](02-three.raku) | The three routines | checked |
| [`03-untyped.raku`](03-untyped.raku) | Where the two engines differ | checked |
