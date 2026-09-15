# Avolution::Emoji — the examples

Every example from [the Avolution::Emoji page](https://raku.online/modules/avolution-emoji/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Avolution::Emoji   # or: zef install Avolution::Emoji
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Using it | checked |
| [`02-broken.raku`](02-broken.raku) | The one thing to know | checked |
| [`03-collisions.raku`](03-collisions.raku) | The table is not what the names say | checked |
| [`04-portable.raku`](04-portable.raku) | Where the two engines differ | checked |
