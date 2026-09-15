# Proc::Easy — the examples

Every example from [the Proc::Easy page](https://raku.online/modules/proc-easy/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Proc::Easy   # or: zef install Proc::Easy
rakupp 01-run.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-run.raku`](01-run.raku) | Running a command | checked |
| [`02-selectors.raku`](02-selectors.raku) | Asking for one of them | checked |
| [`03-dir.raku`](03-dir.raku) | Running somewhere else | checked |
| [`04-no-shell.raku`](04-no-shell.raku) | The one thing to know | checked |
