---
name: Browser::Open
version: 1.0.1
auth: github:azawawi
kind: Distribution · system
summary: Picks a command that can open a URL, per kernel — and silently
  ignores `$BROWSER` when you set it to an absolute path.
status: full
suite: 2 files, green
tested: 2026-09-15
license: MIT
depends: File::Which
raku-land: https://raku.land/github:azawawi/Browser::Open
source: git://github.com/azawawi/raku-browser-open.git
---

## What it is for

"Open this URL in the user's browser" has a different answer on every system:
`open` on macOS, `xdg-open` or one of a dozen fallbacks on Linux, a registry
lookup on Windows. This distribution walks a fixed table of candidates for the
current kernel and hands you the first one that exists.

## Asking what it would run

```raku name="basics"
use Browser::Open;

say 'kernel               : ', $*KERNEL.name;
say 'open-browser-cmd     : ', open-browser-cmd();
say 'open-browser-cmd-all : ', open-browser-cmd-all();
say '';
my $cmd = open-browser-cmd();
say 'it is executable     : ', $cmd.IO.x;
say 'return type          : ', $cmd.WHAT.^name;
say '';
say 'open-browser($url) spawns that command with the URL as its single';
say 'argv element — Proc::Async.new($cmd, $url), no shell — so a URL';
say 'containing shell metacharacters is not an injection vector.';
say '  it would run : ', ($cmd, 'https://example.invalid/x').raku;
```

```output
kernel               : darwin
open-browser-cmd     : /usr/bin/open
open-browser-cmd-all : /usr/bin/open

it is executable     : True
return type          : Str

open-browser($url) spawns that command with the URL as its single
argv element — Proc::Async.new($cmd, $url), no shell — so a URL
containing shell metacharacters is not an injection vector.
  it would run : ("/usr/bin/open", "https://example.invalid/x")
```

The signature is `open-browser(Str $url, Bool $all = False)`, and on macOS the
`$all` flag is a no-op: both `-cmd` subs answer the same string.

## The one thing to know

Setting `BROWSER` to an absolute path — the one way everybody sets it — is
silently ignored. You get the OS default instead.

```raku name="browser-env"
use Browser::Open;
use File::Which;

say 'the candidate table stores the $BROWSER value with no "this is';
say 'already a path" flag, so it goes through which():';
say '';
say '  which("cat")      = ', which('cat').raku;
say '  which("/bin/cat") = ', which('/bin/cat').raku, '   <- a real, executable file';
say '  "/bin/cat".IO.x   = ', '/bin/cat'.IO.x;
say '';
say 'File::Which only scans PATH directories, so an absolute path returns';
say 'Nil and the candidate is skipped. No error, no warning.';
say '';
say '  BROWSER=/bin/cat -> falls back to the OS default';
say '  BROWSER=cat      -> resolves to ', which('cat').raku;
say '';
say 'set BROWSER to a NAME on your PATH, not to a path.';
```

```output
the candidate table stores the $BROWSER value with no "this is
already a path" flag, so it goes through which():

  which("cat")      = "/bin/cat"
  which("/bin/cat") = Any   <- a real, executable file
  "/bin/cat".IO.x   = True

File::Which only scans PATH directories, so an absolute path returns
Nil and the candidate is skipped. No error, no warning.

  BROWSER=/bin/cat -> falls back to the OS default
  BROWSER=cat      -> resolves to "/bin/cat"

set BROWSER to a NAME on your PATH, not to a path.
```

There is a second half to the same trap: `$BROWSER` is read **once**, at
module load, into a module-scope table. Assigning `%*ENV<BROWSER>` after
`use Browser::Open` has no effect at all — only a `require` after the
assignment sees it.

## Failure is silent

```raku name="silent"
use Browser::Open;

say 'open-browser returns nothing useful:';
say '  the sub does Proc::Async.new($cmd, $url).start and DISCARDS the';
say '  Promise, so it returns immediately and a script that exits right';
say '  after calling it gives the child no time to start.';
say '';
say 'and if no candidate resolves at all, it returns without spawning';
say 'anything and without any indication. Check first:';
my $cmd = open-browser-cmd();
if $cmd {
    say '  a browser command is available : ', $cmd;
} else {
    say '  no browser command found — tell the user yourself';
}
say '';
say 'a wrapper worth having:';
say '  sub open-url($url) {';
say '      my $cmd = open-browser-cmd() or die "no browser command found";';
say '      await Proc::Async.new($cmd, $url).start;';
say '  }';
```

```output
open-browser returns nothing useful:
  the sub does Proc::Async.new($cmd, $url).start and DISCARDS the
  Promise, so it returns immediately and a script that exits right
  after calling it gives the child no time to start.

and if no candidate resolves at all, it returns without spawning
anything and without any indication. Check first:
  a browser command is available : /usr/bin/open

a wrapper worth having:
  sub open-url($url) {
      my $cmd = open-browser-cmd() or die "no browser command found";
      await Proc::Async.new($cmd, $url).start;
  }
```

## Where the two engines differ

Nothing. The candidate table, the `which` resolution, the `$BROWSER` handling
and the load-time capture all behave identically — this is a table walk and a
`File::Which` call, with no container-type or laziness question in it.

```raku name="table"
use Browser::Open;

say 'what the table holds for this kernel, in order, is an implementation';
say 'detail — but which one won is not:';
say '  chosen : ', open-browser-cmd();
say '';
say 'two dead branches worth knowing about, since they explain the shape';
say 'of the code: two entries carry an unused fourth field $no_search, and';
say 'no row ever sets it, so `next if $no_search && …` and';
say '`return $cmd if $no_search` are both unreachable.';
say '';
say 'on Windows the distribution declares a Win32::Registry dependency,';
say 'which is not in the ecosystem index — `rakupp test` reports it as';
say 'skipped by distro name, which is correct off Windows.';
```

```output
what the table holds for this kernel, in order, is an implementation
detail — but which one won is not:
  chosen : /usr/bin/open

two dead branches worth knowing about, since they explain the shape
of the code: two entries carry an unused fourth field $no_search, and
no row ever sets it, so `next if $no_search && …` and
`return $cmd if $no_search` are both unreachable.

on Windows the distribution declares a Win32::Registry dependency,
which is not in the ecosystem index — `rakupp test` reports it as
skipped by distro name, which is correct off Windows.
```
