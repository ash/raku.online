# URI — the examples

Every example from [the URI page](https://raku.online/modules/uri/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install URI   # or: zef install URI
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.7.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-authority.raku`](02-authority.raku) | The parts of an authority | checked |
| [`03-ports.raku`](03-ports.raku) | The parts of an authority | checked |
| [`04-ipv6.raku`](04-ipv6.raku) | The parts of an authority | checked |
| [`05-segments.raku`](05-segments.raku) | The path, and its segments | checked |
| [`06-query.raku`](06-query.raku) | The query is not a Hash | checked |
| [`07-decoding.raku`](07-decoding.raku) | The query is not a Hash | checked |
| [`08-build.raku`](08-build.raku) | Building one | checked |
| [`09-absolute.raku`](09-absolute.raku) | Absolute, relative, and one method to avoid | checked |
| [`10-rel2abs.raku`](10-rel2abs.raku) | Absolute, relative, and one method to avoid | checked |
| [`11-where-the-two-engines-differ.raku`](11-where-the-two-engines-differ.raku) | Where the two engines differ | runs |
