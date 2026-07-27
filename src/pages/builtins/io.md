---
title: File & process IO
slug: io
status: full
browser: false
browser-why: needs the filesystem and subprocesses
order: 78
summary: Read and write files, run subprocesses — real in Raku++, but there's no browser filesystem.
---

Raku++ can read and write files and launch subprocesses, exactly as Rakudo does. The
browser playground has **no filesystem and can't spawn processes**, so these examples
are shown with their verified output (from the interpreter and `--exe`) rather than a
Run button.

## Running a subprocess

`run` launches an external command; with `:out` you capture its standard output.

```raku
my $r = run "echo", "from a subprocess", :out;
say $r.out.slurp(:close).chomp;
```
```output
from a subprocess
```

## Writing and reading a file

`spurt` writes a whole string to a path; `slurp` (or `.lines`) reads it back. Here a
temp file is written, its lines counted and indexed, then removed.

```raku
my $f = $*TMPDIR.add("spec-io-demo.txt");
spurt $f, "alpha\nbeta\ngamma\n";
say $f.lines.elems;
say $f.lines[1];
$f.unlink;
```
```output
3
beta
```

## Notes

- File handling: `spurt`/`slurp` for whole files, `open` for a handle, `.lines`/`.words`
  to iterate, `IO::Path` methods (`.e`, `.d`, `.add`, `.unlink`) for paths.
- `run`/`shell` start subprocesses; `:out`/`:err` capture their streams.
- `$*TMPDIR`, `$*CWD`, `$*HOME` are `IO::Path` handles to standard locations.
- None of this exists in the browser sandbox — run such programs with the interpreter
  (`rakupp program.raku`) or a compiled binary (`rakupp --exe program.raku`).
