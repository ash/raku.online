# Timezones::US — the examples

Every example from [the Timezones::US page](https://raku.online/modules/timezones-us/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Timezones::US   # or: zef install Timezones::US
rakupp 01-transitions.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-transitions.raku`](01-transitions.raku) | The transition instants | checked |
| [`02-is-dst.raku`](02-is-dst.raku) | Asking whether a moment is in DST | checked |
| [`03-zones.raku`](03-zones.raku) | The zone tables | checked |
| [`04-minute.raku`](04-minute.raku) | The one thing to know | checked |
| [`05-mutability.raku`](05-mutability.raku) | Where the two engines differ | checked |
