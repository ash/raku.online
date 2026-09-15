# HTML::Parser — the examples

Every example from [the HTML::Parser page](https://raku.online/modules/html-parser/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install HTML::Parser   # or: zef install HTML::Parser
rakupp 01-declaration.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-declaration.raku`](01-declaration.raku) | The whole declaration | checked |
| [`02-compose.raku`](02-compose.raku) | Using it as it is meant | checked |
| [`03-stub.raku`](03-stub.raku) | The one thing to know | checked |
| [`04-strict.raku`](04-strict.raku) | The contract is stricter than HTML | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
