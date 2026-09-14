# Terminal::WCWidth — the examples

Every example from [the Terminal::WCWidth page](https://raku.online/modules/terminal-wcwidth/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Terminal::WCWidth   # or: zef install Terminal::WCWidth
rakupp 01-widths.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-widths.raku`](01-widths.raku) | Two subs, one question | checked |
| [`02-align.raku`](02-align.raku) | Two subs, one question | checked |
| [`03-refusal.raku`](03-refusal.raku) | The one thing to know | checked |
