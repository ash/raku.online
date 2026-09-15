# Lingua::Conjunction — the examples

Every example from [the Lingua::Conjunction page](https://raku.online/modules/lingua-conjunction/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::Conjunction   # or: zef install Lingua::Conjunction
rakupp 01-conjunction.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-conjunction.raku`](01-conjunction.raku) | Building a phrase | checked |
| [`02-switches.raku`](02-switches.raku) | The switches | checked |
| [`03-langs.raku`](03-langs.raku) | Other languages | checked |
| [`04-separator-trap.raku`](04-separator-trap.raku) | The one thing to know | checked |
