# NativeHelpers::Array — the examples

Every example from [the NativeHelpers::Array page](https://raku.online/modules/nativehelpers-array/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install NativeHelpers::Array   # or: zef install NativeHelpers::Array
rakupp 01-copies.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-copies.raku`](01-copies.raku) | The four copies | checked |
