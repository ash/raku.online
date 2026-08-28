---
name: TAP
version: 0.3.15
auth: zef:leont
kind: Distribution · testing
summary: The Test Anything Protocol as a library — parse TAP from a string, a
  file or a running program, add runs up into one verdict, and print the
  report you know from prove6.
status: full
license: Artistic-2.0
suite: 2 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:leont/TAP
source: https://github.com/Raku/tap-harness6
---

## What it is for

Every `use Test` file speaks the same line protocol: a plan (`1..5`), then one
`ok` or `not ok` per test. That protocol is TAP — the Test Anything Protocol —
and it is deliberately dull, so that *anything* can produce it and anything
can read it. This distribution is the reader: the library `prove6` is built
on. It takes TAP from wherever it comes — a string, a `.tap` file saved by CI,
a program being run right now — turns each line into an object, adds a whole
run up into one verdict, and prints the familiar report.

Its own README is one paragraph, which undersells it badly. The pieces you
will actually touch are three: a **source** you parse, the **result** that
parse adds up to, and the **harness** that does both for a list of files.

```raku name="parse-a-string"
use TAP;

my $tap = q:to/END/;
    1..4
    ok 1 - addition
    ok 2 - subtraction
    not ok 3 - division
    ok 4 - modulo # TODO edge case
    END

my $parser = TAP::Source::String.new(:content($tap)).parse;
my $result = await $parser;
say $result.tests-planned;
say $result.tests-run;
say $result.passed;
say $result.failed;
say $result.has-problems;
```

```output
4
4
3
[3]
True
```

`.parse` starts reading and gives you a `TAP::Parser`; `await` hands back the
`TAP::Result` when the stream ends. Note that `.failed` is not a count — it is
the **list of test numbers** that failed, which is what you want when the next
step is telling a human which ones to look at.

## What a run adds up to

TAP has more vocabulary than pass and fail: a test can be `# TODO` (expected
to fail, so a failure does not sink the suite) or `# SKIP` (not attempted,
counted as fine). The `Result` object keeps all of those books separately:

```raku name="result-object"
use TAP;

my $tap = q:to/END/;
    1..6
    ok 1 - basic maths
    not ok 2 - the tricky case
    ok 3 - rounding # TODO negative zero undecided
    not ok 4 - overflow handling # TODO needs bigint
    ok 5 - unicode names # SKIP no locale on this box
    ok 6 - cleanup
    END

my $result = await TAP::Source::String.new(:content($tap)).parse;
say 'planned      ', $result.tests-planned;
say 'passed       ', $result.passed;
say 'failed       ', $result.failed;
say 'todo         ', $result.todo;
say 'todo-passed  ', $result.todo-passed;
say 'skipped      ', $result.skipped;
```

```output
planned      6
passed       5
failed       [2]
todo         2
todo-passed  [3]
skipped      1
```

Read the middle rows carefully, because they encode TAP's whole philosophy.
Test 4 said `not ok` but was marked TODO, so it lands in `passed` — an
expected failure is not a problem. Test 3 was marked TODO and *succeeded*,
so it shows up in `todo-passed` — the suspicious case, a fix that landed
while its test still says "expected to fail". Only test 2, which failed
without excuse, is in `failed`.

## Running files: the harness

`TAP::Harness` is the machinery behind `prove6`: give it file names, and a
`TAP::SourceHandler` decides per file what to do — a `.rakutest` or `.t6`
file is run by the Raku that is running the harness, and a `.tap` file is
read as text, which is how you re-examine a run that CI saved. `await` on
the running harness returns a `TAP::Aggregator`, the sum over all files:

```raku name="run-tap-files"
use TAP;

my $dir = $*TMPDIR.add("tap-demo-$*PID");
mkdir $dir;
$dir.add('results.tap').spurt(q:to/END/);
    TAP version 13
    1..3
    ok 1 - the server starts
    ok 2 - it answers on the right port
    ok 3 - it stops again
    END

indir $dir, {
    my $aggregator = await TAP::Harness.new.run('results.tap');
    say '';
    say $aggregator.passed, '/', $aggregator.tests-run, ' passed';
}

unlink $dir.add('results.tap'); rmdir $dir;
```

```output
results.tap .. ok
All tests successful.
Files=1, Tests=3,  0 wallclock secs
Result: PASS

3/3 passed
```

The first four lines are the harness talking — the report went to standard
output as it would from `prove6` — and the last is ours, from the aggregator.
`TAP::Harness.new` takes `:jobs(4)` to run four files at once,
`:volume(TAP::Verbose)` to echo every TAP line as it arrives, and
`:volume(TAP::Silent)` to print nothing and leave the aggregator as the only
witness. The environment variables `prove` users know work here too, because
this is the layer that reads them: `HARNESS_VERBOSE`, `HARNESS_TIMER`, and
`HARNESS_OPTIONS=j4` for jobs.

## The report, taken apart

The summary block that `prove6` prints on failure is not welded to the
harness — `TAP::Formatter::Text` renders it from any aggregator you hand it.
That is the piece to reuse when you are building your own runner and want
its output to read like everyone else's:

```raku name="failure-report"
use TAP;

my $tap = q:to/END/;
    1..3
    ok 1 - the server starts
    not ok 2 - it answers on the right port
    ok 3 - it stops again
    END

my $result = await TAP::Source::String.new(:content($tap), :name<t/server.rakutest>).parse;

my $aggregator = TAP::Aggregator.new;
$aggregator.add-result($result);

my $formatter = TAP::Formatter::Text.new(:names[$result.name]);
print $formatter.format-summary($aggregator, Duration);
```

```output

Test Summary Report
-------------------
t/server.rakutest (Wstat: (none) Tests: 3 Failed: 1)
  Failed tests:  2
Files=1, Tests=3
Result: FAILED
```

`Wstat` is the file's exit status as `wait(2)` would report it — `(none)`
here, because this run came from a string rather than a process. Passing an
undefined `Duration` drops the wallclock line, which also makes the report
reproducible — that is why this page can promise you its output.

## Watching entries as they stream

Underneath the counting, the parser turns every TAP line into a typed entry —
`TAP::Plan`, `TAP::Test`, `TAP::Comment`, `TAP::Bailout`, `TAP::YAML`,
`TAP::Sub-Test` for indented subtest blocks, and `TAP::Unknown` for anything
it cannot place. Anything that does the `TAP::Entry::Handler` role can be
passed to `.parse` and sees each entry the moment it is parsed — this is the
hook for live dashboards, or for questions the `Result` totals cannot answer:

```raku name="stream-entries"
use TAP;

class Narrator does TAP::Entry::Handler {
    method handle-entry($entry) {
        given $entry {
            when TAP::Plan    { say "plan: {.tests} tests promised" }
            when TAP::Test    { say "test {.number}: {.ok ?? 'ok' !! 'NOT ok'} — {.description}" }
            when TAP::Comment { say "note: {.comment}" }
        }
    }
    method end-entries() { say "-- stream ended --" }
}

my $tap = q:to/END/;
    1..2
    # starting up
    ok 1 - config loads
    not ok 2 - server answers
    END

await TAP::Source::String.new(:content($tap)).parse(:handlers[Narrator.new]);
```

```output
plan: 2 tests promised
note: starting up
test 1: ok — config loads
test 2: NOT ok — server answers
-- stream ended --
```

A subtest arrives as one `TAP::Sub-Test` entry carrying its own entries, and
counts as a single test in the enclosing plan:

```raku name="subtests"
use TAP;

my $tap = q:to/END/;
    1..2
        ok 1 - opens
        ok 2 - closes
        1..2
    ok 1 - the file half
    ok 2 - the network half
    END

class Peek does TAP::Entry::Handler {
    method handle-entry($e) {
        say $e.^name, ($e ~~ TAP::Sub-Test ?? " with {$e.entries.elems} entries" !! '');
    }
}
my $r = await TAP::Source::String.new(:content($tap)).parse(:handlers[Peek.new]);
say $r.passed, '/', $r.tests-run;
```

```output
TAP::Plan
TAP::Sub-Test with 3 entries
TAP::Test
2/2
```

## prove6, and where this module sits

If you want to run a test directory from a shell rather than a program, that
is `prove6` — a separate distribution, `App::Prove6`, which is a command-line
skin over exactly the classes on this page:

```sh
$ prove6 -l t/           # run t/, with lib/ on the library path
$ prove6 -j4 -v t/       # four files at a time, every TAP line echoed
```

`zef` runs each distribution's suite at install time through its own runner,
so this module is not in that path — but `prove6`, CI scripts that keep
`.tap` files, and any tool that wants to *read* test results rather than
produce them all funnel through here.

## Where the two engines differ

Nothing on this page any more — and getting that sentence took four engine
fixes. When this page was first written the badge said *partial*: a
`.rakutest` file handed to `TAP::Harness` ran, exited cleanly, and counted
for nothing —

```raku fragment
# Raku++ 3.20.1, the day this page was written:
await TAP::Harness.new.run('t/math.rakutest');   # Files=1, Tests=0 … NOTESTS
```

— because `TAP::Source::Proc` reads the child through
`Proc::Async.stdout.lines(:!chomp)`, and Raku++ handed that tap one raw
chunk with the terminators stripped, where TAP's grammar needs the newline
to close each entry. Chasing the NOTESTS pulled a whole chain into the
light, each gap hiding the next: proc-stream taps also arrived as
undecoded `Blob`s where Rakudo emits `Str` lines; `whenever
$proc.stdout.lines(:!chomp)` *inside* a `supply { }` block — the exact
shape of the module's `parse-stream` — wired nothing at all, so the child
ran uncaptured; `$start.then({ … })` fired at registration with a
still-Planned promise, and `.result` answered the `Proc::Async` itself
where the module's `Status.new(Proc $proc)` needs the finished `Proc`; and
a relative `IO::Path` carrying its own `:CWD` resolved file operations
against the process directory, which broke `run(..., :cwd($dir))` — the
harness probes every source through exactly such paths.

All of it is fixed in the engine, each piece pinned by a regression file
([proc-stream-tap-fidelity.raku and
io-path-cwd-operations.raku](https://github.com/ash/rakupp/tree/main/t/regression)
carry this page's finds). Every example above prints the same bytes under
both engines, and so does what the examples do not show: a *failing*
`.rakutest` is reported with Rakudo's exact words, down to `Dubious, test
returned 1` and `Wstat: 256`.

One caveat remains, and it is the module's, not either engine's: a
**`.tap` file whose tests fail** makes the harness reap the finished
parser twice and die (the message differs by engine; under Rakudo it is
*"You already have a parser for…"*). Failing *programs* are reported fine;
failing saved *files* are not — treat `.tap` replays as a green-path tool.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install TAP`; it depends on nothing outside core.
3. **Test** — the distribution's own suite: 2 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

This module earned its way here the hard way. When `rakupp install TAP` was
first tried, **seven engine bugs stood in a row between the tarball and a
working module**, each one hiding the next: destructuring pointy blocks on
`if`/`with` conditions did not parse (line 457 of the module — the error
that got reported as issue #34), the hyper subscript `»<key>` did not parse,
the renaming form of `handles(:print<print>)` did not delegate, a `proto`
with a real body competed with its own candidates instead of wrapping them,
`.lines` on a live `Supply` did not exist, a coercion type on a named
parameter was never applied, and `IO::Path.relative` mangled paths that
share no prefix with the base — which on macOS is every path under
`$*TMPDIR`. Each fix is pinned by a regression file named
[issue34-*.raku](https://github.com/ash/rakupp/tree/main/t/regression) that
passes under both engines, and the delegation and supply fixes alone moved
twelve Roast files.

The `Source::Proc` gap became the eighth in that series — and unwinding it
surfaced three more, so the row now stands at eleven. A page that said
*partial* on the day it was written is how they got their numbers; the
badge flipped to *full* the day they landed.
