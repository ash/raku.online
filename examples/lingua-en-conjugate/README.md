# Lingua::EN::Conjugate — the examples

Every example from [the Lingua::EN::Conjugate page](https://raku.online/modules/lingua-en-conjugate/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::EN::Conjugate   # or: zef install Lingua::EN::Conjugate
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Conjugating | checked |
| [`02-negation.raku`](02-negation.raku) | Conjugating | checked |
| [`03-guard.raku`](03-guard.raku) | The guard you will hit first | checked |
| [`04-doubling.raku`](04-doubling.raku) | The one thing to know | checked |
| [`05-irregulars.raku`](05-irregulars.raku) | The one thing to know | checked |
| [`06-mod.raku`](06-mod.raku) | Where the two engines differ | checked |
