# XML::Entity::HTML — the examples

Every example from [the XML::Entity::HTML page](https://raku.online/modules/xml-entity-html/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install XML::Entity::HTML   # or: zef install XML::Entity::HTML
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Encoding and decoding | checked |
| [`02-unknown.raku`](02-unknown.raku) | What it does with input it does not know | checked |
| [`03-numeric-dead.raku`](03-numeric-dead.raku) | The one thing to know | checked |
| [`04-inverse.raku`](04-inverse.raku) | Encoding is not the inverse of decoding | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
