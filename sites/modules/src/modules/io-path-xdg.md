---
name: IO::Path::XDG
version: 0.2.0
auth: cpan:TYIL
kind: Distribution · files
summary: The freedesktop.org base directories as six subs — config, data
  and cache homes, their search lists, and the runtime directory — with the
  specification's defaults filled in.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: AGPL-3.0
raku-land: https://raku.land/?/IO::Path::XDG
source: https://home.tyil.nl/git/raku/IO::Path::XDG/
---

## What it is for

Where should a program put its settings on Linux? Under `~/.config`, unless
the user has moved it, in which case an environment variable says where.
Its cache goes somewhere else again, its data somewhere else again, and
system-wide copies of each are searched in a documented order. The rules
are the XDG Base Directory specification and they are not hard — they are
just numerous enough that most programs implement two of them and guess the
rest.

This distribution answers all six questions.

## The directories

```raku name="directories"
%*ENV<XDG_CONFIG_HOME> = '/home/ada/.config';
%*ENV<XDG_DATA_HOME>   = '/home/ada/.local/share';
%*ENV<XDG_CACHE_HOME>  = '/home/ada/.cache';
%*ENV<XDG_CONFIG_DIRS> = '/etc/xdg:/opt/site/etc';
%*ENV<XDG_DATA_DIRS>:delete;

use IO::Path::XDG;

say xdg-config-home;
say xdg-data-home.add('myapp');
say xdg-cache-home.basename;
say xdg-config-dirs.join(' ');
say xdg-data-dirs.join(' ');
say xdg-config-home.^name;
```

```output
"/home/ada/.config".IO
"/home/ada/.local/share/myapp".IO
.cache
/home/ada/.config /etc/xdg /opt/site/etc
/home/ada/.local/share /usr/local/share /usr/share
IO::Path
```

The environment is pinned inside the example so it prints the same
everywhere; a real program leaves it alone and takes what the user
configured. Each answer is an `IO::Path`, so `.add('myapp')` gives the
directory to create. The two search lists put the user's own directory
first, which is the order a config file should be looked for in, and
`xdg-data-dirs` shows the specification's defaults because that variable
was deliberately unset.

## The one thing to know

A variable that is **set but empty** is honoured as a real value, where the
specification says to treat it as unset:

```raku name="empty-variable"
%*ENV<XDG_CONFIG_HOME> = '';

use IO::Path::XDG;

# the guard: treat an empty value as absent, as the specification says
sub config-home-or-default {
    my $set = %*ENV<XDG_CONFIG_HOME>;
    ($set // '').trim ?? $set.IO !! $*HOME.add('.config')
}

say config-home-or-default().add('app.toml').absolute.starts-with($*HOME.Str);
say (%*ENV<XDG_CONFIG_HOME> // '').chars;
say (%*ENV<XDG_CONFIG_HOME>:exists);
```

```output
True
0
True
```

`XDG_CONFIG_HOME=` with nothing after it is a common shape — it appears in
minimal environments, in container images, in systemd units and in
continuous integration. The specification says a variable set to the empty
string is to be treated as though it were absent. This module tests only
whether the name exists, so it takes the empty string literally and hands
back the empty path.

What happens next depends on the engine, which is why the example above
guards instead of demonstrating. Under Raku++ the empty path is allowed and
a config file resolves to `/app.toml` — the file system root. Under Rakudo
constructing that path throws. Same environment, same code, a crash on one
engine and a write to the root directory on the other.

Do what the guard does: treat an empty value as unset before calling, or
check that what comes back is absolute and under the home directory.

## Where the two engines differ

Only in the empty-variable case above, and the difference is which failure
you get rather than whether there is one. Raku++ permits an empty
`IO::Path` and Rakudo refuses to construct one, so the same call answers a
useless path on one engine and throws on the other. That is why the example
guards rather than calling straight through — a page example has to print
the same thing on both. Every other function here behaves identically.

One more thing worth knowing whichever engine you are on:
`xdg-runtime-dir` appends the process identifier to whatever fallback it
picks when the variable is unset, so it answers a different path in every
process and does not create it. It is not a stable location, and you must
make the directory yourself.
