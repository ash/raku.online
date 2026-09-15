---
name: I18n::Simple
version: 0.1.2
kind: Distribution · language
summary: User-facing strings in flat YAML files, looked up by key with
  placeholders filled from named arguments — layered so a translation can
  be loaded over a base language.
status: full
suite: 1 file, green
tested: 2026-09-15
license: AGPL-3.0
depends: Hash::Merge, YAMLish
raku-land: https://raku.land/?/I18n::Simple
source: https://gitlab.com/tyil/perl6-i18n-Simple
---

## What it is for

The first step in translating a program is getting the strings out of the
code, and the second is filling in the parts that vary. A message is a key
and a template, the template has slots, and the slots are filled at the
call site. Everything else — plurals, gender, locale-aware number
formatting — is a much larger problem this distribution does not attempt,
which is what the name promises.

Strings live in flat YAML files. Loading a second file merges it over the
first, which is how a translation is applied on top of a base language.

## Keys, slots, and layering

```raku name="lookup"
use I18n::Simple;

my $dir = $*TMPDIR.add("i18n-{$*PID}");
$dir.mkdir;
$dir.add('en.yml').spurt: q:to/YAML/;
    greeting: "Hello, $(name)!"
    invoice: "$(name), you owe $(amount) euro."
    plain: "No placeholders here"
    YAML
$dir.add('nl.yml').spurt: q:to/YAML/;
    greeting: "Hallo, $(name)!"
    YAML

i18n-init($dir.add('en.yml').Str);
say i18n('greeting', :name<Ada>);
say i18n('invoice', :name<Ada>, :amount(42));
say i18n('plain');

i18n-init($dir.add('nl.yml').Str);
say i18n('greeting', :name<Ada>);
say i18n('invoice', :name<Ada>, :amount(42));

.unlink for $dir.dir;
$dir.rmdir;
```

```output
Hello, Ada!
Ada, you owe 42 euro.
No placeholders here
Hallo, Ada!
Ada, you owe 42 euro.
```

The second `i18n-init` merges rather than replaces, so the Dutch greeting
wins and the English invoice — which the Dutch file does not define —
survives. That is the layering the design is built on, and it means a
partial translation is usable from the first key.

Note the placeholder syntax: `$(name)`, with parentheses. Not braces, not
doubled braces, not a percent sign. Every other shape passes through as
literal text.

## The one thing to know

Forgetting the context and getting it wrong fail in opposite directions:

```raku name="missing-context"
use I18n::Simple;

my $dir = $*TMPDIR.add("i18nb-{$*PID}");
$dir.mkdir;
$dir.add('en.yml').spurt: qq:to/YAML/;
    greeting: "Hello, \$(name)!"
    YAML
i18n-init($dir.add('en.yml').Str);

say i18n('greeting', :name<Ada>);
say i18n('greeting');
say (try i18n('greeting', :other<x>)) // $!.message;

.unlink for $dir.dir;
$dir.rmdir;
```

```output
Hello, Ada!
Hello, $(name)!
Unknown variable used: name
```

With no named arguments at all the substitution is skipped entirely and the
template's own source text goes into your interface — `Hello, $(name)!`,
shown to a user. With one irrelevant argument the substitution runs, finds
no value for `name`, and throws. So the mistake that is easier to make is
the one that fails silently, and it fails by displaying markup.

Neither is a missing-key error, because there is no such thing: a key the
table does not contain is an empty string under Raku++ and an internal
error leaking out of the module under Rakudo. Check your keys with a test
that walks the YAML rather than relying on the lookup to tell you.

The YAML must be flat. A nested value is refused outright by the default
validation, and with validation turned off it loads and then renders the
nested structure stringified into your output.
