---
name: Getopt::Long
version: 0.4.2
auth: cpan:LEONT
kind: Distribution · command line
summary: Command-line parsing in the GNU style — long and short options,
  negatable flags, typed values, repeats — declared either as patterns in
  the Perl tradition or by the signature of the sub you want called.
status: divergent
suite: 1 file, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/cpan:LEONT/Getopt::Long
source: https://github.com/Leont/getopt-long6
---

## What it is for

Raku hands a `sub MAIN` its options for free, in Raku's own dialect:
`--name=Ada` works and `--name Ada` does not, `-vx` is not two flags, and
`--no-colour` is not the opposite of `--colour`. Users who arrive from every
other command-line tool expect those, and this distribution parses them —
the conventions of GNU getopt and of Perl's `Getopt::Long`, whose pattern
language it keeps.

There are two ways in. `get-options-from` takes an argument list and the
patterns (`name=s` a string, `count=i` an integer, `verbose|v!` a flag with a
short alias and a `--no-` form, `tag=s@` a string that may repeat) and
answers with what it found. `call-with-getopt` takes a sub and derives the
patterns from its signature, then calls it — the shape `MAIN` has, with
GNU's rules.

## Patterns, and a signature

```raku name="patterns"
use Getopt::Long;

my @args = <--name=Ada -v --count 3 file.txt --tag a --tag b>;
my $opts = get-options-from(@args, 'name=s', 'verbose|v!', 'count=i', 'tag=s@');
say $opts.hash.sort.map({ .key ~ '=' ~ .value.join(',') }).join(' ');
say $opts.list;
```

```output
count=3 name=Ada tag=a,b verbose=True
(file.txt)
```

What comes back is a `Capture`: the options in `.hash`, the arguments that
were not options in `.list`, in the order they appeared. `--count 3` with a
space and `--name=Ada` with an equals both land, `-v` is `verbose`, and the
repeated `--tag` is collected into an array because the pattern said `@`.

The signature form reads the same conventions off a sub's named parameters
— a `Bool` becomes a flag, an `Int` a number that must parse, a default the
value when the option is absent — and the positionals go to the slurpy:

```raku name="signature"
use Getopt::Long;

sub main(Str :$name = 'nobody', Bool :$verbose, Int :$count = 1, *@files) {
    say "name=$name verbose={$verbose // 'no'} count=$count files={@files.join(',')}";
}

call-with-getopt(&main, <--name Ada --verbose --count=2 a.txt b.txt>);
call-with-getopt(&main, ["--count=7"]);
say (try { call-with-getopt(&main, ["--nope"]); 'ran' }) // $!.message;
```

```output
name=Ada verbose=True count=2 files=a.txt,b.txt
name=nobody verbose=no count=7 files=
Unknown option --nope
```

An option the signature does not mention throws `Getopt::Long::Exception`
with a one-line message, which is the thing to catch and turn into a usage
line — `generate-usage(&main)` writes one from the same signature.

## The one thing to know

`get-options-from` returns a Capture, not a Hash, and assigning it to a hash
is the mistake that looks fine until the first positional argument. With
`file.txt` on the command line the Capture has a positional element, and
`my %opts = get-options-from(…)` dies under Rakudo with *Odd number of
elements found where hash initializer expected*. Bind it to a scalar, as the
example does, and read `.hash` and `.list` — or use the signature form, where
the question does not arise.

## Where the two engines differ

A value that fails to convert — `--count x` for an `Int` option — is reported
differently. Under Rakudo the module catches the failed conversion and throws
its own `Getopt::Long::Exception`, *Cannot convert --count argument "x" to
number*. Under Raku++ the conversion's `Failure` reaches the module's typed
store first and surfaces as the underlying `X::Str::Numeric`, *Cannot convert
string to number*. Same cause, same line, different exception class: a
program that catches `Getopt::Long::Exception` to print usage will, on
Raku++, let this one case through. Catch `X::Str::Numeric` beside it, or
match on `Exception` and print the message, until the engine closes the gap.
