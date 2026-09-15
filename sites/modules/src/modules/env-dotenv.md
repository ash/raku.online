---
name: Env::Dotenv
version: 0.0.6
auth: zef:ispyhumanfly
kind: Distribution · configuration
summary: Read a .env file in the current directory and turn each line into a
  key and a value, either copied into the process environment or returned as
  a hash.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:ispyhumanfly/Env::Dotenv
source: git://github.com/ispyhumanfly/raku-dotenv.git
---

## What it is for

The twelve-factor convention keeps configuration in environment variables and
keeps the development values in a `.env` file next to the code, outside
version control. Nearly every language has a small library that reads that
file; this is Raku's.

## Loading a file

```raku name="load"
use Env::Dotenv :load, :values;

my $dir = $*TMPDIR.add("dotenv-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

$dir.add('.env').spurt: q:to/ENV/;
SIMPLE=hello
DATABASE=postgres
PORT=5432
ENV

indir $dir, {
    my %v = dotenv_values();
    say 'dotenv_values : ', %v.keys.sort.map({ "$_={%v{$_}}" }).join(' ');
    dotenv_load();
    say 'after dotenv_load, ENV<SIMPLE> = ', %*ENV<SIMPLE>;
}
```

```output
dotenv_values : DATABASE=postgres PORT=5432 SIMPLE=hello
after dotenv_load, ENV<SIMPLE> = hello
```

There is also an object flavour behind the `:oop` tag — `Dotenv.new.load` and
`.values` — doing exactly the same two things.

## The import tags

A plain `use Env::Dotenv;` imports **nothing at all**. Every export sits
behind a tag:

| tag | gives you |
|---|---|
| `:load` | `dotenv_load()`, which populates `%*ENV` |
| `:values` | `dotenv_values()`, which returns a `Hash` |
| `:oop` | `class Dotenv` with `.load` and `.values` |

Neither routine takes a path. The filename `.env` and the location `$*CWD`
are both hard-coded, so behaviour depends on where the process was started
rather than where the script lives.

## The one thing to know

Values are truncated at the first `=`, so base64 and URLs with query strings
are silently corrupted.

```raku name="equals-trap"
use Env::Dotenv :values;

my $dir = $*TMPDIR.add("dotenv2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

$dir.add('.env').spurt: q:to/ENV/;
BASE64=aGVsbG8=
URL=https://example.com/?a=1&b=2
QUOTED="double quoted"
SPACED = padded
EXPORTED=plain
ENV

indir $dir, {
    my %v = dotenv_values();
    for %v.keys.sort -> $k {
        say sprintf('%-12s => %s', $k.raku, %v{$k}.raku);
    }
}
```

```output
"BASE64"     => "aGVsbG8"
"EXPORTED"   => "plain"
"QUOTED"     => "\"double quoted\""
"SPACED "    => " padded"
"URL"        => "https://example.com/?a"
```

Four defects in five lines. The base64 padding is gone, the URL stops at its
first query parameter, the quotes are kept as part of the value, and
whitespace around the `=` is preserved in both the key and the value — so the
key is `'SPACED '` with a trailing space. An `export ` prefix, which is how
most people write these files so they can also be sourced by a shell, is
absorbed into the key.

Base64 secrets and URLs with query strings are exactly what people put in a
`.env` file, which makes the truncation the one to watch.

## Where the two engines differ

On a comment. There is no comment syntax and no blank-line skipping anywhere
in the module's forty lines: every line is split on `=` and whatever comes out
becomes a pair. A line with no `=` yields an undefined value, and
`dotenv_values` calls `.chomp` on it.

Under Rakudo that throws `No such method 'chomp' for invocant of type 'Any'`,
so a `.env` file containing a `#` comment, a blank line or a bare word cannot
be read at all. Under Raku++ the call returns, with `'# note'` or `''` as a
**key** — arguably worse, since nothing tells you.

`dotenv_load` survives on both engines only because it happens not to call
`.chomp`, so the two routines in the same module disagree about whether your
file is readable.

The most ordinary `.env` file in existence — one with a header comment and a
trailing blank line — is therefore unreadable on one engine. Strip comments
and blanks before calling, or use `dotenv_load` and read `%*ENV`.

One smaller difference: with no tag at all, Rakudo reports the undeclared
routines at compile time and Raku++ only at runtime.
