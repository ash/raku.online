# Path::Through — the examples

Every example from [the Path::Through page](https://raku.online/modules/path-through/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Path::Through   # or: zef install Path::Through
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | The four verbs | checked |
| [`02-leading-slash.raku`](02-leading-slash.raku) | The one thing to know | checked |
| [`03-empty.raku`](03-empty.raku) | Over-popping | checked |
| [`04-prepend.raku`](04-prepend.raku) | Where the two engines differ | checked |
