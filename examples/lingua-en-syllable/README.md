# Lingua::EN::Syllable — the examples

Every example from [the Lingua::EN::Syllable page](https://raku.online/modules/lingua-en-syllable/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::EN::Syllable   # or: zef install Lingua::EN::Syllable
rakupp 01-syllable.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-syllable.raku`](01-syllable.raku) | Counting syllables | checked |
| [`02-input.raku`](02-input.raku) | Case and punctuation | checked |
| [`03-floor-trap.raku`](03-floor-trap.raku) | The one thing to know | checked |
| [`04-accuracy.raku`](04-accuracy.raku) | Where the two engines differ | checked |
