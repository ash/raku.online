# P5getnetbyname — the examples

Every example from [the P5getnetbyname page](https://raku.online/modules/p5getnetbyname/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5getnetbyname   # or: zef install P5getnetbyname
rakupp 01-enumerate.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-enumerate.raku`](01-enumerate.raku) | Reading the database | checked |
| [`02-miss.raku`](02-miss.raku) | Misses | checked |
| [`03-aliases-trap.raku`](03-aliases-trap.raku) | The one thing to know | checked |
