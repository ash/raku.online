---
name: Config::INI
version: 1.2
auth: zef:raku-community-modules
kind: Distribution · configuration
summary: A grammar for the classic key = value / [section] file, plus a writer
  that walks a hash back out, giving a two-level hash of strings.
status: full
suite: 3 files, green
tested: 2026-09-15
license: NOASSERTION
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Config::Ini
source: https://github.com/raku-community-modules/Config-INI.git
---

## What it is for

The INI file is the lowest-ceremony configuration format there is: a key, an
equals sign, a value, and square brackets when you want to group them. It has
no schema, no types and no nesting, and that is exactly why it has outlived
several formats that did.

This distribution is a forty-line grammar for it and a writer that goes the
other way.

## Reading a file

```raku name="parse"
use Config::INI;

my $conf = q:to/END/;
# a leading comment
; another comment style
timeout = 30
name=top level

[server]
host = example.test
port = 8080

[server.tls]
enabled = yes   ; trailing comment
END

my %got = Config::INI::parse($conf);
for %got.keys.sort -> $sect {
    say "[$sect]";
    for %got{$sect}.keys.sort -> $k {
        say sprintf('    %-14s = %s', $k.raku, %got{$sect}{$k}.raku);
    }
}
```

```output
[_]
    "name"         = "top level"
    "timeout"      = "30"
[server]
    "host"         = "example.test"
    "port"         = "8080"
[server.tls]
    "enabled"      = "yes"
```

Bare keys before the first section go under `_`. Comments start with `#` or
`;` and are stripped anywhere a line ends. Every value is a **`Str`** —
`timeout` is `"30"`, not `30`.

Nothing is exported: both units are `unit module` with `our sub`, so every
call must be fully qualified.

## Writing one

```raku name="write"
use Config::INI;
use Config::INI::Writer;

say Config::INI::Writer::dump({ server => { host => 'example.test' } });
say '---';
say Config::INI::Writer::dump({ a => 1 }).raku;
```

```output

[server]
host=example.test

---
"a=1\n"
```

Two things to notice. The output always begins with a blank line before the
first section. And a flat hash with no sections dumps as bare keys, which
`parse` then reads back under `_` — so `dump` followed by `parse` is **not** a
round trip for a flat hash.

The writer also cannot represent nesting deeper than two levels: a third level
is stringified into the value with a literal tab.

## What the grammar accepts

```raku name="edges"
use Config::INI;

sub show($label, $text) {
    my $r = try Config::INI::parse($text);
    say sprintf('%-32s -> %s', $label,
        $r.defined ?? 'parsed, ' ~ $r.keys.sort.join(',') !! 'Nil');
}

show 'value containing =',        "a=b=c\n";
show 'key containing a space',    "my key = v\n";
show 'bracket inside a key',      "[s]\na[0]=1\n";
show 'section name with spaces',  "[my section]\nk=v\n";
show 'indented key',              "   a = b\n";
show 'CRLF line endings',         "a=b\r\n";
show 'only comments',             "# hi\n; there\n";
show 'no equals sign at all',     "just words\n";
```

```output
value containing =               -> parsed, _
key containing a space           -> parsed, _
bracket inside a key             -> parsed, s
section name with spaces         -> parsed, my section
indented key                     -> parsed, _
CRLF line endings                -> parsed, _
only comments                    -> parsed, 
no equals sign at all            -> Nil
```

Keys may contain spaces and brackets; only `#`, a leading `[`, `;` and `=` are
excluded. A value containing `=` survives, because the split is on the first
one.

## The one thing to know

A file with no trailing newline does not parse, and the failure is reported as
`Nil`.

```raku name="newline-trap"
use Config::INI;

say 'with a trailing newline    : ', Config::INI::parse("a=b\n").defined;
say 'without one                : ', Config::INI::parse("a=b").defined;
say 'a section without one      : ', Config::INI::parse("[s]\nk=v").defined;
say '';
say 'the grammar\'s keyval token ends in <.eol>+, and eol requires a literal';
say 'newline — so the last line of a trimmed file is unmatchable.';
say '';
say 'and the failure is not an exception:';
my $r = Config::INI::parse("a=b");
say '  the return value is defined : ', $r.defined;
```

```output
with a trailing newline    : True
without one                : False
a section without one      : False

the grammar's keyval token ends in <.eol>+, and eol requires a literal
newline — so the last line of a trimmed file is unmatchable.

and the failure is not an exception:
  the return value is defined : False
```

`INI.parse` returns `Nil`, the module calls `.ast` on it, `Nil` absorbs the
method call, and you get `Nil` back. Assigning that to a `my %conf` then gives
you an empty hash indistinguishable from a legitimately empty configuration on
one engine, and an `X::Hash::Store::OddNumber` naming neither the file nor the
newline on the other.

Editors that strip trailing newlines, and heredocs assembled by hand, hit this
constantly. Append a newline before parsing.

## Where the two engines differ

On what happens when you assign that `Nil` to a hash. Raku++ accepts
`my %h = Nil` silently and gives you `{}`; Rakudo throws
`X::Hash::Store::OddNumber`. Neither message mentions the missing newline,
which is the actual cause.

And with no qualification, `parse(...)` resolves on Raku++ and is a
compile-time undeclared routine on Rakudo — a trap for anyone developing on
one engine and shipping to the other. Qualify it, as every example here does.

Three things that are the same on both and are worth knowing before you trust
a parse. A **repeated `[section]` header discards everything from the earlier
copy**, and a repeated key keeps only the last value, neither reported. A `#`
or `;` **anywhere** in a value truncates it, with no escaping mechanism. And
`Config::INI::Writer::dump({})` returns an undefined `Any`, not `""`.

The distribution's name is `Config::Ini` while the modules are `Config::INI`
and `Config::INI::Writer`, and its metadata states the licence as
`NOASSERTION`.
