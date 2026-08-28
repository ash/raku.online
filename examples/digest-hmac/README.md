# Digest::HMAC — the examples

Every example from [the Digest::HMAC page](https://raku.online/modules/digest-hmac/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Digest::HMAC   # or: zef install Digest::HMAC
rakupp 01-first-hmac.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-first-hmac.raku`](01-first-hmac.raku) | What it is for | checked |
| [`02-webhook-signature.raku`](02-webhook-signature.raku) | Verifying a webhook | checked |
| [`03-blocksize.raku`](03-blocksize.raku) | Raw bytes, and the blocksize trap | checked |
