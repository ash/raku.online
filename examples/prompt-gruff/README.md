# Prompt::Gruff — the examples

Every example from [the Prompt::Gruff page](https://raku.online/modules/prompt-gruff/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Prompt::Gruff   # or: zef install Prompt::Gruff
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Driving it without a terminal | checked |
| [`02-verify.raku`](02-verify.raku) | Driving it without a terminal | checked |
| [`03-eof.raku`](03-eof.raku) | The one thing to know | checked |
| [`04-options.raku`](04-options.raku) | Every option resets the object | checked |
| [`05-yn.raku`](05-yn.raku) | `:yn` accepts more than y and n | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
