---
name: Logger
version: 0.4.6
auth: zef:whity
kind: Distribution · debugging
summary: The continuation of the Log distribution under a new name — the
  same levels, pattern and contexts, plus a settable pattern and a hook for
  the timestamp.
status: full
suite: 6 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:whity/Logger
source: https://github.com/whity/raku-log
---

## What it is for

This is the same codebase as `Log`, from the same repository, under the
name its author settled on. Everything on the [Log page](../log/) applies:
five levels, a pattern string, a registry of named loggers, and the nested
and mapped context stores.

Two things are different, and they are the two that matter most in
practice. The pattern can be changed after construction, and the timestamp
has a hook — which is what makes a logger testable, because a line with a
live clock in it cannot be compared against anything.

## A pinned timestamp

```raku name="timestamp"
use Logger;

my $log = Logger.new(
    level        => Logger::INFO,
    dt-formatter => sub ($dt) { 'TS' },
);
$log.error('disk on fire');
$log.warn('disk warm');
$log.info('disk fine');
$log.debug('dropped: level is INFO');

$log.level = Logger::TRACE;
$log.debug('now it appears');

$log.pattern = '[%c] %m%n';
$log.info('a different layout');
```

```output
[TS][ERROR] disk on fire
[TS][WARN] disk warm
[TS][INFO] disk fine
[TS][DEBUG] now it appears
[INFO] a different layout
```

`dt-formatter` replaces the `%d` placeholder's value, and a formatter that
ignores its argument and returns a constant is what a test wants. The
default pattern includes `%d`, so without this every line carries the
current time and nothing about the output is reproducible.

The formatter is handed the `DateTime`, so a real one can format it however
the deployment wants:

```raku name="formatter"
use Logger;

my $log = Logger.new(level => Logger::INFO, pattern => '[%d] %m%n');

$log.dt-formatter = sub ($x) { 'given a ' ~ $x.^name };
$log.info('what does the hook receive?');

$log.dt-formatter = sub ($dt) {
    sprintf('%04d-%02d-%02d', $dt.year, $dt.month, $dt.day)
};
$log.info('a date only');

my $a = Logger.new(level => Logger::INFO, pattern => '[%x] %m%n');
$a.ndc.push('orig');
my $b = $a.clone;
$b.ndc.push('cloned-only');
$a.info('from the original');
$b.info('from the clone');
```

```output
[given a DateTime] what does the hook receive?
[2026-09-15] a date only
[orig] from the original
[orig cloned-only] from the clone
```

`clone` copies the contexts by value, so the two loggers diverge from the
moment they are cloned — which is what you want when a request handler
takes a copy of the application logger and adds its own request identifier.

## The one thing to know

The shipped default formatter names its parameter `$self`, and it is not
the logger — it is the `DateTime`:

```raku fragment
# the default, as shipped
sub ($self) { DateTime.now.Str }
```

It ignores its argument and reads the clock a second time. So anyone who
writes a formatter trusting that name will reach for logger methods on a
`DateTime` and get a method-not-found error that makes no sense. The first
example above probes it and prints what actually arrives.

Everything on the Log page's warning about pattern-escape injection applies
here unchanged: the message goes into the pattern before the other
placeholders are expanded, so a logged string containing `%p` or `%X{…}`
has them interpolated. Under the Raku++ 3.28.0 release the class-level
registry was dead here — `Logger.get` returned nothing, because the engine
did not resolve the compile-time class name the registry keys on. That is
fixed, and both spellings work now.

If you are choosing between the two distributions: use this one. They are
the same code, and `Log` is the older name. Do not load both — you get two
registries and two incompatible level enumerations.
