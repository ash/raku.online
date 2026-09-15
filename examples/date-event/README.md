# Date::Event — the examples

Every example from [the Date::Event page](https://raku.online/modules/date-event/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Event   # or: zef install Date::Event
rakupp 01-event.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-event.raku`](01-event.raku) | An event | checked |
| [`02-gid-order.raku`](02-gid-order.raku) | The one thing to know | checked |
