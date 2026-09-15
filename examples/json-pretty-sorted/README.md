# JSON::Pretty::Sorted — the examples

Every example from [the JSON::Pretty::Sorted page](https://raku.online/modules/json-pretty-sorted/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Pretty::Sorted   # or: zef install JSON::Pretty::Sorted
rakupp 01-write.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-write.raku`](01-write.raku) | Writing JSON | checked |
| [`02-nested.raku`](02-nested.raku) | Nested documents | checked |
| [`03-read.raku`](03-read.raku) | Reading back | checked |
| [`04-sorter-trap.raku`](04-sorter-trap.raku) | The one thing to know | checked |
