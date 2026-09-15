# Dictionary::Create — the examples

Every example from [the Dictionary::Create page](https://raku.online/modules/dictionary-create/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Dictionary::Create   # or: zef install Dictionary::Create
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Building an article | checked |
| [`02-tags.raku`](02-tags.raku) | The tag builders | checked |
| [`03-accumulator.raku`](03-accumulator.raku) | The accumulator | checked |
| [`04-font.raku`](04-font.raku) | The one thing to know | checked |
| [`05-language.raku`](05-language.raku) | Where the two engines differ | checked |
