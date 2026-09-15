# File::Directory::Bubble — the examples

Every example from [the File::Directory::Bubble page](https://raku.online/modules/file-directory-bubble/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Directory::Bubble   # or: zef install File::Directory::Bubble
rakupp 01-down.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-down.raku`](01-down.raku) | Listing a tree | checked |
| [`02-order.raku`](02-order.raku) | The removal order | checked |
| [`03-up.raku`](03-up.raku) | Walking upwards | checked |
| [`04-missing-trap.raku`](04-missing-trap.raku) | The one thing to know | checked |
