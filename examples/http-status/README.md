# HTTP::Status — the examples

Every example from [the HTTP::Status page](https://raku.online/modules/http-status/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install HTTP::Status   # or: zef install HTTP::Status
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | What it is for | checked |
| [`02-predicates.raku`](02-predicates.raku) | The predicates, and a log line | checked |
| [`03-provenance.raku`](03-provenance.raku) | Deeper than the title | checked |
