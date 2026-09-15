# NativeLibs — the examples

Every example from [the NativeLibs page](https://raku.online/modules/nativelibs/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install NativeLibs   # or: zef install NativeLibs
rakupp 01-cannon.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-cannon.raku`](01-cannon.raku) | Naming a library | checked |
| [`02-loader.raku`](02-loader.raku) | Opening and resolving | checked |
| [`03-searcher.raku`](03-searcher.raku) | Probing for the right ABI version | checked |
| [`04-which.raku`](04-which.raku) | The one thing to know | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
