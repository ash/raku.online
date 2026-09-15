---
name: X::Intl
version: 0.1
auth: zef:guifa
kind: Distribution · exceptions
summary: Two empty marker roles so internationalization libraries can tag
  their exceptions with a common type — and one of them does not compose.
status: divergent
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:guifa/X::Intl
source: git://github.com/alabamenhu/XIntl.git
---

## What it is for

A program using four internationalization libraries wants one `CATCH` that
handles "a locale problem" without naming all four. That needs a type the
four libraries agree on, and it needs to be a role, because each library's
exception already has a superclass of its own.

This distribution is that type, and nothing else: two empty roles, no
methods, no attributes, no exports.

## Composing it

```raku name="basics"
use X::Intl;

class X::Bad::Locale does X::Intl {
    has Str $.tag;
    method message { "unusable locale tag: $!tag" }
}

my $e = X::Bad::Locale.new(tag => 'xx-YY-zz');
say 'message        : ', $e.message;
say '~~ X::Intl     : ', $e ~~ X::Intl;
say '~~ Exception   : ', $e ~~ Exception;
say '';
my $caught = try { $e.throw };
say 'caught as X::Intl : ', $! ~~ X::Intl;
say '  its message     : ', $!.message;
say '';
say 'that is the whole use case, and it works on both engines.';
```

```output
message        : unusable locale tag: xx-YY-zz
~~ X::Intl     : True
~~ Exception   : True

caught as X::Intl : True
  its message     : unusable locale tag: xx-YY-zz

that is the whole use case, and it works on both engines.
```

The role supplies no `message`, so you must write one — composing the role is
not enough to make a usable exception.

## The warning half

```raku name="warn"
use CX::Warn::Intl;

say 'the sibling role is CX::Warn::Intl, in its own unit:';
say '  use X::Intl does NOT give it to you on Rakudo — `use` it separately.';
say '';
class CX::Locale::Fallback does CX::Warn::Intl {
    has Str $.wanted;
    has Str $.used;
    method message { "no data for $!wanted; fell back to $!used" }
}
my $w = CX::Locale::Fallback.new(wanted => 'gsw-CH', used => 'de-CH');
say 'a composed warning : ', $w.message;
say '  ~~ CX::Warn::Intl : ', $w ~~ CX::Warn::Intl;
```

```output
the sibling role is CX::Warn::Intl, in its own unit:
  use X::Intl does NOT give it to you on Rakudo — `use` it separately.

a composed warning : no data for gsw-CH; fell back to de-CH
  ~~ CX::Warn::Intl : True
```

## The one thing to know

`role X::Intl is Exception` is the whole distribution, and under Raku++ that
`is Exception` does not reach the classes that compose the role — so you get
something that type-checks as an `Exception` and does not behave like one.

```raku name="parents"
use X::Intl;

class Boom does X::Intl { method message { 'parametros invalidos' } }

say 'Boom ~~ Exception : ', Boom ~~ Exception;
say 'Boom.^parents     : engine-dependent — see below';
say '';
say 'Rakudo reports ("Exception",) there; Raku++ reports ("Any",).';
say 'The smart-match is True on both, which is why this hides — but on';
say 'Raku++ the class does not inherit Exception`s behaviour, so .gist';
say 'falls back to Mu`s object dump instead of showing the message, and';
say 'an uncaught one prints "parametros invalidos\n  (Boom)" rather than';
say 'a backtrace line.';
say '';
say 'test with ~~, never with ^parents, and never rely on .gist:';
my $e = Boom.new;
say '  the portable way to show it : ', $e.message;
```

```output
Boom ~~ Exception : True
Boom.^parents     : engine-dependent — see below

Rakudo reports ("Exception",) there; Raku++ reports ("Any",).
The smart-match is True on both, which is why this hides — but on
Raku++ the class does not inherit Exception`s behaviour, so .gist
falls back to Mu`s object dump instead of showing the message, and
an uncaught one prints "parametros invalidos\n  (Boom)" rather than
a backtrace line.

test with ~~, never with ^parents, and never rely on .gist:
  the portable way to show it : parametros invalidos
```

## Where the two engines differ

Exactly the gap above, and it is the whole point of the distribution — a role
whose only content is `is Exception`. Rakudo is right here.

```raku name="sibling"
use X::Intl;
use CX::Warn::Intl;

say 'both roles, both explicitly used:';
say '  X::Intl        : ', X::Intl.^name;
say '  CX::Warn::Intl : ', CX::Warn::Intl.^name;
say '';
say 'Raku++ additionally makes CX::Warn::Intl visible after `use X::Intl`';
say 'alone, because a `use` of one unit there resolves a sibling unit of';
say 'the same distribution. Rakudo does not. Write both `use` lines.';
say '';
say 'introspecting the role groups is not portable either —';
say 'X::Intl.^parents is ("Exception",) on Raku++ and empty on Rakudo.';
say 'Check with ~~ instead.';
```

```output
both roles, both explicitly used:
  X::Intl        : X::Intl
  CX::Warn::Intl : CX::Warn::Intl

Raku++ additionally makes CX::Warn::Intl visible after `use X::Intl`
alone, because a `use` of one unit there resolves a sibling unit of
the same distribution. Rakudo does not. Write both `use` lines.

introspecting the role groups is not portable either —
X::Intl.^parents is ("Exception",) on Raku++ and empty on Rakudo.
Check with ~~ instead.
```
