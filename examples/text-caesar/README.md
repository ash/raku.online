# Text::Caesar — the examples

Every example from [the Text::Caesar page](https://raku.online/modules/text-caesar/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Caesar   # or: zef install Text::Caesar
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Encrypting and decrypting | checked |
| [`02-keys.raku`](02-keys.raku) | Encrypting and decrypting | checked |
| [`03-case.raku`](03-case.raku) | The case trap | checked |
| [`04-lossy.raku`](04-lossy.raku) | The one thing to know | checked |
| [`05-qualified.raku`](05-qualified.raku) | Where the two engines differ | checked |
