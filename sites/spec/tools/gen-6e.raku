#!/usr/bin/env raku
# gen-6e.raku — measure Raku++'s support for the 6.e language revision into
# src/data/6e.raku.
#
#   rakupp tools/gen-6e.raku [--rakupp=PATH] [--rakudo=PATH] [--out=PATH]
#
# Unlike gen-dashboard.raku, which only collects numbers other runs produced,
# this one *measures*: every feature below is a snippet that gets run three
# times — on Rakudo under 6.d, on Rakudo under 6.e, and on Raku++ under 6.e —
# and the three outputs go into the data file next to the snippet. The support
# verdict is then derived from those outputs by one rule (see verdict()), never
# asserted by hand, so re-running this after an engine change re-scores the
# whole page.
#
# The feature list itself is the hand-maintained part. It comes from rakudo's
# src/core.e, from every language_revision >= 3 gate in its grammars, actions and
# metamodel, from the `is revision-gated("6.e")` routines in src/core.c, and from
# roast's 6.e test files — the same reconstruction as the prose article at
# raku.online/6e (rakupp docs/guide/LANGUAGE-6E.md), which this page is the
# machine-checked companion to.

constant RAKUPP-DEFAULT = 'rakupp';
constant RAKUDO-DEFAULT = 'raku';

# id      — the anchor on the page, and the stable key for a feature
# title   — what the row is called
# code    — the snippet, run verbatim under 6.d and with the pragma prepended for 6.e
# note    — one line of context, shown under the title
# status  — optional manual verdict, overriding the derived one (with `why`)
# env     — extra environment for the *Rakudo* runs only (q:o needs its new frontend)
# lib     — files to write into a lib/ next to the snippet, passed with -I
my @GROUPS =
  {
    slug  => 'syntax',
    title => 'New syntax',
    intro => 'Spellings the 6.d grammar rejects outright.',
    items => (
      { id => 'prefix-defined', title => 'prefix //',
        note => 'Shorthand for .defined; in 6.d, // opens an empty regex.',
        code => 'say //42, " ", //Any;' },
      { id => 'nano', title => 'term nano',
        note => 'The POSIX time in nanoseconds, as an Int, next to time and now.',
        code => 'say nano ~~ Int;' },
      { id => 'format-literal', title => 'q:o / q:format literals',
        note => 'A compile-time sprintf template that is a callable Format object. Needs Rakudo\'s RakuAST frontend as well as 6.e.',
        env  => { RAKUDO_RAKUAST => '1' },
        code => 'my $f := q:o/%5s/; say $f.^name; say $f("foo");' },
      { id => 'rakuast', title => 'the RakuAST:: package',
        note => 'Available without a pragma from 6.e; under 6.d it needs use experimental :rakuast.',
        code => 'say RakuAST::IntLiteral.new(42).DEPARSE;' },
      { id => 'multislice-slip', title => 'slipped multislice @a[||@i]',
        note => 'A list of indices spliced into a multi-dimensional subscript.',
        code => 'my @a = [[1,2],[3,4]],; my @i = 0,1,0; say @a[||@i];' },
      { id => 'hyperslice', title => 'hash hyperslice %h{**}',
        note => 'Every leaf of a nested associative, at any depth.',
        code => 'my %h = A => { B => 1, C => 2 }, D => 3; say %h{**}:k.sort.join(",");' },
      { id => 'multislice-hash', title => 'hash multislice %h<a;b>',
        note => 'One value, not a one-element list as in 6.d.',
        code => 'my %h = A => { B => 42 }; say %h{\'A\';\'B\'};' },
      { id => "unit-sub", title => "unit sub foo;",
        note => "The semicolon form, for any sub rather than only MAIN — but it must be unit-scoped. Nothing prints: the rest of the file is the sub's body.",
        code => "unit sub foo;\nsay \"compiled\";" },
    ),
  },
  {
    slug  => 'routines',
    title => 'New subs, terms and operators',
    intro => 'Added to CORE by src/core.e/additions.rakumod.',
    items => (
      { id => 'rotor-sub', title => 'rotor as a sub',
        note => 'The cycle comes first, the list last.',
        code => 'say rotor(2, 1..6); say rotor(2, 1, 1..6);' },
      { id => 'snip-sub', title => 'snip as a sub',
        note => 'Split a list where a predicate stops holding.',
        code => 'say snip(* < 3, 1,2,3,4);' },
      { id => 'snitch-sub', title => 'snitch as a sub',
        note => 'Note a value in passing and return it unchanged — a print(1) that does not disturb the expression.',
        code => 'my $x = snitch("hi"); say $x;' },
      { id => 'trans-sub', title => 'trans as a sub',
        note => 'For use in feed operators.',
        code => 'say trans("a" => "b", "banana");' },
      { id => 'comb-sub-pair', title => 'comb with a Pair',
        note => 'size => step, the way rotor takes it.',
        code => 'say comb(2 => 1, "abcdef");' },
      { id => 'next-value', title => 'next with a value',
        note => 'The value becomes the result of that iteration.',
        code => 'say (1,2,3).map({ $_ == 2 ?? next(42) !! $_ }).List;' },
      { id => 'last-value', title => 'last with a value',
        note => 'Same, and it is the final element produced.',
        code => 'say (1,2,3).map({ $_ == 2 ?? last(99) !! $_ }).List;' },
    ),
  },
  {
    slug  => 'methods',
    title => 'New methods',
    intro => 'Augmented onto existing core classes by src/core.e/Fixups.rakumod.',
    items => (
      { id => 'snip', title => '.snip',
        note => 'On Any and on Supply.',
        code => 'say (1,2,3,4,5).snip(* < 3);' },
      { id => 'snitch', title => '.snitch',
        note => 'Notes to $*ERR by default; takes a snitcher of your own.',
        code => 'my $x = (1,2).snitch; say $x.List;' },
      { id => 'skip-list', title => '.skip with a list',
        note => 'Alternates produce N, skip N — .skip(2,3) keeps the first two and drops the next three.',
        code => 'say (1..10).skip(2,3).List;' },
      { id => 'nomark', title => '.nomark',
        note => 'The string with every mark stripped from its graphemes.',
        code => 'say "élan vitál".nomark;' },
      { id => 'stem', title => 'IO::Path.stem',
        note => 'The basename without extensions — all of them, or the last N.',
        code => 'say "foo.tar.gz".IO.stem, " ", "foo.tar.gz".IO.stem(1);' },
      { id => 'complex-sign', title => 'Complex.sign',
        note => 'v / |v| — the unit complex number. In 6.d, .sign throws on a non-real.',
        code => 'say (3+4i).sign;' },
      { id => "int-pick", title => "Int.roll / Int.pick",
        note => "42.pick(3) is short for (^42).pick(3).",
        status => "partial", why => Q[Int.roll is there; Int.pick($n) returns a single value instead of $n of them.],
        code => Q[say 6.roll ~~ Int, " ", 6.pick(3).elems;] },
      { id => 'mu-callable', title => 'Mu.Callable($name)',
        note => 'The method of that name, or a Failure — a findable method reference.',
        code => 'say 42.Callable("Str") ~~ Method;' },
      { id => 'comb-pair', title => 'Str.comb with a Pair',
        note => 'The method form of the same size => step combing.',
        code => 'say "abcdef".comb(2 => 1);' },
      { id => 'smartcase', title => ':smartcase on the Str searches',
        note => 'Case-insensitive unless the needle itself has a capital. On contains, starts-with, ends-with, index, indices, rindex, substr-eq.',
        code => 'say "Hello World".contains("world", :smartcase), " ", "Hello World".contains("World", :smartcase);' },
      { id => 'fmt-format', title => '.fmt with a Format',
        note => 'Added to Bag, BagHash, List, Map, Mix, MixHash, Pair, Seq, Set and SetHash.',
        env  => { RAKUDO_RAKUAST => '1' },
        code => 'say (1,2,3).fmt(q:o/%3d/);' },
      { id => 'date-tz', title => 'Date.DateTime(:timezone)',
        note => 'The named argument is honoured; in 6.d it is silently dropped.',
        code => 'say Date.new(2026,1,1).DateTime(:timezone(3600)).timezone;' },
      { id => 'instant-tz', title => 'Instant.DateTime(:timezone)',
        note => 'The same fix on Instant.',
        code => 'say Instant.from-posix(0).DateTime(:timezone(3600)).timezone;' },
    ),
  },
  {
    slug  => 'behaviour',
    title => 'Changed behaviour',
    intro => 'Same program, different answer. These are the ones to read before turning 6.e on for code that already works.',
    items => (
      { id => 'int-sqrt-neg', title => 'sqrt of a negative Int',
        note => 'A Complex rather than NaN.',
        code => 'say (-4).sqrt;' },
      { id => "num-sqrt-neg", title => "sqrt of a negative Num",
        note => "The same fix on the floating-point side.",
        code => Q[say (-4e0).sqrt;] },
      { id => "num-log-neg", title => "log of a negative Num",
        note => "The complex logarithm rather than NaN.",
        code => Q[say (-1e0).log;] },
      { id => 'range-bool', title => 'Range.Bool',
        note => 'Emptiness, not "has endpoints".',
        code => 'say so (5..1), " ", so ("b".."a");' },
      { id => 'str-range', title => 'string ranges iterate by .succ',
        note => '6.d walks a per-position cross product, which is why ("az".."bc") has 52 elements there.',
        code => 'say ("az".."bc").join(",");' },
      { id => 'sprintf-sign', title => 'sprintf: sign before the prefix',
        note => 'C puts the minus first for every base.',
        code => 'say sprintf("%#x", -256);' },
      { id => 'sprintf-flags-b', title => 'sprintf: + and space no longer apply to %b',
        note => 'A binary conversion has no sign to decorate.',
        code => 'say sprintf("[%+b][% b]", 5, 5);' },
      { id => 'sprintf-hash-f', title => 'sprintf: # on a float',
        note => 'Forces the decimal point, as in C.',
        code => 'say sprintf("[%#.0f]", 1);' },
      { id => 'sprintf-nan', title => 'sprintf: %G upper-cases NaN',
        note => 'And only %G — %g keeps the Raku spelling.',
        code => 'say sprintf("[%G][%g]", NaN, NaN);' },
      { id => 'role-submethod', title => 'a role\'s submethods are not composed',
        note => 'BUILD, TWEAK and DESTROY still run — 6.e adds them to the buildplan explicitly — but a role submethod is no longer callable as a method on the class.',
        code => 'role R { submethod s { 42 } }; class C does R { }; say C.new.s;' },
      { id => 'nested-package', title => 'a package no longer replaces its namesake',
        note => 'class A::B inside module A::B nests instead of silently overwriting the outer stash.',
        code => 'module A::B { class A::B { } }; say A::B::A::B.^name;' },
      { id => 'shaped-hash', title => 'shaped hashes default to Mu',
        note => 'The value type of my %h{Str} with no explicit type.',
        code => 'my %h{Str}; say %h<nope>.WHAT.^name;' },
      { id => 'placeholder-args', title => '@_ is per-block',
        note => 'Every block gets its own implicit *@_ instead of reaching for the enclosing routine\'s.',
        code => 'sub f(*@_) { my &c = { @_.elems }; say c(1,2,3) }; f(7,7,7,7);' },
      { id => 'pseudo-failure', title => 'pseudo-packages fail on a missing symbol',
        note => 'A Failure instead of Nil, so the mistake is not silent.',
        code => 'my $r = MY::<$nosuchvar>; say $r.^name;' },
      { id => 'lexical-dynamic', title => 'LEXICAL:: rejects a dynamic',
        note => 'A $*variable is not a lexical, and asking for one through LEXICAL:: now says so.',
        code => 'my $*dyn = 42; sub f { say LEXICAL::<$*dyn> }; f;' },
      { id => 'grammar-parse', title => 'Grammar.parse fails instead of returning Nil',
        note => '6.e gives grammars a new base class whose failed parse carries an X::Syntax::Confused with the position.',
        code => 'grammar G { token TOP { \d+ } }; my $r = G.parse("abc"); say $r.^name;' },
      { id => 'splice-item', title => 'splice can insert an itemized array whole',
        note => 'A $[…] argument goes in as one element rather than being flattened.',
        code => 'my @a = 1,2,3; @a.splice(1,1,$[8,9]); say @a.raku;' },
      { id => 'subset-ver', title => 'a subset records its language version',
        note => 'Even.^ver reports the revision it was declared under.',
        code => 'subset Even of Int where * %% 2; say Even.^ver;' },
    ),
  },
  {
    slug  => 'errors',
    title => 'New errors',
    intro => 'Accepted and ignored in 6.d; a compile-time error from 6.e.',
    items => (
      { id => 'regex-boundary', title => 'unknown regex boundary',
        note => 'Only <|w> and <|c> are boundaries; anything else was a silent no-op.',
        code => 'say so "abc" ~~ /<|f> abc/;' },
      { id => "macros", title => "experimental macros",
        note => "Not carried into 6.e.",
        why => "Both refuse the program, but Raku++ has no macros under any revision, so what it reports is a parse error rather than the 6.e diagnostic.",
        code => 'use experimental :macros; macro m() { quasi { 42 } }; say m();' },
      { id => 'sub-semicolon', title => 'sub foo; without unit',
        note => '6.d rejects the semicolon form for anything but MAIN; 6.e allows any sub, but demands unit scope.',
        code => "sub foo;\nsay \"compiled\";" },
    ),
  },
  {
    slug  => 'removals',
    title => 'Deprecations and removals',
    intro => 'The only things 6.e takes away.',
    items => (
      { id => 'pm-extension', title => '.pm is no longer a module extension',
        note => 'CompUnit::Repository::FileSystem looks for .rakumod and .pm6 only.',
        lib  => { 'OldMod.pm' => 'sub hi is export { say "from .pm" }' },
        code => 'use OldMod; hi;' },
      { id => 'unlink-single', title => 'single-path unlink / rmdir / chmod / chown',
        note => 'One path in, one Bool out; the multi-path forms still work but are deprecated.',
        code => 'say unlink("/tmp/no-such-file-abc123").raku;' },
    ),
  };

# ---- running ---------------------------------------------------------------

# One line, whitespace collapsed, capped. A compile error carries four lines of
# scaffolding — the file it was compiling, the line it was at, a list of things
# the parser expected — none of which says what went wrong; the message does.
sub tidy(Str $s, Str $scrub = "" --> Str) {
    my $text = $scrub ?? $s.subst($scrub, "", :g) !! $s;
    my $sorry = $text.contains("===SORRY!===");
    my @keep = $text.lines.grep({
        .trim ne ""
          && !.starts-with("===SORRY!=== Error while compiling")
          && !($sorry && .trim.starts-with("at "))
          && !($sorry && .trim eq "expecting any of:")
          && !($sorry && .starts-with("    "))
          # Rakudo's runtime backtrace frames ("  in block <unit> at …") name the
          # temporary file this tool wrote, which is noise in a table of outputs.
          && !(.trim ~~ / ^ "in " [ "block" | "sub" | "submethod" | "method" | "any" | "code" ] /)
    });
    my $t = @keep.head(2).join(" | ").subst(/ \s+ /, " ", :g).trim;
    $t.chars > 110 ?? $t.substr(0, 107) ~ "…" !! $t
}

# Returns the tidied output and whether the run failed — the exit code is the
# only engine-neutral way to ask "did this program run?".  Two engines rejecting
# the same program word it differently and always will; that they both reject it
# is the fact worth comparing.
sub run-one(Str $exe, Str $file, @inc, %env, Str $scrub --> List) {
    my %e = %*ENV;
    %e{$_} = %env{$_} for %env.keys;
    my @cmd = $exe, |@inc.map({ ("-I", $_) }).flat, $file;
    my $p = run(|@cmd, :out, :err, :env(%e));
    my $out = $p.out.slurp(:close);
    my $err = $p.err.slurp(:close);
    (tidy($out ~ "\n" ~ $err, $scrub), $p.exitcode != 0)
}

# The verdict rule, in one place.
#
#   full       Raku++ does what Rakudo does under 6.e: the same output, or —
#              for the features that are new *errors* — the same refusal.
#   ni         Raku++ says the thing does not exist, and 6.e says it does.
#   divergent  anything else: it runs, and answers something else.
#
# `partial` is only ever set by hand, because "there, but not all the way there"
# is a judgement no output comparison can make.
sub verdict(Str $e, Bool $e-failed, Str $pp, Bool $pp-failed --> Str) {
    return "full" if $e-failed && $pp-failed;          # both refuse the program
    return "full" if !$e-failed && !$pp-failed && $pp eq $e;
    if $pp-failed && !$e-failed {
        return "ni" if $pp ~~ / "No such method" | "Undefined routine"
                              | "Undeclared name" | "Unsupported" | "Could not find" /;
    }
    "divergent"
}

sub MAIN(Str :$rakupp = RAKUPP-DEFAULT, Str :$rakudo = RAKUDO-DEFAULT,
         Str :$out = 'src/data/6e.raku') {
    my $tmp = ($*TMPDIR // '/tmp'.IO).add("gen-6e-{$*PID}");
    mkdir $tmp;
    mkdir $tmp.add('lib');

    my @groups;
    my %counts = full => 0, partial => 0, divergent => 0, ni => 0;

    for @GROUPS -> %g {
        my @items;
        for @(%g<items>) -> %it {
            my @inc;
            if %it<lib> {
                for %it<lib>.kv -> $name, $content {
                    spurt $tmp.add('lib').add($name), $content ~ "\n";
                }
                @inc.push(~$tmp.add('lib'));
            }
            my $plain = $tmp.add('plain.raku');
            my $preview = $tmp.add('preview.raku');
            spurt $plain,   %it<code> ~ "\n";
            spurt $preview, "use v6.e.PREVIEW;\n" ~ %it<code> ~ "\n";

            my %env = %it<env> // {};
            my $scrub = ~$tmp ~ "/";
            my ($d,  $d-failed)  = run-one($rakudo, ~$plain,   @inc, %env, $scrub);
            my ($e,  $e-failed)  = run-one($rakudo, ~$preview, @inc, %env, $scrub);
            my ($pp, $pp-failed) = run-one($rakupp, ~$preview, @inc, {},   $scrub);

            my $status = %it<status> // verdict($e, $e-failed, $pp, $pp-failed);
            %counts{$status}++;
            @items.push({
                id => %it<id>, title => %it<title>, note => %it<note>,
                code => %it<code>, d => $d, e => $e, pp => $pp,
                changed => ($d ne $e || $d-failed != $e-failed) ?? 1 !! 0,
                status => $status, why => (%it<why> // ''),
                rakuast => (%it<env>:exists ?? 1 !! 0),
            });
            say "  {%it<id>}: $status";
        }
        @groups.push({ slug => %g<slug>, title => %g<title>, intro => %g<intro>, items => @items });
    }

    run('rm', '-rf', ~$tmp);

    my $rakudo-ver = tidy(run($rakudo, '-e', 'print $*RAKU.compiler.version', :out).out.slurp(:close));
    # rakupp reports Rakudo's version for $*RAKU.compiler.version (programs check it);
    # its own build string is what identifies the engine that produced these runs.
    my $rakupp-ver = tidy(run($rakupp, '--version', :out).out.slurp(:close).lines.grep({ .starts-with('Raku++') }).head // '');

    my @lines = '# Generated by tools/gen-6e.raku — do not edit.', '{';
    @lines.push("  'generated' => '{Date.today}',");
    @lines.push("  'rakudo' => '$rakudo-ver',");
    @lines.push("  'rakupp' => '$rakupp-ver',");
    @lines.push("  'counts' => \{ " ~ %counts.keys.sort.map({ "'$_' => {%counts{$_}}" }).join(', ') ~ " \},");
    @lines.push("  'groups' => [");
    for @groups -> %g {
        @lines.push("    \{");
        @lines.push("      'slug' => " ~ %g<slug>.raku ~ ",");
        @lines.push("      'title' => " ~ %g<title>.raku ~ ",");
        @lines.push("      'intro' => " ~ %g<intro>.raku ~ ",");
        @lines.push("      'items' => [");
        for @(%g<items>) -> %i {
            @lines.push("        \{ " ~ <id title note code d e pp changed status why rakuast>.map({
                "'$_' => " ~ %i{$_}.raku
            }).join(', ') ~ " \},");
        }
        @lines.push("      ],");
        @lines.push("    \},");
    }
    @lines.push("  ],");
    @lines.push('}');
    spurt $out, @lines.join("\n") ~ "\n";

    my $total = %counts.values.sum;
    say "6.e support: {%counts<full>}/$total full, {%counts<partial>} partial, " ~
        "{%counts<divergent>} divergent, {%counts<ni>} not implemented -> $out";
}
