# YAMLish — the examples

Every example from [the YAMLish page](https://raku.online/ecosystem/yamlish/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install YAMLish   # or: zef install YAMLish
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.7.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-save.raku`](02-save.raku) | Writing it back | checked |
| [`03-stream.raku`](03-stream.raku) | More than one document | checked |
| [`04-types.raku`](04-types.raku) | What the scalars become | checked |
| [`05-norway.raku`](05-norway.raku) | The Norway problem | checked |
| [`06-anchors.raku`](06-anchors.raku) | What it does not do | checked |
