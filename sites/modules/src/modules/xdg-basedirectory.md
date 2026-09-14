---
name: XDG::BaseDirectory
version: 0.0.15
auth: zef:jonathanstowe
kind: Distribution · files
summary: Where a program should keep its config, data, cache and state on a
  Unix desktop, by the freedesktop.org rules — the environment variables
  read, the defaults filled in, and the search lists in order.
status: full
suite: 5 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:jonathanstowe/XDG::BaseDirectory
source: https://github.com/jonathanstowe/XDG-BaseDirectory
---

## What it is for

A well-behaved program on Linux does not scatter dotfiles across the home
directory: its settings go under `~/.config`, its data under
`~/.local/share`, its cache under `~/.cache`, and each of those can be
moved by an environment variable the user sets. The rules are the XDG Base
Directory specification, and they have enough cases — a home directory
plus a search list for each kind, with defaults when the variables are
unset — that every program gets one of them wrong. This distribution reads
the variables and answers the questions. Nine distributions build on it,
`Config` among them.

## The directories

```raku name="directories"
%*ENV<XDG_CONFIG_HOME> = '/home/ada/.config';
%*ENV<XDG_DATA_HOME>   = '/home/ada/.local/share';
%*ENV<XDG_CACHE_HOME>  = '/home/ada/.cache';
%*ENV<XDG_STATE_HOME>  = '/home/ada/.local/state';
%*ENV<XDG_CONFIG_DIRS> = '/etc/xdg:/opt/site/etc';
%*ENV<XDG_DATA_DIRS>:delete;
%*ENV<XDG_RUNTIME_DIR> = '/run/user/1000';

use XDG::BaseDirectory :terms;

say config-home;
say data-home.add('myapp');
say cache-home.basename, ' ', state-home.basename;
say config-dirs.join(' ');
say data-dirs.join(' ');
say runtime-dir;
```

```output
"/home/ada/.config".IO
"/home/ada/.local/share/myapp".IO
.cache state
/home/ada/.config /etc/xdg /opt/site/etc
/home/ada/.local/share /usr/local/share /usr/share
"/run/user/1000".IO
```

The environment is set inside the example so that it prints the same on
every machine; in a real program you leave it alone and take what the user
configured. Each answer is an `IO::Path`, so `data-home.add('myapp')` is
the directory to create. The two `-dirs` lists are search paths with the
home entry first — the order in which a config file should be looked for —
and `data-dirs` shows the specification's defaults when the variable is
unset.

## The one thing to know

`use XDG::BaseDirectory;` imports nothing. The seven names are exported as
**terms** — no parentheses, as the example calls them — and only under the
`:terms` tag, so the plain `use` compiles and the first `config-home` is
an undeclared routine. The other way in is the class:
`XDG::BaseDirectory.new.config-home`, which also carries the methods that
search the lists for a file (`load-config-paths`, `load-first-config`).

The terms share one object, built the first time any of them is called.
After that the environment is not read again, so a variable changed later
in the program is not seen — the class form reads fresh on every `.new`,
which is the one to use in a test that changes the environment between
cases.
