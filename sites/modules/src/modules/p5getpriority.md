---
name: P5getpriority
version: 0.0.8
auth: zef:lizmat
kind: Distribution · system
summary: Scheduling priority and process groups — getpriority, setpriority,
  getppid, getpgrp and setpgrp — bound directly, returning plain integers.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getpriority
source: https://github.com/lizmat/P5getpriority.git
---

## What it is for

A long-running batch job that should not compete with interactive work wants
to lower its own priority; a supervisor wants to know what priority a child is
running at. That is `nice`, and underneath it `getpriority(2)` and
`setpriority(2)`.

Unlike the database modules in the same family, there is no record reshaping
here — these are thin bindings returning integers straight from C.

## Reading a priority

```raku name="priority"
use P5getpriority;

constant PRIO_PROCESS = 0;   # from <sys/resource.h>
constant PRIO_PGRP    = 1;
constant PRIO_USER    = 2;

# "who = 0" means "me". The absolute value is not portable; the range is.
my $me = getpriority(PRIO_PROCESS, 0);
say 'own nice value is in -20..20 : ', -20 <= $me <= 20;
say 'own nice value is an Int     : ', $me ~~ Int;
say '';
say 'process-group priority in range : ', -20 <= getpriority(PRIO_PGRP, 0) <= 20;
say 'getppid is positive             : ', getppid() > 0;
say 'getpgrp is positive             : ', getpgrp() > 0;
```

```output
own nice value is in -20..20 : True
own nice value is an Int     : True

process-group priority in range : True
getppid is positive             : True
getpgrp is positive             : True
```

The `$which` argument takes the `<sys/resource.h>` constants: 0 for a process,
1 for a process group, 2 for a user. The module exports **no constants for
them**, so you declare your own as above.

## Writing one

```raku name="setpriority"
use P5getpriority;

constant PRIO_PROCESS = 0;

# writing back the value already there is a no-op, and 0 means success
my $me = getpriority(PRIO_PROCESS, 0);
say 'setpriority to the current value : ', setpriority(PRIO_PROCESS, 0, $me);
say 'and it is unchanged              : ', getpriority(PRIO_PROCESS, 0) == $me;
```

```output
setpriority to the current value : 0
and it is unchanged              : True
```

Only the no-op form is shown here on purpose. Raising a process's nice value
is **irreversible** for a non-root process — you can be nicer, never less
nice — so an example that actually lowered the priority would leave the
program it ran in worse than it found it.

`setpgrp` is left alone entirely: moving a process out of its shell's process
group detaches it from job control.

## The one thing to know

`getpriority` signals failure by returning `-1`, and `-1` is also a perfectly
valid nice value. The module exposes no `errno`.

```raku name="minus-one-trap"
use P5getpriority;

constant PRIO_PROCESS = 0;

say 'a pid that does not exist:';
say '  getpriority(PRIO_PROCESS, 999999) = ', getpriority(PRIO_PROCESS, 999_999);
say '';
say 'a process niced to -1 would return exactly the same number,';
say 'and -1 is inside the legal range : ', -20 <= -1 <= 20;
say '';
say 'setpriority has the same ambiguity, except that 0 means success:';
say '  on a nonexistent pid : ', setpriority(PRIO_PROCESS, 999_999, 0);
```

```output
a pid that does not exist:
  getpriority(PRIO_PROCESS, 999999) = -1

a process niced to -1 would return exactly the same number,
and -1 is inside the legal range : True

setpriority has the same ambiguity, except that 0 means success:
  on a nonexistent pid : -1
```

In C the documented idiom is to clear `errno`, make the call, and inspect
`errno` afterwards. Nothing here does that, and nothing is exported that
could. So `getpriority(0, $pid)` on a pid that has gone away is byte-for-byte
the same answer as a process that has been niced to -1.

Check the pid exists separately, or use `setpriority`'s unambiguous `0` when
you need a definite answer.

## Where the two engines differ

Nowhere. Every reading, the no-op write, both process-group calls and both
failure cases produced identical output on Raku++ and Rakudo.

One introspection oddity, identical on both: `getppid` and `getpgrp` are
declared `--> uint32` and `.^name` reports `Int`, so do not expect the native
type to survive into Raku.
