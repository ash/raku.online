---
name: Test::META
version: 0.0.20
auth: zef:jonathanstowe
kind: Distribution · testing
summary: One test that proves your distribution's META6.json is complete,
  parseable and honest — before an installer or the ecosystem indexer finds
  out it is not.
status: full
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

```raku name="meta-ok-passes"
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

```raku name="meta-ok-fails"
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

Nothing on this page any more: both outputs above are the same bytes under
Raku++ and under Rakudo — banner, indented checks, closing inner plan,
verdict — and the site build fails if that stops being true. The badge
said *divergent* when this page was first written, for two reasons this
section used to name, and their story is worth keeping.

**The formatting** was the visible one. Raku++'s Test printed neither the
`# Subtest:` banner nor the subtest's own closing plan (`    1..10`), so
the two engines' outputs could only be shown as "one run" apiece.
Harnesses accept both shapes, but strict TAP consumers — the
[TAP](/modules/tap/) module's own subtest parser among them — key nested
blocks off exactly those lines.

**The answer** was the serious one: check 9 — *version is present and
doesn't have an asterisk* — **passed under Raku++ for a version of
`"*"`**, precisely what it exists to reject. The cause sat two layers
down. `Version.new('*').parts` held a `Whatever` where Rakudo stores the
plain string `'*'`; META6's innocent `$ver.parts[0] eq 'v'` probe curried
that Whatever into a closure, a closure is true, so the strip-the-v branch
ran and left an *empty* version — whose empty parts the asterisk check
then waved through vacuously. A wildcard version in a real dist would have
sailed into the ecosystem under Raku++ alone.

Both fixes landed in the engine the day this page found them, pinned by
[subtest-tap-format.raku and
version-star-parts.raku](https://github.com/ash/rakupp/tree/main/t/regression);
`meta-ok` now answers — and spells — its verdicts identically on both
engines.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Test::META`, which brings `META6`, `URI`
   and `License::SPDX` with it — ten distributions in all.
3. **Test** — the distribution's own suite: 3 files, green.
4. **Run** — both examples on this page, twice under each engine, as the
   site is built; their outputs are compared byte for byte.

The two divergences this page uncovered are fixed and pinned by regression
files; the badge flipped from *divergent* to *full* the day `meta-ok`
started answering the same on both engines.
