---
name: Test::META
version: 0.0.20
auth: zef:jonathanstowe
kind: Distribution · testing
summary: One test that proves your distribution's META6.json is complete,
  parseable and honest — before an installer or the ecosystem indexer finds
  out it is not.
status: divergent
license: Artistic-2.0
depends: Test, META6, URI, License::SPDX
suite: 3 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:jonathanstowe/Test::META
source: https://github.com/jonathanstowe/Test-META
---

## What it is for

Every distribution ships a `META6.json`, and everything downstream trusts
it: `zef` and `rakupp install` resolve dependencies from it, raku.land
renders it, the REA archives it. A typo in it does not fail loudly at your
desk — it fails quietly at someone else's, weeks later. This module is the
smoke alarm: one exported sub, `meta-ok`, which runs a subtest over the
file and tells you *today*.

Thirty-four distributions call it from their own suites, which makes it the
most-depended-on module of the "test your project, not your code" kind. The
usual installation is one file, `t/030-meta.t`, containing exactly this:

```raku fragment
use Test;
use Test::META;

plan 1;
meta-ok;
```

For this page the example has to carry its own distribution with it, so it
builds a tiny one in a temporary directory and points the test at it — the
two dynamic variables at the end are hooks the module provides for exactly
that, and everything before them is a perfectly ordinary dist:

```raku sample name="meta-ok-passes"
use Test;
use Test::META;

my $dist = $*TMPDIR.add("meta-demo-$*PID");
mkdir $dist;
mkdir $dist.add('lib');
$dist.add('lib/Greeter.rakumod').spurt('unit module Greeter;');
$dist.add('META6.json').spurt(q:to/END/);
    {
        "perl": "6.d",
        "name": "Greeter",
        "version": "0.0.1",
        "description": "Says hello",
        "auth": "zef:example",
        "authors": ["A. Author"],
        "license": "Artistic-2.0",
        "provides": { "Greeter": "lib/Greeter.rakumod" },
        "source-url": "https://github.com/example/Greeter.git"
    }
    END

my $*META-FILE = $dist.add('META6.json');
my $*DIST-DIR  = $dist;
plan 1;
meta-ok;
```

```output
1..1
# Subtest: Project META file is good
    ok 1 - have a META file
    ok 2 - META parses okay
    ok 3 - have all required entries
    ok 4 - 'provides' looks sane
    ok 5 - Optional 'authors' and not 'author'
    ok 6 - License is correct
    ok 7 - name has a '::' rather than a hyphen (if this is intentional please pass :relaxed-name to meta-ok)
    ok 8 - no 'v' in version strings (meta-version greater than 0)
    ok 9 - version is present and doesn't have an asterisk
    ok 10 - have usable source
    1..10
ok 1 - Project META file is good
```

Ten checks in the one subtest, and the list is the documentation: the file
exists, it parses, the mandatory fields are all present, every module named
under `provides` maps to a file that actually exists, `authors` (plural) is
used rather than the obsolete `author`, the license is a known SPDX
identifier, the name uses `::` rather than a hyphen, no version string
carries a stray `v` prefix, the version is not `*`, and `source-url` points
somewhere usable.

## When it fails, it says why

Break the distribution — here, `provides` names a file that does not exist,
the classic casualty of a rename — and the subtest pinpoints it. The
*reason* arrives as a TAP diagnostic on standard error
(`# file for 'Greeter' 'lib/Greeter.rakumod' does not exist`), so it shows
in your `prove6` output but not in the pass/fail stream below:

```raku sample name="meta-ok-fails"
use Test;
use Test::META;

my $dist = $*TMPDIR.add("meta-broken-$*PID");
mkdir $dist;
$dist.add('META6.json').spurt(q:to/END/);
    {
        "perl": "6.d",
        "name": "Greeter",
        "version": "0.0.1",
        "description": "Says hello",
        "auth": "zef:example",
        "authors": ["A. Author"],
        "license": "Artistic-2.0",
        "provides": { "Greeter": "lib/Greeter.rakumod" },
        "source-url": "https://github.com/example/Greeter.git"
    }
    END

my $*META-FILE = $dist.add('META6.json');
my $*DIST-DIR  = $dist;
plan 1;
meta-ok;
```

```output
1..1
# Subtest: Project META file is good
    ok 1 - have a META file
    ok 2 - META parses okay
    ok 3 - have all required entries
    not ok 4 - 'provides' looks sane
    ok 5 - Optional 'authors' and not 'author'
    ok 6 - License is correct
    ok 7 - name has a '::' rather than a hyphen (if this is intentional please pass :relaxed-name to meta-ok)
    ok 8 - no 'v' in version strings (meta-version greater than 0)
    ok 9 - version is present and doesn't have an asterisk
    ok 10 - have usable source
    1..10
not ok 1 - Project META file is good
```

The one adverb is `:relaxed-name`, for the handful of distributions whose
hyphenated name is intentional — `meta-ok(:relaxed-name)` turns check 7
from a failure into a pass and says so in its description.

In your own distribution you need neither `$*META-FILE` nor `$*DIST-DIR`:
by default the module looks for the META file in the directory above the
test file, which is the repository root of every conventionally laid-out
dist. Authors who keep author-only tests separate put this in `xt/`
instead of `t/`, so their users' installs do not depend on Test::META
being present.

## Where the two engines differ

Both outputs above are labelled *one run* because the two engines format a
subtest differently, and one check answers differently.

**The formatting**: Rakudo's Test prints a `# Subtest:` banner line before
the indented tests and closes them with their own plan (`1..10`), as shown
above. Raku++'s Test currently prints neither — the indented lines and the
final verdict only. Harnesses accept both, but strict TAP consumers (the
[TAP](/modules/tap/) module's subtest parser among them) expect the inner
plan, so this is on the engine's list.

**The answer**: check 9 — *version is present and doesn't have an
asterisk* — currently **passes under Raku++ for a version of `"*"`**, which
is precisely what it exists to reject; Rakudo fails it, correctly. A wildcard
version in a real dist would sail through this check under Raku++ alone.
That is an engine-side comparison bug, found writing this page, and it is
why the badge at the top says *divergent* — run your META tests under
Rakudo until it is fixed.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Test::META`, which brings `META6`, `URI`
   and `License::SPDX` with it — ten distributions in all.
3. **Test** — the distribution's own suite: 3 files, green.
4. **Run** — both examples on this page under each engine, as the site is
   built; their outputs are recorded as one run each, for the formatting
   reason above.

The version-check divergence is pinned for the engine to fix; the badge
flips to *full* when `meta-ok` answers the same on both engines.
