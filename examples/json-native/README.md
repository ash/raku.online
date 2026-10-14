# JSON::Native — the examples

Every example from [the JSON::Native page](https://raku.online/modules/json-native/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Native   # or: zef install JSON::Native
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-backend.raku`](02-backend.raku) | Which path answers, on which engine | varies (random) |
| [`03-types.raku`](03-types.raku) | The types you get back are JSON::Fast's | checked |
| [`04-byte-for-byte.raku`](04-byte-for-byte.raku) | Byte for byte, quirks included | checked |
| [`05-immutable.raku`](05-immutable.raku) | `:immutable`, and the import options | checked |
| [`06-import-options.raku`](06-import-options.raku) | `:immutable`, and the import options | checked |
| [`07-jsonc.raku`](07-jsonc.raku) | Comments, and refusals in JSON::Fast's words | checked |
| [`08-refusals.raku`](08-refusals.raku) | Comments, and refusals in JSON::Fast's words | checked |
