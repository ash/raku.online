# Locale::Dates — the examples

Every example from [the Locale::Dates page](https://raku.online/modules/locale-dates/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Locale::Dates   # or: zef install Locale::Dates
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Asking for a locale | checked |
| [`02-indexing.raku`](02-indexing.raku) | Asking for a locale | checked |
| [`03-fallback.raku`](03-fallback.raku) | The one thing to know | checked |
| [`04-quirks.raku`](04-quirks.raku) | What the tables actually contain | checked |
| [`05-containers.raku`](05-containers.raku) | Where the two engines differ | checked |
