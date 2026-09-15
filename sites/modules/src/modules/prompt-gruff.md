---
name: Prompt::Gruff
version: 0.0.1
auth: github:adaptiveoptics
kind: Distribution · command line
summary: Ask a question and get an answer — with re-prompting, verification
  and a regex constraint, and a built-in harness so you can test it.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:adaptiveoptics/Prompt::Gruff
source: git://github.com/adaptiveoptics/P6-Prompt-Gruff.git
---

## What it is for

Core `prompt` asks once and accepts whatever comes back, including nothing.
An installer or a CLI usually wants more: re-ask until the answer is
non-empty, ask twice for a passphrase, constrain the answer to a pattern,
offer a default, or take a yes/no.

## Driving it without a terminal

Every example here uses the module's own test harness, which swaps the
prompter for one that reads from an array — because that is the only safe way
to exercise it, and because the harness is a documented part of the API.

```raku name="basics"
use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['Ada'];
say 'answer  : ', $p.prompt-for('Name: ').raku;
say 'prompts : ', $p._test-output.List.raku;
say '';
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['blue'];
say 'with a default:';
say '  answer  : ', $p.prompt-for('Colour: ', default => 'blue').raku;
say '  prompts : ', $p._test-output.List.raku;
say '  (the default is shown in the prompt)';
```

```output
answer  : "Ada"
prompts : ("Name: ",)

with a default:
  answer  : "blue"
  prompts : ("Colour: [blue] ",)
  (the default is shown in the prompt)
```

```raku name="verify"
use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['secret', 'secret', 'secret'];
say 'with :verify(3):';
say '  answer  : ', $p.prompt-for('Passphrase: ', verify => 3).raku;
say '  prompts : ', $p._test-output.List.raku;
say '';
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['99'];
say 'with a :regex constraint:';
say '  digits  : ', $p.prompt-for('Port: ', regex => '^\d+$').raku;
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['abc'];
say '  letters : ', $p.prompt-for('Port: ', regex => '^\d+$', no-escape => False).raku;
say '  output  : ', $p._test-output.List.raku;
```

```output
with :verify(3):
  answer  : "secret"
  prompts : ("Passphrase: ", "(verify) Passphrase: ", "(verify) Passphrase: ")

with a :regex constraint:
  digits  : "99"
  letters : Bool::False
  output  : ("Port: ", "Input does not match valid pattern")
```

## The one thing to know

With the default `required => True`, end of input is an infinite loop: the
prompt is re-emitted forever.

```raku name="eof"
use Prompt::Gruff;

say 'the body is';
say '  while !($response = $prompter($!_prompt) || $!default) { }';
say '';
say 'at EOF core prompt returns Nil on every call, so nothing ever';
say 'becomes true. Fed /dev/null, a required prompt writes the prompt';
say 'string until you kill it — tens of megabytes in a few seconds.';
say '';
say ':required(False) returns the empty string cleanly instead:';
my $p = Prompt::Gruff.new(:testing);
$p._test-input = [];                # an exhausted input array stands in for EOF
say '  required => False -> ', $p.prompt-for('Name: ', required => False).raku;
say '';
say 'the multi-line path does the same thing, so guard both. If your';
say 'program can run non-interactively, check $*IN.t before you ask:';
say '  $*IN.t : ', $*IN.t;
say '  (and fall back to a default, an argument, or an exit)';
```

```output
the body is
  while !($response = $prompter($!_prompt) || $!default) { }

at EOF core prompt returns Nil on every call, so nothing ever
becomes true. Fed /dev/null, a required prompt writes the prompt
string until you kill it — tens of megabytes in a few seconds.

:required(False) returns the empty string cleanly instead:
  required => False -> ""

the multi-line path does the same thing, so guard both. If your
program can run non-interactively, check $*IN.t before you ask:
  $*IN.t : False
  (and fall back to a default, an argument, or an exit)
```

## Every option resets the object

```raku name="options"
use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing, verify => 3, default => 'blue', required => False);
say 'attributes before : verify=', $p.verify, ' default=', $p.default.raku,
    ' required=', $p.required;
$p._test-input = ['first'];
say 'answer            : ', $p.prompt-for('Colour: ').raku;
say 'prompts           : ', $p._test-output.elems, ' — not 3';
say 'attributes after  : verify=', $p.verify, ' default=', $p.default.raku,
    ' required=', $p.required;
say '';
say 'every named option is bound straight to an attribute WITH A DEFAULT,';
say 'so omitting one silently resets it. Setting attributes on the object';
say 'and then calling prompt-for($prompt) throws those settings away.';
say '';
say 'pass everything at the call site, every time.';
say '';
say 'verify is destructive too — it counts down to 0 on the object and';
say 'stays there, so a second call asks once.';
```

```output
attributes before : verify=3 default="blue" required=False
answer            : "first"
prompts           : 1 — not 3
attributes after  : verify=0 default="" required=True

every named option is bound straight to an attribute WITH A DEFAULT,
so omitting one silently resets it. Setting attributes on the object
and then calling prompt-for($prompt) throws those settings away.

pass everything at the call site, every time.

verify is destructive too — it counts down to 0 on the object and
stays there, so a second call asks once.
```

## `:yn` accepts more than y and n

```raku name="yn"
use Prompt::Gruff;

for <y n yes no nay nope maybe xyzzy> -> $answer {
    my $p = Prompt::Gruff.new(:testing);
    $p._test-input = [$answer];
    my $r = $p.prompt-for('Continue? ', yn => True, no-escape => False);
    say sprintf('  %-8s -> %s', $answer.raku, $r.raku);
}
say '';
say 'the generated regex is `:i y || n`, matched ANYWHERE in the answer,';
say 'and the verdict is then `$response ~~ /:i y/`.';
say '';
say 'so "nay", "maybe" and even "xyzzy" are read as YES, while an answer';
say 'with neither letter in it — "sure" — is rejected as invalid and';
say 'RE-ASKED, which on an exhausted input is an infinite loop.';
say '';
say 'constrain it yourself instead:';
my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['y'];
say '  with :regex -> ', $p.prompt-for('Continue? ', regex => '^<[yYnN]>$').raku;
```

```output
  "y"      -> Bool::True
  "n"      -> Bool::False
  "yes"    -> Bool::True
  "no"     -> Bool::False
  "nay"    -> Bool::True
  "nope"   -> Bool::False
  "maybe"  -> Bool::True
  "xyzzy"  -> Bool::True

the generated regex is `:i y || n`, matched ANYWHERE in the answer,
and the verdict is then `$response ~~ /:i y/`.

so "nay", "maybe" and even "xyzzy" are read as YES, while an answer
with neither letter in it — "sure" — is rejected as invalid and
RE-ASKED, which on an exhausted input is an infinite loop.

constrain it yourself instead:
  with :regex -> "y"
```

## Where the two engines differ

Nothing behavioural — the harness, the options, the `:yn` table and the EOF
loop are identical. Only the `.raku` rendering of the typed `@._test-output`
array differs between the engines, which is why the examples above print
`.elems` or compare rather than dumping it raw in the later sections.

```raku name="portable"
use Prompt::Gruff;

say 'the functional interface is in a SEPARATE unit:';
say '  use Prompt::Gruff::Export;   # gives you prompt-for($prompt, |%opts)';
say '';
say 'and one more thing to plan around on both engines: :no-escape';
say 'defaults to True, which makes a regex failure or a verification';
say 'mismatch RECURSE into another prompt-for. With a non-interactive';
say 'stdin that is unbounded recursion on top of the unbounded loop.';
say '';
say 'the safe shape:';
sub ask(Str $prompt, *%opts) {
    return Nil unless $*IN.t;
    Prompt::Gruff.new.prompt-for($prompt, |%opts, no-escape => False)
}
say '  ask() returns Nil when stdin is not a terminal : ', ask('Name: ').raku;
```

```output
the functional interface is in a SEPARATE unit:
  use Prompt::Gruff::Export;   # gives you prompt-for($prompt, |%opts)

and one more thing to plan around on both engines: :no-escape
defaults to True, which makes a regex failure or a verification
mismatch RECURSE into another prompt-for. With a non-interactive
stdin that is unbounded recursion on top of the unbounded loop.

the safe shape:
  ask() returns Nil when stdin is not a terminal : Nil
```
