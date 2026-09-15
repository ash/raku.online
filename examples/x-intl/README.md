# X::Intl — the examples

Every example from [the X::Intl page](https://raku.online/modules/x-intl/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install X::Intl   # or: zef install X::Intl
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Composing it | checked |
| [`02-warn.raku`](02-warn.raku) | The warning half | checked |
| [`03-parents.raku`](03-parents.raku) | The one thing to know | checked |
| [`04-sibling.raku`](04-sibling.raku) | Where the two engines differ | checked |
