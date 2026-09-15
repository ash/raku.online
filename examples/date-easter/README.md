# Date::Easter — the examples

Every example from [the Date::Easter page](https://raku.online/modules/date-easter/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Easter   # or: zef install Date::Easter
rakupp 01-easter.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-easter.raku`](01-easter.raku) | Computing Easter | checked |
| [`02-invariants.raku`](02-invariants.raku) | The invariants | checked |
| [`03-feasts.raku`](03-feasts.raku) | The moveable feasts | checked |
| [`04-keyof-trap.raku`](04-keyof-trap.raku) | The one thing to know | checked |
