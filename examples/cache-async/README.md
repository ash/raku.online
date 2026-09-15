# Cache::Async — the examples

Every example from [the Cache::Async page](https://raku.online/modules/cache-async/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Cache::Async   # or: zef install Cache::Async
rakupp 01-cache.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-cache.raku`](01-cache.raku) | Caching | checked |
| [`02-interface.raku`](02-interface.raku) | The rest of the interface | checked |
| [`03-ages.raku`](03-ages.raku) | Ages and validation | checked |
| [`04-poison-trap.raku`](04-poison-trap.raku) | The one thing to know | checked |
