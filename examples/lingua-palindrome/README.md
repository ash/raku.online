# Lingua::Palindrome — the examples

Every example from [the Lingua::Palindrome page](https://raku.online/modules/lingua-palindrome/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Lingua::Palindrome   # or: zef install Lingua::Palindrome
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | The three granularities | checked |
| [`02-flags.raku`](02-flags.raku) | The flags | checked |
| [`03-symbols.raku`](03-symbols.raku) | The one thing to know | checked |
| [`04-foldcase.raku`](04-foldcase.raku) | The one thing to know | checked |
| [`05-file.raku`](05-file.raku) | Where the two engines differ | checked |
