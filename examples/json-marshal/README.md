# JSON::Marshal — the examples

Every example from [the JSON::Marshal page](https://raku.online/modules/json-marshal/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Marshal   # or: zef install JSON::Marshal
rakupp 01-into-json.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-into-json.raku`](01-into-json.raku) | Objects into documents | checked |
| [`02-traits.raku`](02-traits.raku) | Objects into documents | checked |
| [`03-pretty-default.raku`](03-pretty-default.raku) | The one thing to know | checked |
