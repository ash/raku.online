# HTML::EscapeUtils — the examples

Every example from [the HTML::EscapeUtils page](https://raku.online/modules/html-escapeutils/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install HTML::EscapeUtils   # or: zef install HTML::EscapeUtils
rakupp 01-escape.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-escape.raku`](01-escape.raku) | Escaping | checked |
| [`02-attributes.raku`](02-attributes.raku) | Escaping | checked |
| [`03-unescape.raku`](03-unescape.raku) | Unescaping | checked |
| [`04-unknown.raku`](04-unknown.raku) | The one thing to know | checked |
| [`05-cost.raku`](05-cost.raku) | Cost | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
