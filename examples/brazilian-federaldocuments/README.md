# Brazilian::FederalDocuments — the examples

Every example from [the Brazilian::FederalDocuments page](https://raku.online/modules/brazilian-federaldocuments/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Brazilian::FederalDocuments   # or: zef install Brazilian::FederalDocuments
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
| [`02-padding.raku`](02-padding.raku) | The padding | checked |
| [`03-checkdigits.raku`](03-checkdigits.raku) | The one thing to know | checked |
| [`04-portable.raku`](04-portable.raku) | Where the two engines differ | checked |
