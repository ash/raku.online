---
name: Getopt::Long::Grammar
version: 0.0.2
auth: zef:antononcube
kind: Distribution · grammars
summary: Parse a command line held in a single string — command word, options
  and positional arguments — into a Match or a plain hash, without ever
  touching @*ARGS.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:antononcube/Getopt::Long::Grammar
source: https://github.com/antononcube/Raku-Getopt-Long-Grammar
---

## What it is for

Raku's `MAIN` handles the command line your program was actually started with.
It does not help when the command line arrives as a **string** — from a chat
message, a configuration file, a saved history entry, a test fixture.

This distribution is for that case. It never reads `@*ARGS`; you hand it a
string and it hands back structure. Because the grammar lives in a role, the
delimiter and the other tokens can be overridden by a subclass.

## Interpreting a command line

```raku name="interpret"
use Getopt::Long::Grammar;

my %res = getopt-interpret('mytool --verbose --output=out.txt --level=3');
say 'command : ', %res<command>;
say 'options : ', %res<options>.keys.sort.map({ "$_=" ~ %res<options>{$_} }).join(' ');
say 'args    : ', (%res<arguments> // ()).elems, ' positional';
```

```output
command : mytool
options : level=3 output=out.txt verbose=True
args    : 0 positional
```

`getopt-parse` and `getopt-subparse` give you the raw `Match` if you want to
walk it yourself; `getopt-interpret` gives you the hash.

## Repeated options

```raku name="repeat"
use Getopt::Long::Grammar;

my %g = getopt-interpret('build --define=A --define=B --define=C');
say 'gathered   : ', %g<options><define>.List.join(',');
say '';
my %r = getopt-interpret('build --define=A --define=B', :!gather);
say 'raw pairs  : ', %r<options>.map({ "{$_<name>}={$_<value>}" }).join(' ');
```

```output
gathered   : A,B,C

raw pairs  : define=A define=B
```

With `:gather` — the default — a repeated option collapses to one key holding
a `List`. With `:!gather` you get the raw ordered list of `{name, value}`
hashes, which is what you want when the order of repeated flags matters.

## The one thing to know

A space is as good as `=`, so a boolean flag silently swallows the next word.

```raku name="space-trap"
use Getopt::Long::Grammar;

for 'mytool --verbose file.txt',
    'mytool --verbose=1 file.txt',
    'mytool file.txt --verbose' -> $line {
    my %res = getopt-interpret($line);
    say $line;
    say '  options : ', %res<options>
        ?? %res<options>.keys.sort.map({ "$_=" ~ %res<options>{$_}.gist }).join(' ')
        !! '(none)';
    say '  args    : ', %res<arguments> ?? %res<arguments>.join(' ') !! '(none)';
}
```

```output
mytool --verbose file.txt
  options : verbose=file.txt
  args    : (none)
mytool --verbose=1 file.txt
  options : verbose=1
  args    : file.txt
mytool file.txt --verbose
  options : verbose=True
  args    : file.txt
```

The `option-pair` token is `<option-name> [['=' | \h+] <option-value>]?`, so
`--verbose file.txt` parses as `verbose => "file.txt"` with **no positional
arguments at all**. The same line written `--verbose=1 file.txt` does the
obvious thing. Nothing errors either way.

Write your boolean flags last, or always with `=`, or accept that you must
know the flag's arity before parsing — which rather defeats the purpose.

## Where the two engines differ

Only in `.raku` rendering: Rakudo shows the itemisation sigil on a gathered
list (`$("A", "B")`) where Raku++ does not. A follow-up check confirmed the
value is the same on both — same `WHAT`, same `elems`, same `.join`.

The larger thing to know is not an engine difference at all: **quoting does
not work**. The grammar declares a `getopt-quoted-string` rule that knows
about `'…'`, `"…"`, `⎡…⎦` and `«…»`, and it can never fire. `generic-arg` is
`<-[-]> <-[=\s]>* || <getopt-quoted-string>`, and the first alternative
matches a leading quote and then runs to the first space, so it always
succeeds before the second is reached — and the ratcheting `||` in a `token`
never backtracks for it.

```raku name="quoting"
use Getopt::Long::Grammar;

my %a = getopt-interpret('mytool "quoted value"');
say 'arguments : ', %a<arguments>.List.raku;
my %b = getopt-interpret(q{mytool --name='John Smith'});
say 'options   : ', %b<options>.keys.sort.map({ "$_=" ~ %b<options>{$_} }).join(' ');
```

```output
arguments : ("\"quoted", "value\"")
options   : name='John
```

`mytool "quoted value"` yields **two** arguments with the quote characters
retained, and `--name='John Smith'` loses `Smith'` from the options entirely.
The line still *parses* — `getopt-parse` returns a match — so nothing alerts
you. Split quoted values yourself before handing the string over.

Two smaller notes. `-x=1` and `--x=1` are treated identically; there is no
single-dash distinction and no clustering of short flags. And the empty string
is a successful parse yielding an empty hash, while `mytool --` fails to
parse.
