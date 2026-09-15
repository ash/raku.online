# MessageStream — the examples

Every example from [the MessageStream page](https://raku.online/modules/messagestream/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install MessageStream   # or: zef install MessageStream
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Publishing and subscribing | checked |
| [`02-missing.raku`](02-missing.raku) | Publishing and subscribing | checked |
| [`03-payload.raku`](03-payload.raku) | The payload rules are not the option rules | checked |
| [`04-leak.raku`](04-leak.raku) | The one thing to know | checked |
| [`05-synchronous.raku`](05-synchronous.raku) | Delivery is synchronous | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
