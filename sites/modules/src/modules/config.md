---
name: Config
version: 3.0.4
auth: cpan:TYIL
kind: Distribution · configuration
summary: A settings object with a template of allowed keys, dotted paths
  into nested values, and readers for hashes, files, environment variables
  and XDG directories — where every change hands back a new Config.
status: full
suite: 9 files, green
tested: 2026-09-14
license: LGPL-3.0-only
depends: Hash::Merge, IO::Glob, IO::Path::XDG, Log
raku-land: https://raku.land/cpan:TYIL/Config
source: https://home.tyil.nl/git/raku/Config/
---

## What it is for

Settings come from several places and the later ones win: the defaults in
the program, then a file in the user's config directory, then the
environment, then whatever was typed on the command line. Doing that with a
plain hash means writing the merge, the dotted lookup (`db.port`) and the
"is this key even allowed" check yourself, three times over three projects.

This distribution is those three things as one object. A `Config` starts
from a **template** — a hash whose keys are the settings that exist and
whose values are their defaults — and then layers other sources onto it:
another hash, a file, the environment, the XDG config directories. Eleven
distributions build on it, mostly the author's own tools.

## Layers

```raku name="layers"
use Config;

my $defaults = Config.new({ name => 'app', port => 8080, db => { host => 'localhost', port => 5432 } },
                          :!from-env, :!from-xdg);
say $defaults.get('db.port');
say $defaults.get('db.user', 'nobody');
say $defaults.has('db.host'), ' ', $defaults.has('db.user');

my $site = $defaults.read({ port => 9090, db => { host => 'db.internal' } });
say $site.get('port'), ' ', $site.get('db.host'), ' ', $site.get('db.port');
say $defaults.get('port');
say $site.keys.sort.join(',');
```

```output
5432
nobody
True False
9090 db.internal 5432
8080
db.host,db.port,name,port
```

`get` takes a dotted path and an optional fallback, `has` answers whether the
path is set, and `keys` lists the leaves. `read` with a hash merges it in
**and returns a new object** — the second `$defaults.get('port')` is still
8080 — which is the shape the author chose for every mutator: `set` and
`unset` return a new Config too, and the old one is what it was.

Two switches in `new` are worth knowing on day one, because they default to
*on*: `:from-env` reads settings out of environment variables named after
the config, and `:from-xdg` looks for files in the XDG config directories.
Both are the point of the module in a deployed program and a surprise in a
test, which is why the examples turn them off.

Reading a file is `read('settings.json')`, and the parser is chosen by the
extension — but this distribution ships **no parsers**. Each format is its own
distribution (`Config::Parser::json`, `::yaml`, `::toml`), and without one
installed the read fails after the file is found. A path that does not exist
throws `X::Config::FileNotFound` first.

## The one thing to know

The copy that `set` makes is one level deep. A top-level key behaves as the
immutable design promises; a nested one is reached through a hash the new
object still shares with the old, so the write lands in both:

```raku name="write-through"
use Config;

my $c = Config.new({ port => 8080, db => { port => 5432 } }, :!from-env, :!from-xdg);
my $d = $c.set('port', 9090);
say $c.get('port'), ' ', $d.get('port');
my $e = $c.set('db.port', 1);
say $c.get('db.port'), ' ', $e.get('db.port');
```

```output
8080 9090
1 1
```

`read` does not have this problem — it merges through `Hash::Merge`, which
builds fresh hashes on the way down. So if you keep an old Config around to
compare against or to fall back to, change nested values with `read({ db =>
{ port => 1 } })` rather than `set('db.port', 1)`, and the old object stays
what it was. The same output appears under both engines: this is the
module's copy, not the interpreter's.
