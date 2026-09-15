# Email::MessageID — the examples

Every example from [the Email::MessageID page](https://raku.online/modules/email-messageid/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Email::MessageID   # or: zef install Email::MessageID
rakupp 01-shape.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-shape.raku`](01-shape.raku) | Minting an identifier | checked |
| [`02-explicit.raku`](02-explicit.raku) | Supplying your own halves | checked |
| [`03-disclosure.raku`](03-disclosure.raku) | The one thing to know | checked |
