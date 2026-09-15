# JSON::Unmarshal — the examples

Every example from [the JSON::Unmarshal page](https://raku.online/modules/json-unmarshal/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Unmarshal   # or: zef install JSON::Unmarshal
rakupp 01-into-objects.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-into-objects.raku`](01-into-objects.raku) | Documents into objects | checked |
| [`02-type-checks.raku`](02-type-checks.raku) | Documents into objects | checked |
| [`03-asymmetric.raku`](03-asymmetric.raku) | The one thing to know | checked |
