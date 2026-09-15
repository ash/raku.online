# Trap — the examples

Every example from [the Trap page](https://raku.online/modules/trap/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Trap   # or: zef install Trap
rakupp 01-trap.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-trap.raku`](01-trap.raku) | Capturing output | checked |
| [`02-both.raku`](02-both.raku) | Both handles at once | checked |
| [`03-not-a-handle.raku`](03-not-a-handle.raku) | The one thing to know | checked |
