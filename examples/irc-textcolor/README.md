# IRC::TextColor — the examples

Every example from [the IRC::TextColor page](https://raku.online/modules/irc-textcolor/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install IRC::TextColor   # or: zef install IRC::TextColor
rakupp 01-colours.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-colours.raku`](01-colours.raku) | Colour, style, and a bridge from ANSI | checked |
| [`02-unknown-names.raku`](02-unknown-names.raku) | The one thing to know | checked |
