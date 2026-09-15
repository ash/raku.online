# HTTP::ParseParams — the examples

Every example from [the HTTP::ParseParams page](https://raku.online/modules/http-parseparams/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install HTTP::ParseParams   # or: zef install HTTP::ParseParams
rakupp 01-urlencoded.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-urlencoded.raku`](01-urlencoded.raku) | Parsing a query string | checked |
| [`02-cookies.raku`](02-cookies.raku) | Cookies | checked |
| [`03-content-type.raku`](03-content-type.raku) | Choosing the dialect from a header | checked |
| [`04-no-equals-trap.raku`](04-no-equals-trap.raku) | The one thing to know | checked |
