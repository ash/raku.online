# Method::Also — the examples

Every example from [the Method::Also page](https://raku.online/modules/method-also/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Method::Also   # or: zef install Method::Also
rakupp 01-aliases.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-aliases.raku`](01-aliases.raku) | What it is for | checked |
| [`02-multi-and-gist.raku`](02-multi-and-gist.raku) | It composes with multis and coercions | checked |
