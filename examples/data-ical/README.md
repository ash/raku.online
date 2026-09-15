# Data::ICal — the examples

Every example from [the Data::ICal page](https://raku.online/modules/data-ical/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::ICal   # or: zef install Data::ICal
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Parsing | checked |
| [`02-failures.raku`](02-failures.raku) | Malformed input throws | checked |
| [`03-roundtrip.raku`](03-roundtrip.raku) | The one thing to know | checked |
| [`04-empty-units.raku`](04-empty-units.raku) | Four units that are empty files | checked |
| [`05-crlf.raku`](05-crlf.raku) | Where the two engines differ | checked |
