# Automata::Cellular — the examples

Every example from [the Automata::Cellular page](https://raku.online/modules/automata-cellular/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Automata::Cellular   # or: zef install Automata::Cellular
rakupp 01-wolfram.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-wolfram.raku`](01-wolfram.raku) | Running a rule | checked |
| [`02-rules.raku`](02-rules.raku) | Other rules, other glyphs | checked |
| [`03-table.raku`](03-table.raku) | The rule table | checked |
| [`04-global-trap.raku`](04-global-trap.raku) | The one thing to know | checked |
