# XML — the examples

Every example from [the XML page](https://raku.online/ecosystem/xml/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install XML   # or: zef install XML
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.6.0 (dev build) and under Rakudo 2026.07, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-navigate.raku`](02-navigate.raku) | Finding things | checked |
| [`03-build.raku`](03-build.raku) | Building a document | checked |
| [`04-escaping.raku`](04-escaping.raku) | The sharp edge: nothing is escaped for you | checked |
