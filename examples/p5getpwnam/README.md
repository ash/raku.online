# P5getpwnam — the examples

Every example from [the P5getpwnam page](https://raku.online/modules/p5getpwnam/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5getpwnam   # or: zef install P5getpwnam
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | Looking a user up | checked |
| [`02-enumerate.raku`](02-enumerate.raku) | Enumerating | checked |
| [`03-arity-trap.raku`](03-arity-trap.raku) | The one thing to know | checked |
