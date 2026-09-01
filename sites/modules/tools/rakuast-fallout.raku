#!/usr/bin/env rakupp
# rakuast-fallout.raku — which distributions are about to be decided by the
# RakuAST frontend rather than by Raku++, and in which direction.
#
#   rakupp tools/rakuast-fallout.raku --index=$HOME/.raku/rakupp-install/rea-meta.json \
#          [--sweep=src/data/ecosweep.tsv] --out=src/data/rakuast-fallout.tsv
#   rakupp tools/rakuast-fallout.raku --index=… --annotate=src/data/ecosweep.tsv
#
# Rakudo 2026.09 makes RakuAST the default frontend; the legacy one goes behind
# RAKUDO_LEGACY=1 and is removed at 6.e (dev.to/lizmat/mainstreaming-rakuast-49j8).
# That splits the failing half of the ecosystem sweep in two, and the halves
# want opposite treatment:
#
#   legacy     the dist rides the frontend that is being deleted — an old slang
#              hook, QAST, `macro`, P5tie. It stops working on stock Rakudo too,
#              whatever we do, so it is never engine work and never charged to
#              the engine. (P5tie PASSES under rakupp today and is still in here:
#              this is not a verdict, and a green dist can carry it.)
#   needs-AST  the dist uses the RakuAST API. It is blocked on us — on
#              rakupp's RAKUAST-PLAN — and not on ordinary parser work.
#
# Hence a FLAG, not a seventh verdict: verdicts are the ladder of the first rung
# that failed and are mutually exclusive, while this axis is orthogonal to them.
# The flag is column 9 of ecosweep.tsv and a badge on /modules/ecosystem/.
#
# Three kinds of evidence, in this order of authority:
#
#   1. the sweep's own first error   — `No such method 'AST'`, `Could not find
#      QAST`, `refine_slang`. Measured, so it keeps working for sweeps run
#      after this file was written.
#   2. the REA index                 — a name in the `Slang::` family, or a
#      `depends` entry naming one. Cheap and needs no sources.
#   3. %SOURCE-VERIFIED below        — the handful the first two cannot see,
#      each with the file:line that was read to establish it. Anything added
#      here carries its evidence or does not go in.

# Evidence the index and the error column cannot reach: what is INSIDE a
# distribution. Every row was read from the dist's own tarball.
my %SOURCE-VERIFIED =
    # lib/Text/CSV.rakumod:3 and lib/Text/IO/String.rakumod:1 are
    # `use Slang::Tuxic` — the LIBRARY, not just the 33 test files, so every
    # runtime dependent rides the slang too.
    'Text::CSV'          => 'legacy: lib/Text/CSV.rakumod:3 uses Slang::Tuxic (which is already on Slangify)',
    # Named in the announcement as disabled upstream.
    'P5tie'              => 'legacy: disabled upstream at 2026.09',
    # Its first error is `Cannot add tokens` in ASTQuery::Actions, which
    # fingerprints as neither; lib/ASTQuery/Match.rakumod:36 is
    # `method of {RakuAST::Node}` and lib/ASTQuery.rakumod:50 dispatches on
    # `RakuAST::Call` — the whole dist is a RakuAST query language.
    'ASTQuery'           => 'needs-AST: lib/ASTQuery/Match.rakumod:36 types on RakuAST::Node',
    ;

# `Slang` in the name is the family; Slangify is the opposite — it is the
# ACTIVATION interface the announcement points authors at, so it stays clean.
my $SLANG-NAME = / ^ 'Slang' ['::' | ':'] /;
sub slangish(Str $n --> Bool) {
    return False if $n eq 'Slangify' || $n.starts-with('Slangify::');
    so $n ~~ $SLANG-NAME
}

sub field(Str $line, Str $key --> Str) {
    $line ~~ / '"' $key '":"' (<-["]>+) '"' / ?? ~$0 !! ''
}

# A `depends` entry names a MODULE and may carry version/auth adverbs; the name
# is everything before the first adverb.
sub dep-name(Str $s --> Str) {
    $s ~~ / ^ (<-[:]>+ [ '::' <-[:]>+ ]*) / ?? ~$0 !! $s
}

# depends/build-depends/test-depends, in any of the four shapes the ecosystem
# writes them: a list of strings, a list of hashes with <name>, a phase hash,
# or absent.
sub names-of($v, @out) {
    return unless $v.defined;
    if $v ~~ Positional {
        names-of($_, @out) for @$v;
    }
    elsif $v ~~ Associative {
        if $v<name>.defined {
            @out.push(~$v<name>);
        }
        else {
            # {runtime => {requires => [...]}} is the deepest shape in the
            # index — Slang::Tuxic writes its Slangify dependency that way,
            # and a walker that stops at the phase key never sees it.
            names-of($v{$_}, @out) for <runtime build test requires>;
        }
    }
    elsif $v ~~ Str {
        @out.push($v);
    }
}

my $have-own-json = ?(try { ::('Rakupp::Internals::JSON').from-json('1') === 1 });
sub json-decode(Str $text) {
    $have-own-json
        ?? ::('Rakupp::Internals::JSON').from-json($text)
        !! Rakudo::Internals::JSON.from-json($text)
}

# name -> [flag, reason]; `legacy` wins over `needs-AST` (a dist that dies with
# the frontend is not waiting on our RakuAST work — it is not waiting at all).
sub decide(%flags, Str $name, Str $flag, Str $why) {
    my $have = %flags{$name};
    return if $have && $have[0] eq 'legacy';
    %flags{$name} = [$flag, $why];
}

sub MAIN(Str :$index!, Str :$sweep = '', Str :$out = '', Str :$annotate = '') {
    die "give --out or --annotate" unless $out || $annotate;

    # ---- pass 1: the latest line of each dist, kept as text -----------------
    my %latest;
    for $index.IO.lines -> $line {
        next unless $line.starts-with('{');
        my $date = field($line, 'release-date');
        my $dist = field($line, 'dist');
        my $name = $dist ~~ / ^ (.+?) ':ver<' / ?? ~$0 !! field($line, 'name');
        next unless $name && $date;
        my $have = %latest{$name};
        %latest{$name} = { :$date, :$line } if !$have.defined || $date gt $have<date>;
    }
    note "{%latest.elems} dists at latest version";

    my %flags;

    # ---- evidence 2: the index ---------------------------------------------
    for %latest.kv -> $name, %e {
        my %m = try json-decode(%e<line>.trim.subst(/ ',' $ /, ''));
        next unless %m;

        if slangish($name) {
            # A slang that already names Slangify has begun the migration the
            # announcement asks for. It is still `legacy` — Slangify eases
            # ACTIVATION, it does not find the new hooks for you — but the
            # reason says so, because the flag then means "upstream's move to
            # finish", not "abandoned".
            my @d;
            names-of(%m{$_}, @d) for <depends build-depends test-depends>;
            my $migrating = so @d.map(&dep-name).grep(* eq 'Slangify');
            decide(%flags, $name, 'legacy', $migrating
                ?? 'legacy: a Slang:: dist, already on Slangify — hooks still move at 6.e'
                !! 'legacy: a Slang:: dist — the old grammar hooks go at 6.e');
            next;
        }
        # A dist can ship a slang under another name (`T` is "library and
        # slang"); what it PROVIDES gives it away.
        with %m<provides> {
            my @s = .keys.grep(&slangish).sort;
            if @s {
                decide(%flags, $name, 'legacy', "legacy: provides {@s.join(', ')}");
                next;
            }
        }

        my @deps;
        names-of(%m{$_}, @deps) for <depends build-depends test-depends>;
        @deps = @deps.map(&dep-name).grep(*.chars).unique;

        my @slangs = @deps.grep(&slangish).sort;
        if @slangs {
            decide(%flags, $name, 'legacy', "legacy: depends on {@slangs.join(', ')}");
            next;
        }
        my @asts = @deps.grep({ .lc.starts-with('rakuast') || $_ eq 'ASTQuery' }).sort;
        decide(%flags, $name, 'needs-AST', "needs-AST: depends on {@asts.join(', ')}") if @asts;
        decide(%flags, $name, 'needs-AST', 'needs-AST: the RakuAST API by name')
            if $name.lc.starts-with('rakuast');
    }

    # ---- evidence 1: the sweep's own first error ---------------------------
    # Last, so a measured failure overrides a guess from the index — and so a
    # dist the index cannot fingerprint still lands correctly.
    if $sweep && $sweep.IO.e {
        for $sweep.IO.lines.skip(1) -> $line {
            my @c = $line.split("\t");
            next unless @c.elems >= 8 && @c[0];
            my ($name, $err) = @c[0], @c[7];
            next unless $err;
            if $err.contains('Could not find QAST') {
                decide(%flags, $name, 'legacy', 'legacy: reaches QAST, the frontend being deleted');
            }
            elsif $err.contains('refine_slang') || $err.contains('slang_grammar') {
                decide(%flags, $name, 'legacy', 'legacy: calls a slang hook of the old grammar');
            }
            elsif $err.contains(q{No such method 'AST'}) {
                decide(%flags, $name, 'needs-AST', 'needs-AST: calls .AST on a Str');
            }
            elsif $err.contains('RakuAST::') {
                decide(%flags, $name, 'needs-AST', 'needs-AST: names a RakuAST:: class');
            }
        }
    }

    # ---- evidence 3: read from the sources ---------------------------------
    for %SOURCE-VERIFIED.kv -> $name, $why {
        %flags{$name} = [$why.substr(0, $why.index(':')), $why];
    }

    my @names = %flags.keys.sort(*.lc);
    my %tally;
    %tally{%flags{$_}[0]}++ for @names;

    if $out {
        my $fh = open($out, :w);
        $fh.say("name\tflag\treason");
        $fh.say("$_\t{%flags{$_}[0]}\t{%flags{$_}[1]}") for @names;
        $fh.close;
        say "wrote $out — {+@names} flagged dists";
    }

    if $annotate {
        # Add or refresh column 9 of an ecosweep.tsv that distill already
        # wrote, so today's committed data gains the flag without re-running
        # the whole distillation (whose blocker reconstruction needs the sweep
        # LOGS, which do not travel with the TSVs).
        my @lines = $annotate.IO.lines;
        my @head  = @lines[0].split("\t");
        my $keep  = @head[* - 1] eq 'rakuast' ?? @head.elems - 1 !! @head.elems;
        my $fh = open($annotate, :w);
        $fh.say((|@head[^$keep], 'rakuast').join("\t"));
        for @lines.skip(1) -> $line {
            my @c = $line.split("\t");
            @c.push('') while @c.elems < $keep;
            $fh.say((|@c[^$keep], (%flags{@c[0]} ?? %flags{@c[0]}[0] !! '')).join("\t"));
        }
        $fh.close;
        say "annotated $annotate — {+@lines - 1} rows, {+@names} flagged";
    }

    say "  {%tally{$_}} $_" for %tally.keys.sort({ -%tally{$_} });
}
