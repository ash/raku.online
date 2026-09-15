# UNIX::Privileges — the examples

Every example from [the UNIX::Privileges page](https://raku.online/modules/unix-privileges/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install UNIX::Privileges   # or: zef install UNIX::Privileges
rakupp 01-userinfo.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-userinfo.raku`](01-userinfo.raku) | Looking a user up | checked |
| [`02-tags.raku`](02-tags.raku) | The import tags | checked |
| [`03-miss.raku`](03-miss.raku) | When the lookup fails | checked |
