---
name: Config::Clever
version: 1.0.0
kind: Distribution · configuration
summary: Layered JSON configuration by convention — a default file, an
  environment file and a machine-local override, merged in that order from
  one directory.
status: full
suite: 1 file, green
tested: 2026-09-15
license: MIT
depends: JSON::Tiny
raku-land: https://raku.land/?/Config::Clever
source: https://github.com/ShaneKilkelly/perl6-config-clever
---

## What it is for

The same program runs on a laptop, in continuous integration and in
production, and wants mostly the same settings in each with a few
deliberate differences. The pattern that has settled across a dozen
ecosystems is three layers: a base file everyone shares, a file named after
the environment, and a machine-local file that is not in version control.
Later files win, missing ones are skipped.

This distribution is that convention over a directory of JSON. There is
nothing to configure about the configuration: the three names are fixed as
`default.json`, `<environment>.json` and `local-<environment>.json`.

## Three layers

```raku name="layers"
use Config::Clever;

my $dir = $*TMPDIR.add("cfg-{$*PID}");
$dir.mkdir;
$dir.add('default.json').spurt:
    '{ "app": "demo", "port": 8080, "debug": false }';
$dir.add('production.json').spurt:
    '{ "port": 80 }';
$dir.add('local-production.json').spurt:
    '{ "debug": true }';

sub show($label, %c) {
    say $label, ': ', %c.keys.sort.map({ "$_=" ~ %c{$_} }).join(' ');
}

show 'default   ', Config::Clever.load(:config-dir($dir.Str));
show 'production', Config::Clever.load(:environment<production>, :config-dir($dir.Str));
show 'staging   ', Config::Clever.load(:environment<staging>, :config-dir($dir.Str));

.unlink for $dir.dir;
$dir.rmdir;
```

```output
default   : app=demo debug=False port=8080
production: app=demo debug=True port=80
staging   : app=demo debug=False port=8080
```

Asking for an environment with no file of its own is not an error: the base
file is all there is, and that is the third line. The result is a plain
`Hash`, so everything downstream is ordinary Raku.

## The one thing to know

The merge is one level deep. A nested object in a later file **replaces**
the whole object rather than merging into it, so overriding one field of a
section silently deletes its siblings:

```raku name="nested"
use Config::Clever;

my $dir = $*TMPDIR.add("cfgn-{$*PID}");
$dir.mkdir;
$dir.add('default.json').spurt:
    '{ "app": "demo", "db": { "host": "localhost", "port": 5432, "name": "devdb" } }';
$dir.add('production.json').spurt:
    '{ "db": { "host": "db.internal" } }';

my %base = Config::Clever.load(:config-dir($dir.Str));
say 'base db   : ', %base<db>.keys.sort.join(',');

my %prod = Config::Clever.load(:environment<production>, :config-dir($dir.Str));
say 'prod top  : ', %prod.keys.sort.join(',');
say 'prod db   : ', %prod<db>.keys.sort.join(',');

.unlink for $dir.dir;
$dir.rmdir;
```

```output
base db   : host,name,port
prod top  : app,db
prod db   : host
```

The top-level keys merge exactly as advertised — `app` survives from the
base file — and then the merge stops. `db` in the production file is not
combined with `db` in the base file; it is put in its place, and the port
and database name are gone. Nothing warns, and the shallow case works, so
the breakage only appears the first time someone nests a section.

Write nested overrides out in full, or flatten the configuration so that
every key is top-level. Two more things to know before relying on it: a
`config-dir` that does not exist returns an empty hash rather than failing,
so a typo is indistinguishable from an empty configuration, and malformed
JSON is not caught — the parser's exception comes straight through with its
own type name on it.
