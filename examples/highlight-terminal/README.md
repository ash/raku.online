# Highlight::Terminal — the examples

Every example from [the Highlight::Terminal page](https://raku.online/modules/highlight-terminal/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Highlight::Terminal   # or: zef install Highlight::Terminal
rakupp 01-hl.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-hl.raku`](01-hl.raku) | Composing and colouring | checked |
| [`02-fallback.raku`](02-fallback.raku) | The fallback | checked |
| [`03-nesting.raku`](03-nesting.raku) | The one thing to know | checked |
