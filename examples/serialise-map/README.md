# Serialise::Map — the examples

Every example from [the Serialise::Map page](https://raku.online/modules/serialise-map/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Serialise::Map   # or: zef install Serialise::Map
rakupp 01-compose.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-compose.raku`](01-compose.raku) | Composing it | checked |
| [`02-buys.raku`](02-buys.raku) | What the role buys you | checked |
| [`03-instance-trap.raku`](03-instance-trap.raku) | The one thing to know | checked |
