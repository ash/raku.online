# Digest::SHA1::Native — the examples

Every example from [the Digest::SHA1::Native page](https://raku.online/modules/digest-sha1-native/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Digest::SHA1::Native   # or: zef install Digest::SHA1::Native
rakupp 01-sha1.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-sha1.raku`](01-sha1.raku) | Both subs | checked |
