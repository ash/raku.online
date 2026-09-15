# Text::Diff::Sift4 — the examples

Every example from [the Text::Diff::Sift4 page](https://raku.online/modules/text-diff-sift4/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Diff::Sift4   # or: zef install Text::Diff::Sift4
rakupp 01-sift.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-sift.raku`](01-sift.raku) | Measuring a distance | checked |
| [`02-knobs.raku`](02-knobs.raku) | Tuning the two knobs | checked |
| [`03-underestimate.raku`](03-underestimate.raku) | The one thing to know | checked |
