# Concurrent::Channelify — the examples

Every example from [the Concurrent::Channelify page](https://raku.online/modules/concurrent-channelify/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Concurrent::Channelify   # or: zef install Concurrent::Channelify
rakupp 01-channelify.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-channelify.raku`](01-channelify.raku) | Draining a list through a channel | checked |
| [`02-operator.raku`](02-operator.raku) | The operator | checked |
| [`03-accepts.raku`](03-accepts.raku) | What it accepts | checked |
