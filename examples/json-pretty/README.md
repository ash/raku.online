# JSON::Pretty — the examples

Every example from [the JSON::Pretty page](https://raku.online/modules/json-pretty/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Pretty   # or: zef install JSON::Pretty
rakupp 01-pretty.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-pretty.raku`](01-pretty.raku) | Formatted output | checked |
| [`02-replaces.raku`](02-replaces.raku) | The one thing to know | checked |
