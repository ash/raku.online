# Syslog::Parse — the examples

Every example from [the Syslog::Parse page](https://raku.online/modules/syslog-parse/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Syslog::Parse   # or: zef install Syslog::Parse
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Parsing a line | checked |
| [`02-user.raku`](02-user.raku) | Parsing a line | checked |
| [`03-june.raku`](03-june.raku) | The one thing to know | checked |
| [`04-pid.raku`](04-pid.raku) | Two fields that are always undefined | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
