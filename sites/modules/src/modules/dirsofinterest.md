---
name: DirsOfInterest
version: 1.0.0
auth: zef:patrickb
kind: Distribution · system
summary: Where an application should put its data, config, cache and logs —
  eighteen lookups, ten of which throw on macOS.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:patrickb/DirsOfInterest
source: https://sr.ht/~patrickb/DirsOfInterest/
---

## What it is for

Every platform has its own answer to "where does an application keep its
files": XDG directories on Unix, `~/Library/…` on macOS, `%APPDATA%` on
Windows. This distribution puts one set of eighteen method names over all
three, mixing in a per-platform role at construction.

## The lookups that work here

```raku name="basics"
use DirsOfInterest;

for <user-config-dir user-data-dir user-desktop-dir user-documents-dir
     user-downloads-dir user-music-dir user-pictures-dir user-videos-dir> -> $m {
    my $r = try DirsOfInterest."$m"();
    say sprintf('  %-20s %s', $m,
                $! ?? 'THROWS' !! $r.Str.subst($*HOME.Str, '~'));
}
say '';
say 'note user-videos-dir maps to ~/Movies on macOS, not ~/Videos.';
```

```output
  user-config-dir      ~/Library/Application Support
  user-data-dir        ~/Library/Application Support
  user-desktop-dir     ~/Desktop
  user-documents-dir   ~/Documents
  user-downloads-dir   ~/Downloads
  user-music-dir       ~/Music
  user-pictures-dir    ~/Pictures
  user-videos-dir      ~/Movies

note user-videos-dir maps to ~/Movies on macOS, not ~/Videos.
```

## Naming your application

```raku name="naming"
use DirsOfInterest;

DirsOfInterest.set(app-name => 'demo', app-version => '1.2');
say 'after .set(:app-name, :app-version):';
for <user-data-dir user-config-dir user-documents-dir user-music-dir> -> $m {
    say sprintf('  %-20s %s', $m,
                DirsOfInterest."$m"().Str.subst($*HOME.Str, '~'));
}
say '';
say 'the eight working lookups split into two groups with different';
say 'semantics: data and config get your name and version appended, the';
say 'six media directories do not. Setting :app-name and assuming it';
say 'applies uniformly gets you a wrong answer with no error.';
say '';
say '.set installs a process-wide singleton; .new gives you an instance:';
my $d = DirsOfInterest.new(app-name => 'other', app-version => '0.1');
say '  instance : ', $d.user-data-dir.Str.subst($*HOME.Str, '~');
say '  singleton: ', DirsOfInterest.user-data-dir.Str.subst($*HOME.Str, '~');
```

```output
after .set(:app-name, :app-version):
  user-data-dir        ~/Library/Application Support/demo/1.2
  user-config-dir      ~/Library/Application Support/demo/1.2
  user-documents-dir   ~/Documents
  user-music-dir       ~/Music

the eight working lookups split into two groups with different
semantics: data and config get your name and version appended, the
six media directories do not. Setting :app-name and assuming it
applies uniformly gets you a wrong answer with no error.

.set installs a process-wide singleton; .new gives you an instance:
  instance : ~/Library/Application Support/other/0.1
  singleton: ~/Library/Application Support/demo/1.2
```

## The one thing to know

On macOS, ten of the eighteen lookups throw — and it is not a version or an
install problem.

```raku name="broken"
use DirsOfInterest;

my @all = <site-cache-dir site-config-dir site-config-dirs site-data-dir
           site-data-dirs site-runtime-dir user-cache-dir user-config-dir
           user-data-dir user-desktop-dir user-documents-dir user-downloads-dir
           user-log-dir user-music-dir user-pictures-dir user-runtime-dir
           user-state-dir user-videos-dir>;
my @dead = @all.grep({ my $r = try DirsOfInterest."$_"(); $!.so });
say 'lookups that throw on macOS : ', @dead.elems, ' of ', @all.elems;
say '  ', @dead.join("\n  ");
say '';
say 'DirsOfInterest::MacOS calls self!append-stuff(…) — PRIVATE-method';
say 'syntax — but `append-stuff` is declared as an ordinary public method';
say 'on DirsOfInterest. There is no such private method, and because the';
say 'role is mixed in with `does` at construction, nothing catches it at';
say 'compile time.';
say '';
say 'user-state-dir fails for a second, independent reason: it calls';
say 'self.user_data_dir, with underscores, a name that does not exist.';
say '';
say 'DirsOfInterest::Unix uses the public self.append-stuff consistently';
say 'and has none of this — the defect is macOS-only, which is exactly';
say 'where a macOS developer will meet it.';
```

```output
lookups that throw on macOS : 10 of 18
  site-cache-dir
  site-config-dir
  site-config-dirs
  site-data-dir
  site-data-dirs
  site-runtime-dir
  user-cache-dir
  user-log-dir
  user-runtime-dir
  user-state-dir

DirsOfInterest::MacOS calls self!append-stuff(…) — PRIVATE-method
syntax — but `append-stuff` is declared as an ordinary public method
on DirsOfInterest. There is no such private method, and because the
role is mixed in with `does` at construction, nothing catches it at
compile time.

user-state-dir fails for a second, independent reason: it calls
self.user_data_dir, with underscores, a name that does not exist.

DirsOfInterest::Unix uses the public self.append-stuff consistently
and has none of this — the defect is macOS-only, which is exactly
where a macOS developer will meet it.
```

## The getter that writes to disk

```raku name="ensure"
use DirsOfInterest;

my $base = $*TMPDIR.add("doi-{$*PID}");
LEAVE { $base.add('demo/1.2').rmdir; $base.add('demo').rmdir; $base.rmdir }
$base.mkdir;

my $d = DirsOfInterest.new(app-name => 'demo', app-version => '1.2',
                           ensure-exists => True);
my $made = $d.append-stuff($base);
say 'append-stuff returned : …/', $made.parent.basename, '/', $made.basename;
say 'it exists on disk     : ', $made.d;
say '';
say ':ensure-exists silently mkdirs as a side effect of a GETTER. Asking';
say 'where a file should go creates the directory.';
```

```output
append-stuff returned : …/demo/1.2
it exists on disk     : True

:ensure-exists silently mkdirs as a side effect of a GETTER. Asking
where a file should go creates the directory.
```

## Where the two engines differ

Only in the wording of the failure: Raku++ says `No such private method
'!append-stuff' for invocant of type …`, Rakudo says `No such private method
'append-stuff' on …` and truncates the type name. The same ten lookups fail on
both, which is why this is a module defect rather than an engine one.

One core divergence worth knowing if you write your own checks around this:
`IO::Path.d` and `.f` on a path that does not exist return `False` under
Raku++ and throw `X::IO::DoesNotExist` under Rakudo. `.e` returns `False` on
both — test with `.e` first.

```raku name="portable"
use DirsOfInterest;

# the eight that work, wrapped so a caller gets Nil rather than an exception
sub dir(Str $which) {
    my $r = try DirsOfInterest."$which"();
    $! ?? Nil !! $r
}
for <user-config-dir user-log-dir user-documents-dir> -> $m {
    my $p = dir($m);
    say sprintf('  %-20s %s', $m,
                $p.defined ?? $p.Str.subst($*HOME.Str, '~') !! 'unavailable here');
}
say '';
say 'and note `new` is a submethod, so it is not inherited — subclassing';
say 'DirsOfInterest and calling .new bypasses the role mixin entirely and';
say 'leaves you with an object that has none of the eighteen methods.';
```

```output
  user-config-dir      ~/Library/Application Support
  user-log-dir         unavailable here
  user-documents-dir   ~/Documents

and note `new` is a submethod, so it is not inherited — subclassing
DirsOfInterest and calling .new bypasses the role mixin entirely and
leaves you with an object that has none of the eighteen methods.
```
