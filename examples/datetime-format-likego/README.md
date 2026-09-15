# DateTime::Format::LikeGo — the examples

Every example from [the DateTime::Format::LikeGo page](https://raku.online/modules/datetime-format-likego/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install DateTime::Format::LikeGo   # or: zef install DateTime::Format::LikeGo
rakupp 01-format.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-format.raku`](01-format.raku) | Formatting | checked |
| [`02-tokens.raku`](02-tokens.raku) | The tokens it knows | checked |
| [`03-reference-trap.raku`](03-reference-trap.raku) | The one thing to know | checked |
