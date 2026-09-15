# CCColor — the examples

Every example from [the CCColor page](https://raku.online/modules/cccolor/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install CCColor   # or: zef install CCColor
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Converting | checked |
| [`02-lowercase.raku`](02-lowercase.raku) | The one thing to know | checked |
| [`03-shorthand.raku`](03-shorthand.raku) | The CSS shorthand is wrong, not unsupported | checked |
| [`04-edges.raku`](04-edges.raku) | Where the two engines differ | checked |
