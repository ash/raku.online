# P5getprotobyname — the examples

Every example from [the P5getprotobyname page](https://raku.online/modules/p5getprotobyname/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5getprotobyname   # or: zef install P5getprotobyname
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | Looking a protocol up | checked |
| [`02-enumerate.raku`](02-enumerate.raku) | Enumerating | checked |
| [`03-miss.raku`](03-miss.raku) | Misses | checked |
| [`04-zero-trap.raku`](04-zero-trap.raku) | The one thing to know | checked |
