# TAP — the examples

Every example from [the TAP page](https://raku.online/modules/tap/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install TAP   # or: zef install TAP
rakupp 01-parse-a-string.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-parse-a-string.raku`](01-parse-a-string.raku) | What it is for | checked |
| [`02-result-object.raku`](02-result-object.raku) | What a run adds up to | checked |
| [`03-run-tap-files.raku`](03-run-tap-files.raku) | Running files: the harness | checked |
| [`04-failure-report.raku`](04-failure-report.raku) | The report, taken apart | checked |
| [`05-stream-entries.raku`](05-stream-entries.raku) | Watching entries as they stream | checked |
| [`06-subtests.raku`](06-subtests.raku) | Watching entries as they stream | checked |
