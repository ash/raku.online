# I18n::Simple — the examples

Every example from [the I18n::Simple page](https://raku.online/modules/i18n-simple/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install I18n::Simple   # or: zef install I18n::Simple
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | Keys, slots, and layering | checked |
| [`02-missing-context.raku`](02-missing-context.raku) | The one thing to know | checked |
