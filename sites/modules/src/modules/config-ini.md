---
name: Config::INI
version: 1.2
auth: zef:raku-community-modules
kind: Distribution · configuration
summary: The classic `key = value` file with `[sections]`, read into a hash
  of hashes and written back out — the format every deployment tool and
  half of Windows still speaks.
status: full
suite: 3 files, green
tested: 2026-09-14
raku-land: https://raku.land/zef:raku-community-modules/Config::INI
source: https://github.com/raku-community-modules/Config-INI
---

## What it is for

INI is the settings format that predates all the others and outlived most:
`git config`, `.editorconfig`, `php.ini`, systemd units, every Windows
program with a `.ini` beside it. It has no specification, which is why it
has no core module, and a handful of conventions that this distribution
implements: a `[section]` header starts a group, `key = value` fills it,
`#` and `;` start comments, and keys before the first header belong to a
group of their own. Five distributions depend on it.

## Reading and writing

```raku name="parse-and-write"
use Config::INI;
use Config::INI::Writer;

my %ini = Config::INI::parse(q:to/INI/);
    name = demo
    [db]
    host = localhost
    port = 5432
    [db.replica]
    host = replica.internal
    INI
say %ini.keys.sort.join(',');
say %ini<_><name>, ' ', %ini<db><port>, ' ', %ini<db.replica><host>;
say %ini<db><port> + 1;
print Config::INI::Writer::dump({ name => 'demo', db => { host => 'localhost' } });
```

```output
_,db,db.replica
demo 5432 replica.internal
5433
name=demo

[db]
host=localhost
```

`parse` takes the text (`parse-file` takes a path) and answers a hash of
hashes: one inner hash per section, and the keys written before any header
under the section named `_`. Values are strings — `5432` is a `Str` that
happens to look like a number, and Raku's arithmetic coerces it, but a `+`
or an `Int` type constraint downstream is where you find out. `[db.replica]`
is a section called `db.replica`, not a `replica` inside `db`: dots have no
meaning here, and the file's authors used them for the reader's eye.

## The one thing to know

The writer walks its hashes in hash order. `dump` writes the top-level
scalars, then each section with its keys, in whatever order `.kv` yields —
and under Rakudo that order is randomised per process, so a config with two
sections is written in one order today and the other tomorrow. The file is
still correct, since INI does not care, but a diff of it does, and so does
a person reading it. The example writes one scalar and one section for
exactly that reason. If you want a stable file, build the text yourself in
the order you chose; the writer is fourteen lines and has no option for it.
