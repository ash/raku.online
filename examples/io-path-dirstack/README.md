# IO::Path::Dirstack — the examples

Every example from [the IO::Path::Dirstack page](https://raku.online/modules/io-path-dirstack/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install IO::Path::Dirstack   # or: zef install IO::Path::Dirstack
rakupp 01-pushd.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-pushd.raku`](01-pushd.raku) | Pushing and popping | checked |
| [`02-global.raku`](02-global.raku) | The stack is process-global | checked |
| [`03-failure-trap.raku`](03-failure-trap.raku) | The one thing to know | checked |
