# Number::Bytes::Human — the examples

Every example from [the Number::Bytes::Human page](https://raku.online/modules/number-bytes-human/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Number::Bytes::Human   # or: zef install Number::Bytes::Human
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
| [`02-parse.raku`](02-parse.raku) | Parsing | checked |
| [`03-class.raku`](03-class.raku) | The class | checked |
| [`04-case-trap.raku`](04-case-trap.raku) | The one thing to know | checked |
