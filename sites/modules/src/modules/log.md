---
name: Log
version: 0.3.2
kind: Distribution · debugging
summary: A log4j-shaped logger — five levels, a pattern string, a registry
  of named loggers, and the two context stores that let a request tag every
  line it causes.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/?/Log
source: https://github.com/whity/raku-log
---

## What it is for

`say` is a fine logger until the program has more than one thing going on.
Then you want levels, so that debugging detail can be left in the code and
switched off; a format you set once rather than at every call site; and —
the part people reach for log4j to get — a way to tag every line a
particular request caused, without threading a request identifier through
every function.

That last one is what the two context stores are for: a nested stack and a
key-value map, both rendered into the pattern, both set once where the work
begins.

## Levels, patterns, contexts

```raku name="logging"
use Log;

my $log = Log.new(level => Log::TRACE, pattern => '[%c] %m%n');
$log.error('disk on fire');
$log.warn('disk warm');
$log.info('disk fine');
$log.debug('and the detail');

$log.level = Log::WARN;
$log.info('dropped now');
say $log.is-error, ' ', $log.is-info;

my $req = Log.new(level => Log::INFO, pattern => '[%c][%x][%X{user}] %m%n');
$req.ndc.push('req-7');
$req.ndc.push('shard-3');
$req.mdc.put('user', 'ada');
$req.info('handling');
$req.ndc.pop;
$req.info('one frame up');
$req.ndc.clear;
$req.mdc.delete('user');
$req.info('context gone');
```

```output
[ERROR] disk on fire
[WARN] disk warm
[INFO] disk fine
[DEBUG] and the detail
True False
[INFO][req-7 shard-3][ada] handling
[INFO][req-7][ada] one frame up
[INFO][undef][undef] context gone
```

The level methods are not declared anywhere — `FALLBACK` turns any level
name into a method, which is also why a misspelled one throws rather than
silently dropping the message. `%x` renders the nested context as a stack
and `%X{key}` picks one value out of the map; an empty one renders as the
literal word `undef`, not as nothing.

Output goes to standard output by default, and `output => $fh` sends it to
a file instead.

## The one thing to know

The message is substituted into the pattern **first**, so pattern escapes
inside your text are then expanded as if they were part of the pattern:

```raku name="injection"
use Log;

my $log = Log.new(level => Log::INFO, pattern => '[%c] %m%n');
$log.info('plain message');
$log.info('progress: 100%c done');
$log.info('a %x here');
$log.info('user said: %m');
```

```output
[INFO] plain message
[INFO] progress: 100INFO done
[INFO] a undef here
[INFO] user said: %m
```

`%m` is replaced before `%c`, `%p` and `%X{}`, so a message containing any
of those gets them interpolated. The second line prints the level in the
middle of a sentence. A message with `%p` in it publishes your process
identifier, and one with `%X{user}` publishes whatever the mapped context
holds — which is a genuine leak if the text came from outside the program.

There is no escape mechanism and no way to turn it off. Never log an
untrusted string directly; put it through a placeholder of your own, or
strip `%` from it first.

Two smaller things. The pattern is fixed at construction — it is not
`is rw`, so assigning to it dies, and the newer `Logger` distribution
(which is this same codebase renamed) is the one that lets you change it.
And `%d`, the timestamp, reads the clock at format time with no hook to
replace it, so nothing that logs with the default pattern can be compared
against a golden file.
