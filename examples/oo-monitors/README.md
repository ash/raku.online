# OO::Monitors — the examples

Every example from [the OO::Monitors page](https://raku.online/modules/oo-monitors/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install OO::Monitors   # or: zef install OO::Monitors
rakupp 01-declare.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-declare.raku`](01-declare.raku) | A monitor is a class that serialises itself | checked |
| [`02-reentrant.raku`](02-reentrant.raku) | A monitor is a class that serialises itself | checked |
| [`03-escapes.raku`](03-escapes.raku) | The one thing to know | checked |
