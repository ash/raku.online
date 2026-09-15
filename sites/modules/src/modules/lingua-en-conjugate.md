---
name: Lingua::EN::Conjugate
version: 0.3
auth: zef:raku-community-modules
kind: Distribution · linguistics
summary: English verb phrases from a bare verb and a pronoun — tense, modal,
  aspect, voice, negation and question order, as an ordered list of words.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Lingua::EN::Conjugate
source: https://github.com/raku-community-modules/Lingua-EN-Conjugate.git
---

## What it is for

Generating English rather than parsing it: a template engine that needs
"he goes" from `go`, a grammar drill, a text adventure that conjugates the
verb the player typed. You hand it a bare verb and a pronoun subject; it hands
back the words of the phrase, in order, as an `Array`.

## Conjugating

```raku name="basics"
use Lingua::EN::Conjugate;

sub phrase(*%a) { conjugate(|%a).join(' ') }

say phrase(:bare<run>,  :subject<I>);
say phrase(:bare<run>,  :subject<he>);
say phrase(:bare<run>,  :subject<he>, :tense<sp>);
say phrase(:bare<go>,   :subject<she>, :tense<sp>, :forms['HaveEn']);
say phrase(:bare<eat>,  :subject<they>, :mod<will>, :forms['HaveEn', 'BeIng']);
say phrase(:bare<see>,  :subject<you>,  :tense<sp>, :forms['BeEn']);
say phrase(:bare<be>,   :subject<I>);
say phrase(:bare<have>, :subject<he>);
```

```output
I run
he runs
he ran
she had gone
they will have been eating
you were seen
I am
he has
```

Negation, contraction and question order:

```raku name="negation"
use Lingua::EN::Conjugate;

sub phrase(*%a) { conjugate(|%a).join(' ') }

say 'negated        : ', phrase(:bare<run>, :subject<he>, :negation);
say 'contracted     : ', phrase(:bare<run>, :subject<he>, :negation, :shortneg);
say 'question       : ', phrase(:bare<run>, :subject<he>, :interrogative);
say 'both, short    : ', phrase(:bare<go>, :subject<you>, :negation, :shortneg, :interrogative);
say 'both, long     : ', phrase(:bare<go>, :subject<you>, :negation, :interrogative);
say '';
say 'the last line is ungrammatical — without :shortneg the question';
say 'word order is wrong. Use :shortneg with :interrogative.';
```

```output
negated        : he does not run
contracted     : he doesn't run
question       : does he run
both, short    : don't you go
both, long     : do not you go

the last line is ungrammatical — without :shortneg the question
word order is wrong. Use :shortneg with :interrogative.
```

## The guard you will hit first

The method's first statement returns `[$bare]` unless the subject is one of
`I you he she it we they` **and** the tense is `p` or `sp`. Everything else is
silently a no-op:

```raku name="guard"
use Lingua::EN::Conjugate;

for <p sp i bi ing pp> -> $t {
    say sprintf('  tense=%-4s -> %s', $t,
                conjugate(:bare<go>, :subject<he>, :tense($t)).join(' '));
}
say '';
say '  subject=Bob -> ', conjugate(:bare<go>, :subject<Bob>).join(' ');
say '';
say 'so :tense<ing>, :tense<pp> and any non-pronoun subject give you the';
say 'bare verb back, with no error. Use :alias for a name — but note that';
say 'AGREEMENT still follows :subject:';
say '  he  + alias Bob -> ', conjugate(:bare<run>, :subject<he>,   :alias<Bob>).join(' ');
say '  they+ alias Bob -> ', conjugate(:bare<run>, :subject<they>, :alias<Bob>).join(' ');
```

```output
  tense=p    -> he goes
  tense=sp   -> he went
  tense=i    -> go
  tense=bi   -> go
  tense=ing  -> go
  tense=pp   -> go

  subject=Bob -> go

so :tense<ing>, :tense<pp> and any non-pronoun subject give you the
bare verb back, with no error. Use :alias for a name — but note that
AGREEMENT still follows :subject:
  he  + alias Bob -> Bob runs
  they+ alias Bob -> Bob run
```

## The one thing to know

The consonant-doubling rule needs four letters, so **every three-letter CVC
verb is mis-inflected** — and four-letter ones are fine, which is exactly why
the obvious test cases pass.

```raku name="doubling"
use Lingua::EN::Conjugate;

say 'progressive (should double the final consonant):';
for <run sit get put stop plan begin travel> -> $v {
    say sprintf('  %-8s -> %s', $v,
                conjugate(:bare($v), :subject<I>, :forms['BeIng']).join(' '));
}
say '';
say 'simple past, same rule:';
for <hug plan offer visit open benefit> -> $v {
    say sprintf('  %-8s -> %s', $v,
                conjugate(:bare($v), :subject<he>, :tense<sp>).join(' '));
}
say '';
say 'the rule is / (.+ <consonant> <stressedw>) (<consonant>) $$/ — the `.+`';
say 'demands a character BEFORE the C-V-C, so the shortest verb it can fire';
say 'on is four letters. It is stress-blind in the other direction too,';
say 'which is where offerred, visitted and openned come from.';
```

```output
progressive (should double the final consonant):
  run      -> I am runing
  sit      -> I am siting
  get      -> I am geting
  put      -> I am puting
  stop     -> I am stopping
  plan     -> I am planning
  begin    -> I am beginning
  travel   -> I am travelling

simple past, same rule:
  hug      -> he huged
  plan     -> he planned
  offer    -> he offerred
  visit    -> he visitted
  open     -> he openned
  benefit  -> he benefitted

the rule is / (.+ <consonant> <stressedw>) (<consonant>) $$/ — the `.+`
demands a character BEFORE the C-V-C, so the shortest verb it can fire
on is four letters. It is stress-blind in the other direction too,
which is where offerred, visitted and openned come from.
```

The irregular table has its own errors, and the flagship is the past
participle of *know*:

```raku name="irregulars"
use Lingua::EN::Conjugate;

for <know stride leap bear get dive burn> -> $v {
    say sprintf('  %-8s sp: %-14s pp: %s', $v,
        conjugate(:bare($v), :subject<he>, :tense<sp>).join(' '),
        conjugate(:bare($v), :subject<he>, :tense<sp>, :forms['HaveEn']).join(' '));
}
say '';
say 'know -> "had know": the participle field is missing its n.';
say 'the table also mixes dialects without saying so — gotten and dove are';
say 'American, burnt and travelling British.';
```

```output
  know     sp: he knew        pp: he had know
  stride   sp: he strod       pp: he had stridden
  leap     sp: he lept        pp: he had lept
  bear     sp: he bore        pp: he had born
  get      sp: he got         pp: he had gotten
  dive     sp: he dove        pp: he had dived
  burn     sp: he burnt       pp: he had burnt

know -> "had know": the participle field is missing its n.
the table also mixes dialects without saying so — gotten and dove are
American, burnt and travelling British.
```

## Where the two engines differ

One parse-level gap, and it lands squarely on this module's API: Raku++
cannot parse `mod=>` with no space before the fat arrow, and `mod` is the name
of one of the named parameters.

```raku name="mod"
use Lingua::EN::Conjugate;

# the portable spellings
say 'with :mod<will>   : ', conjugate(:bare<go>, :subject<she>, :mod<will>).join(' ');
say 'with mod => "may" : ', conjugate(:bare<go>, :subject<she>, mod => 'may').join(' ');
say '';
say 'the tight `mod=>"will"` does not parse under Raku++ — `mod`, `div`,';
say '`gcd` and `lcm` are read as operators in term position there. Put a';
say 'space in, or use the colonpair form.';
say '';
say 'an unknown modal is silent on both engines:';
say '  :mod<must> -> ', conjugate(:bare<go>, :subject<she>, :mod<must>).raku;
say '  an Any is pushed into the word list.';
```

```output
with :mod<will>   : she will go
with mod => "may" : she may go

the tight `mod=>"will"` does not parse under Raku++ — `mod`, `div`,
`gcd` and `lcm` are read as operators in term position there. Put a
space in, or use the colonpair form.

an unknown modal is silent on both engines:
  :mod<must> -> ["she", Any, "go"]
  an Any is pushed into the word list.
```

The other divergence is scoping: the file-scope `sub is-erregular` (spelled
with two r's) carries no `is export`, so it is a compile error under Rakudo
and callable under Raku++, where a module's unexported subs leak into the
using scope. Reach it as the method `.is-erregular` on `englishverb`, which is
portable — and remember it is a lookup in the irregular table, not a
linguistic judgement.
