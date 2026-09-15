# as-cli-arguments — the examples

Every example from [the as-cli-arguments page](https://raku.online/modules/as-cli-arguments/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install as-cli-arguments   # or: zef install as-cli-arguments
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Rendering | checked |
| [`02-shapes.raku`](02-shapes.raku) | The other three candidates | checked |
| [`03-strings.raku`](03-strings.raku) | The one thing to know | checked |
| [`04-quoting.raku`](04-quoting.raku) | Quoting is not escaping | checked |
| [`05-named-anywhere.raku`](05-named-anywhere.raku) | Where the two engines differ | checked |
