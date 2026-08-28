# File::Directory::Tree — the examples

Every example from [the File::Directory::Tree page](https://raku.online/modules/file-directory-tree/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Directory::Tree   # or: zef install File::Directory::Tree
rakupp 01-mktree-and-rmtree.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-mktree-and-rmtree.raku`](01-mktree-and-rmtree.raku) | What it is for | checked |
| [`02-empty-directory.raku`](02-empty-directory.raku) | Emptying without removing | checked |
| [`03-edge-cases.raku`](03-edge-cases.raku) | What the edges do | checked |
