# Object::Container — the examples

Every example from [the Object::Container page](https://raku.online/modules/object-container/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Object::Container   # or: zef install Object::Container
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Registering and fetching | checked |
| [`02-singleton.raku`](02-singleton.raku) | Class methods are a different container | checked |
| [`03-callable.raku`](03-callable.raku) | You can never store a Callable | checked |
| [`04-poisoned.raku`](04-poisoned.raku) | The one thing to know | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
