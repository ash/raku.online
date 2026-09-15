# Lazy::Static — the examples

Every example from [the Lazy::Static page](https://raku.online/modules/lazy-static/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lazy::Static   # or: zef install Lazy::Static
rakupp 01-lazy.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lazy.raku`](01-lazy.raku) | Making something lazy | checked |
| [`02-threads.raku`](02-threads.raku) | Under contention | checked |
| [`03-failure-trap.raku`](03-failure-trap.raku) | The one thing to know | checked |
