# Lingua::EN::Stopwords — the examples

Every example from [the Lingua::EN::Stopwords page](https://raku.online/modules/lingua-en-stopwords/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::EN::Stopwords   # or: zef install Lingua::EN::Stopwords
rakupp 01-short.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-short.raku`](01-short.raku) | The three lists | checked |
| [`02-sizes.raku`](02-sizes.raku) | The three lists | checked |
| [`03-mutable.raku`](03-mutable.raku) | The one thing to know | checked |
| [`04-one-list.raku`](04-one-list.raku) | Where the two engines differ | checked |
