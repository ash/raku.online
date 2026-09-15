# Lingua::Stem::Es — the examples

Every example from [the Lingua::Stem::Es page](https://raku.online/modules/lingua-stem-es/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::Stem::Es   # or: zef install Lingua::Stem::Es
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Stemming | checked |
| [`02-merges.raku`](02-merges.raku) | The one thing to know | checked |
| [`03-irregular.raku`](03-irregular.raku) | The one thing to know | checked |
| [`04-pitfalls.raku`](04-pitfalls.raku) | Two shapes that will bite you | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
