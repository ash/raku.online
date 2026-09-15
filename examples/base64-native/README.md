# Base64::Native — the examples

Every example from [the Base64::Native page](https://raku.online/modules/base64-native/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Base64::Native   # or: zef install Base64::Native
rakupp 01-b64.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-b64.raku`](01-b64.raku) | Encoding and decoding | checked |
| [`02-binary.raku`](02-binary.raku) | Binary | checked |
| [`03-uri.raku`](03-uri.raku) | The URL-safe alphabet | checked |
| [`04-buffer-trap.raku`](04-buffer-trap.raku) | The one thing to know | checked |
