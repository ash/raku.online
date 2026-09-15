# Lingua::Pangram — the examples

Every example from [the Lingua::Pangram page](https://raku.online/modules/lingua-pangram/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::Pangram   # or: zef install Lingua::Pangram
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Checking | checked |
| [`02-russian.raku`](02-russian.raku) | Checking | checked |
| [`03-sharp-s.raku`](03-sharp-s.raku) | The one thing to know | checked |
| [`04-wrappers.raku`](04-wrappers.raku) | The alphabets the wrappers pin | checked |
| [`05-digraph.raku`](05-digraph.raku) | Where the two engines differ | checked |
