# Inline::BASIC — the examples

Every example from [the Inline::BASIC page](https://raku.online/modules/inline-basic/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Inline::BASIC   # or: zef install Inline::BASIC
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Running a program | checked |
| [`02-statements.raku`](02-statements.raku) | Running a program | checked |
| [`03-eval.raku`](03-eval.raku) | The one thing to know | checked |
| [`04-builtins.raku`](04-builtins.raku) | The three built-in functions are broken | checked |
| [`05-failures.raku`](05-failures.raku) | Silent zeros and hard dies | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
