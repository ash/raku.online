# App::Rakus — the examples

Every example from [the App::Rakus page](https://raku.online/modules/app-rakus/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install App::Rakus   # or: zef install App::Rakus
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.7.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | The routing is a pure function | checked |
| [`02-routing.raku`](02-routing.raku) | Every refusal, by status | checked |
| [`03-mime.raku`](03-mime.raku) | `Content-Type` by extension — or honestly not | checked |
| [`04-listing.raku`](04-listing.raku) | What a directory answers | checked |
| [`05-response-head.raku`](05-response-head.raku) | The response head is data too | checked |
| [`06-live.raku`](06-live.raku) | A real request, in-process | checked |
