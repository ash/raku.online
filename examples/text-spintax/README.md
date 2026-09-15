# Text::Spintax — the examples

Every example from [the Text::Spintax page](https://raku.online/modules/text-spintax/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Spintax   # or: zef install Text::Spintax
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Parsing once, rendering many | checked |
| [`02-nesting.raku`](02-nesting.raku) | Parsing once, rendering many | checked |
| [`03-nodes.raku`](03-nodes.raku) | The node classes | checked |
| [`04-unbalanced.raku`](04-unbalanced.raku) | The one thing to know | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
