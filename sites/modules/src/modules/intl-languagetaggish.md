---
name: Intl::LanguageTaggish
version: 0.2
auth: zef:guifa
kind: Distribution · language
summary: The interface every language-tag type is expected to satisfy — one
  role with four required methods — so unrelated internationalisation
  libraries can accept each other's tags.
status: full
suite: 3 files, green
tested: 2026-09-15
raku-land: https://raku.land/zef:guifa/Intl::LanguageTaggish
source: https://github.com/alabamenhu/IntlLanguageTaggish
---

## What it is for

Two libraries that both handle language tags will each have their own tag
type, and a program using both then has to convert between them at every
boundary. The usual fix is for one to depend on the other, which makes the
ecosystem a chain. The better fix is a tiny shared distribution that
neither owns: a role saying what a language tag must be able to do, which
both can compose without either depending on the other.

That is all this is. Forty-four lines, one role, four required methods and
one optional. It ships no tag class of its own and parses nothing.

## Composing it

```raku name="compose"
use Intl::LanguageTaggish;

class Tag does LanguageTaggish {
    has Str $.bcp47;
    method language { $!bcp47.split('-')[0] }
    method region   { $!bcp47.split('-')[1] // Str }
    multi method COERCE(LanguageTaggish:D $t --> Tag) { self.new: :bcp47($t.bcp47) }
    multi method COERCE(Str:D $s --> Tag)             { self.new: :bcp47($s) }
    method FALLBACK($name, |) { "<$name not modelled>" }
}

my $t = Tag.new(:bcp47('es-MX'));
say $t.language, ' ', $t.region, ' ', $t.bcp47;
say $t ~~ LanguageTaggish;
say $t.script;

my Tag() $coerced = 'pt-BR';
say $coerced.bcp47, ' ', $coerced.language;
```

```output
es MX es-MX
True
<script not modelled>
pt-BR pt
```

`language`, `region`, `bcp47` and `COERCE` are required; leave any of them
out and the class will not compile. `FALLBACK` is optional and is the
interesting one: it lets a tag type answer questions about subtags it does
not model, rather than failing, which is how a minimal implementation can
still be handed to a library expecting a richer one.

The `Tag()` coercion on the last two lines is what `COERCE` buys — any
routine declaring a `Tag()` parameter now accepts a plain string.

## The one thing to know

`use Intl::LanguageTaggish;` does not give you a type called
`Intl::LanguageTaggish`. It imports exactly one name, the short
`LanguageTaggish`, and that name is a role rather than something you can
instantiate:

```raku name="not-a-type"
use Intl::LanguageTaggish;

say LanguageTaggish.HOW.^name.subst(/^.*'::'/, '');
say LanguageTaggish.^name;
say (try LanguageTaggish.new('en-US')) // 'new: refused';
say (try LanguageTaggish('en-US')) // 'coercion: refused';
```

```output
ParametricRoleGroupHOW
LanguageTaggish
new: refused
coercion: refused
```

So there is no tag in this distribution and nothing here parses `'es-MX'`.
The `language` and `region` methods in the first example are three lines I
wrote, not the module's. If you want a working language tag, the
`Intl::LanguageTag` family is what composes this role; this distribution is
for the author of such a family, or for a library that wants to accept any
of them.

One thing to watch when writing your own: the required `COERCE` must be
declared `multi` with the role's exact signature. The natural-looking
`method COERCE(Str $s)` compiles under Raku++ and is a hard compile error
under Rakudo, so a class written and tested only on Raku++ will not build
for Rakudo users.
