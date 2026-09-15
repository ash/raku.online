# P5getservbyname — the examples

Every example from [the P5getservbyname page](https://raku.online/modules/p5getservbyname/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5getservbyname   # or: zef install P5getservbyname
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | Looking a service up | checked |
| [`02-scalar.raku`](02-scalar.raku) | Scalar context | checked |
| [`03-enumerate.raku`](03-enumerate.raku) | Enumerating | checked |
| [`04-proto-trap.raku`](04-proto-trap.raku) | The one thing to know | checked |
| [`05-miss.raku`](05-miss.raku) | Where the two engines differ | checked |
