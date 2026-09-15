---
name: Acme::Scrub
version: 0.2.1
auth: zef:thundergnat
kind: Distribution · curiosities
summary: Hide a program inside its own source file as zero-width characters,
  and decode and run it on every later invocation.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Acme::Scrub
source: git://github.com/thundergnat/Acme-Scrub.git
---

## What it is for

It is a joke, in the `Acme::Bleach` tradition, and a neat demonstration of two
real things: that a Raku program can rewrite itself at load time, and that
zero-width Unicode characters are invisible in every editor while still being
data.

On its first run it reads the program off disk, re-encodes everything after
the `use` line as a bit string built from two zero-width characters, and
overwrites the file. Run it again and it finds no visible code, decodes the
payload and `EVAL`s it. The program keeps working while appearing to be one
line long.

## What it does to a file

Because the module destroys the file it is used from, an example has to work
on a disposable copy:

```raku name="scrub"
my $dir = $*TMPDIR.add("scrub-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $prog = $dir.add('demo.raku');
$prog.spurt: q:to/SRC/;
use Acme::Scrub;
say "hello from the original source";
say "answer: ", 6 * 7;
SRC

say 'before : ', $prog.s, ' bytes, ', $prog.slurp.lines.elems, ' lines';
say '';
say 'run 1:';
say '  ', run($*EXECUTABLE, $prog.Str, :out).out.slurp(:close).trim.lines.join(' / ');
say '';
say 'after  : ', $prog.s, ' bytes';
say '  the visible text is now : ', $prog.slurp.subst(/<:Cf>/, '', :g).trim.raku;
say '';
say 'run 2, from the scrubbed file:';
say '  ', run($*EXECUTABLE, $prog.Str, :out).out.slurp(:close).trim.lines.join(' / ');
```

```output
before : 78 bytes, 3 lines

run 1:
  hello from the original source / answer: 42

after  : 1529 bytes
  the visible text is now : "use Acme::Scrub; # for REALLY clean code."

run 2, from the scrubbed file:
  hello from the original source / answer: 42
```

Same output both times. The second run decoded 1,769 bytes of invisible
characters back into the original three lines.

## How the payload is built

```raku name="payload"
say 'the two characters it uses:';
say '  U+FEFF ZERO WIDTH NO-BREAK SPACE -> ',
    "\c[ZERO WIDTH NO-BREAK SPACE]".encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '  U+200B ZERO WIDTH SPACE          -> ',
    "\c[ZERO WIDTH SPACE]".encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '';
say 'one pair per BIT of the UTF-8 source, so the file grows by';
say 'a factor of about 24 — three bytes per character, eight bits per byte.';
```

```output
the two characters it uses:
  U+FEFF ZERO WIDTH NO-BREAK SPACE -> EF BB BF
  U+200B ZERO WIDTH SPACE          -> E2 80 8B

one pair per BIT of the UTF-8 source, so the file grows by
a factor of about 24 — three bytes per character, eight bits per byte.
```

## The one thing to know

`use Acme::Scrub;` **rewrites the file it appears in**, the first time that
file is run. There is no function to call and no opt-in step: the `use`
statement is the action, because the module's body runs at load time and ends
in a write to `$*PROGRAM-NAME`.

Two consequences follow, and the second is the dangerous one.

The original formatting, comments and structure are gone. What remains is a
bit-exact encoding of the code, decodable only by the module itself, so if the
file was not under version control it is not practically recoverable.

And it targets **`$*PROGRAM-NAME`** — the entry-point script — not the file
containing the `use`. Put it in a module inside a larger program and the
program's **main file** is overwritten with a payload that has no
`use Acme::Scrub;` line in front of it. It can never decode itself again: it
becomes a single comment, a permanent silent no-op, and the source is gone.

After the first run, every later run is an `EVAL` under
`MONKEY-SEE-NO-EVAL` of invisible text that anyone with write access to the
file can edit without it looking edited.

## Where the two engines differ

Nowhere. The cycle, the byte counts and the payload are identical on Raku++
and Rakudo, and a file scrubbed by one engine runs correctly under the other.

There is no engine on which this is safe, which is rather the point of an
`Acme::` distribution. Enjoy the trick; keep it out of anything you would
mind losing.
