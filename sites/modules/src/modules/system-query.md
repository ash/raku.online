---
name: System::Query
version: 0.1.6
auth: zef:tony-o
kind: Distribution · configuration
summary: Collapses a nested config by environment, distro, kernel or backend —
  and `by-kernel` reads `$*DISTRO`.
status: divergent
suite: 5 files, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:tony-o/System::Query
source: git://github.com/tony-o/p6-warthog.git
---

## What it is for

One configuration file, several machines. This distribution lets the file
carry its own branches — `by-env.DEPLOY_MODE`, `by-distro.name`,
`by-kernel.name` — and collapses them against the running system, leaving a
plain structure behind.

## Collapsing

```raku name="basics"
use System::Query;

my %*ENV-SPIKE;   # not used; the module reads the real %*ENV
{
    my %*ENV = SPIKE_MODE => 'blue';
    my %config = %(
        'by-env.SPIKE_MODE' => %( blue => 'chose blue', green => 'chose green' ),
    );
    say 'by-env      : ', system-collapse(%config).raku;

    say 'by-env-exists, set   : ', system-collapse(%(
        'by-env-exists.SPIKE_MODE' => %( yes => 'present', no => 'absent' ))).raku;
    say 'by-env-exists, unset : ', system-collapse(%(
        'by-env-exists.NO_SUCH' => %( yes => 'present', no => 'absent' ))).raku;
    say '';
    say 'a branch with no matching key is a hard die, so give every';
    say 'by-env a catch-all or be sure of the value:';
    my $r = try system-collapse(%( 'by-env.SPIKE_MODE' => %( green => 'only green' ) ));
    say '  no branch for "blue" -> ', $! ?? 'refused' !! $r.raku;
}
say '';
say 'a non-Hash, non-Array value is returned unchanged:';
say '  ', system-collapse('a bare string').raku;
say '  ', system-collapse(42).raku;
```

```output
by-env      : "chose blue"
by-env-exists, set   : "present"
by-env-exists, unset : "absent"

a branch with no matching key is a hard die, so give every
by-env a catch-all or be sure of the value:
  no branch for "blue" -> refused

a non-Hash, non-Array value is returned unchanged:
  "a bare string"
  42
```

```raku name="distro"
use System::Query;

say 'the reference points on this machine:';
say '  $*DISTRO.name = ', $*DISTRO.name;
say '  $*KERNEL.name = ', $*KERNEL.name;
say '';
my %config = %( "by-distro.name" => %( $*DISTRO.name => 'the distro branch',
                                       ''           => 'fallback' ) );
say 'by-distro.name : ', system-collapse(%config).raku;
say '';
say "the '' key is a catch-all, and version keys take a + or - suffix:";
my %ver = %( 'by-distro.version' => %( '0.0.1+' => 'at least 0.0.1' ) );
say 'by-distro.version : ', system-collapse(%ver).raku;
```

```output
the reference points on this machine:
  $*DISTRO.name = macos
  $*KERNEL.name = darwin

by-distro.name : "the distro branch"

the '' key is a catch-all, and version keys take a + or - suffix:
by-distro.version : "at least 0.0.1"
```

## The one thing to know

`by-kernel` and `by-backend` both read `$*DISTRO`. The code selects the right
object and then never uses it.

```raku name="wrong-object"
use System::Query;

say 'the module`s own line is:';
say '  my $PTR   = $/[0] eq "distro" ?? $*DISTRO !! … !! $*BACKEND;';
say '  my $value = follower($path, 1, $*DISTRO);   # $PTR discarded';
say '';
my %by-kernel-real = %( "by-kernel.name" => %( $*KERNEL.name => 'kernel branch' ) );
my $r = try system-collapse(%by-kernel-real);
say 'by-kernel keyed on the real kernel name : ',
    $! ?? 'FAILS — no such value in $*DISTRO' !! $r.raku;
say '';
my %by-kernel-distro = %( "by-kernel.name" => %( $*DISTRO.name => 'distro branch' ) );
say 'by-kernel keyed on the DISTRO name      : ',
    system-collapse(%by-kernel-distro).raku;
say '';
say 'so a config keyed on the real kernel fails, and one keyed on the';
say 'distro silently satisfies a by-kernel query. Where the two names';
say 'happen to coincide you get a silently wrong answer, not a crash.';
say '';
say 'use by-distro, and say what you mean.';
```

```output
the module`s own line is:
  my $PTR   = $/[0] eq "distro" ?? $*DISTRO !! … !! $*BACKEND;
  my $value = follower($path, 1, $*DISTRO);   # $PTR discarded

by-kernel keyed on the real kernel name : FAILS — no such value in $*DISTRO

by-kernel keyed on the DISTRO name      : "distro branch"

so a config keyed on the real kernel fails, and one keyed on the
distro silently satisfies a by-kernel query. Where the two names
happen to coincide you get a silently wrong answer, not a crash.

use by-distro, and say what you mean.
```

## A `by-*` key hijacks its whole hash

```raku name="siblings"
use System::Query;

{
    my %*ENV = SPIKE_MODE => 'blue';
    my %config = %(
        keep                => 'kept?',
        also                => 'also kept?',
        'by-env.SPIKE_MODE' => %( blue => 'branch value' ),
    );
    say 'input keys  : ', %config.keys.sort.join(', ');
    say 'output      : ', system-collapse(%config).raku;
    say '';
    say 'the `when` branches RETURN from system-collapse outright, so';
    say 'sibling keys at the same level are silently discarded.';
    say '';
    say 'and with two by-* siblings, the winner is whichever key .keys';
    say 'yields first — which varies BETWEEN PROCESSES on Rakudo and is';
    say 'stable on Raku++. A config that looks deterministic in';
    say 'development is not.';
    say '';
    say 'keep a by-* key alone in its own hash.';
}
```

```output
input keys  : also, by-env.SPIKE_MODE, keep
output      : "branch value"

the `when` branches RETURN from system-collapse outright, so
sibling keys at the same level are silently discarded.

and with two by-* siblings, the winner is whichever key .keys
yields first — which varies BETWEEN PROCESSES on Rakudo and is
stable on Raku++. A config that looks deterministic in
development is not.

keep a by-* key alone in its own hash.
```

## Where the two engines differ

Three. `$*BACKEND` exists under Raku++ (with an undefined `.name`) and not
under Rakudo. Hash iteration order is stable under Raku++ and randomised per
process under Rakudo. And an unsuffixed exact version key dies under Rakudo,
because `%( a => 1, () )` is an odd-element hash initialiser there and an
empty slip under Raku++.

```raku name="portable"
use System::Query;

say 'the shapes that behave identically on both engines:';
say '  by-env.NAME          with an explicit "" catch-all';
say '  by-distro.name       keyed on $*DISTRO.name';
say '  by-distro.version    with a + or - suffix on every key';
say '';
say 'the ones to avoid:';
say '  by-kernel / by-backend  — they read $*DISTRO';
say '  an exact version key with no suffix — dies on Rakudo';
say '  a "" catch-all on a Version-valued path — substr(*-1) on "" throws';
say '  two by-* keys in one hash — order decides, and order varies';
say '';
my %safe = %( "by-distro.name" => %( $*DISTRO.name => 'match', '' => 'fallback' ) );
say 'a safe config collapses the same way everywhere : ',
    system-collapse(%safe).raku;
```

```output
the shapes that behave identically on both engines:
  by-env.NAME          with an explicit "" catch-all
  by-distro.name       keyed on $*DISTRO.name
  by-distro.version    with a + or - suffix on every key

the ones to avoid:
  by-kernel / by-backend  — they read $*DISTRO
  an exact version key with no suffix — dies on Rakudo
  a "" catch-all on a Version-valued path — substr(*-1) on "" throws
  two by-* keys in one hash — order decides, and order varies

a safe config collapses the same way everywhere : "match"
```

One more Raku++ leniency to know about: `$*DISTRO` and `$*KERNEL` have a
`FALLBACK` there that answers any method name, so `by-distro.<anything>`
never fails — the module's own guard rail is disabled.
