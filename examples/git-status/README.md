# Git::Status — the examples

Every example from [the Git::Status page](https://raku.online/modules/git-status/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Git::Status   # or: zef install Git::Status
rakupp 01-status.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-status.raku`](01-status.raku) | Reading a repository | checked |
| [`02-gist.raku`](02-gist.raku) | The gist | checked |
| [`03-added-trap.raku`](03-added-trap.raku) | The one thing to know | checked |
