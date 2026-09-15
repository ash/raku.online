---
name: Proc::Easy
version: 0.0.2
auth: zef:tbrowder
kind: Distribution · process
summary: One sub that wraps run, always capturing both output streams, and
  hands back the exit code, stderr and stdout together.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Proc::Easy
source: https://github.com/tbrowder/Proc-Easy.git
---

## What it is for

Running a command and getting its output back is four lines of Raku: `run`
with `:out` and `:err`, slurp both handles, close them, read the exit code.
Four lines is three too many when you do it fifteen times in a script, and
forgetting to close a handle is a resource leak nobody notices until it
matters.

This distribution is that wrapped into one call.

## Running a command

```raku name="run"
use Proc::Easy;

my ($exit, $err, $out) = run-command('echo hello');
say 'exit : ', $exit;
say 'err  : ', $err.raku;
say 'out  : ', $out.raku;
say '';
say 'true  -> exit ', run-command('true',  :exit);
say 'false -> exit ', run-command('false', :exit);
```

```output
exit : 0
err  : ""
out  : "hello\n"

true  -> exit 0
false -> exit 1
```

The bare call returns three things in that order: exit code, stderr, stdout.
Nothing escapes to the terminal.

## Asking for one of them

```raku name="selectors"
use Proc::Easy;

say ':out alone : ', run-command('echo one two', :out).raku;
say ':err alone : ', run-command('echo one two', :err).raku;
say ':exit alone: ', run-command('echo one two', :exit);
say '';
say 'the flags are checked in the order exit, err, out,';
say 'and the FIRST one set wins — they do not combine:';
say '  :out and :err together : ', run-command('echo x', :out, :err).raku;
say '  all three together     : ', run-command('echo x', :out, :err, :exit).raku;
```

```output
:out alone : "one two\n"
:err alone : ""
:exit alone: 0

the flags are checked in the order exit, err, out,
and the FIRST one set wins — they do not combine:
  :out and :err together : ""
  all three together     : 0
```

Asking for `:out, :err` does not give you both. `:err` is tested first, so you
silently get stderr only.

## Running somewhere else

```raku name="dir"
use Proc::Easy;

my $dir = $*TMPDIR.add("pe-{$*PID}");
$dir.mkdir;
LEAVE { $dir.rmdir }

my $before = $*CWD;
my $out = run-command('pwd', :out, :dir($dir.Str));
say 'ran in the fixture      : ', $out.chomp.ends-with("pe-{$*PID}");
say 'and came back afterwards : ', $*CWD.absolute eq $before.absolute;
```

```output
ran in the fixture      : True
and came back afterwards : True
```

`:dir` uses a process-global `chdir`, so it is not thread-safe and does not
restore the directory if the run throws.

## The one thing to know

`run-command` takes a command **string** and never runs a shell. The string is
split with `.words` and handed straight to `run`, so quotes, globs, pipes and
redirections arrive at the program as literal arguments.

```raku name="no-shell"
use Proc::Easy;

say 'plain     : ', run-command('echo hello world', :out).raku;
say 'quoted    : ', run-command(Q[echo 'hello world'], :out).raku;
say 'a glob    : ', run-command('echo *', :out).raku;
say 'a pipe    : ', run-command('echo a | true', :out).raku;
say 'a redirect: ', run-command('echo a > /dev/null', :out).raku;
```

```output
plain     : "hello world\n"
quoted    : "'hello world'\n"
a glob    : "*\n"
a pipe    : "a | true\n"
a redirect: "a > /dev/null\n"
```

`echo 'hello world'` prints the quotes. `echo *` prints an asterisk. `echo a |
true` prints `a | true`. The string interface reads exactly like `shell()` and
behaves exactly like `run()`.

Pass the arguments already split if any of them can contain a space, because
this cannot do it for you.

## Where the two engines differ

Twice, and one of them is a wrong answer rather than a wrong message.

`:dir` to a directory that does **not exist** dies on Rakudo with
`X::IO::Chdir` naming the path. On Raku++ it silently runs the command in the
**original** directory and returns its output, because the module writes
`chdir $dir if $dir;` and Raku++ does not sink-throw an unhandled `Failure`
under a statement modifier. So a typo in a path is an error on one engine and
a wrong answer on the other.

And the exit code of a command that could not be started differs: Raku++
reports 127, Rakudo reports −1. Neither throws, so an example printing that
number will not build on both engines.

One thing that is the same on both: **`:debug` writes its `ERROR:` block to
stdout**, not stderr. That is output pollution in the middle of whatever you
were capturing.
