# HTML::Lazy — the examples

Every example from [the HTML::Lazy page](https://raku.online/modules/html-lazy/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install HTML::Lazy   # or: zef install HTML::Lazy
rakupp 01-build.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-build.raku`](01-build.raku) | Building a document | checked |
| [`02-tags.raku`](02-tags.raku) | Tag helpers | checked |
| [`03-compose.raku`](03-compose.raku) | Composition | checked |
| [`04-escape-trap.raku`](04-escape-trap.raku) | The one thing to know | checked |
