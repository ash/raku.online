#!/usr/bin/env rakupp
# ---------------------------------------------------------------------------
# tools/inspect.raku — what a module ACTUALLY offers, as facts.
#
#   rakupp tools/inspect.raku <Dist::Name> [--install] [--suite] [--deep]
#
# A page on this site is an independent review, so it may not be written from
# anybody else's prose. This tool exists to make that practical: it reports a
# module's real API surface — exported subs with their signatures, the types it
# defines, their methods and attributes — read out of the INSTALLED code by
# introspection, plus the facts the distribution states about itself in its
# META6.json.
#
# It deliberately does NOT print README text, POD prose or example code from
# the distribution. Those are the author's words; the facts below are not.
# Write the page from these, and from examples spiked in a scratchpad.
#
# Each unit is introspected in its OWN child process, with a literal `use`.
# Two reasons: `require ::($name)` fails for a fair number of installed dists
# on BOTH engines where `use` succeeds, and a unit whose load-time code dies or
# hangs then takes down only its own probe rather than the whole run.
# ---------------------------------------------------------------------------
use JSON::Fast;

constant STORE = $*HOME.add('.raku');

#| The store can hold several versions of one distribution at once — installing
#| an upgrade does not evict what was there. Take the HIGHEST, which is the one
#| `use` will resolve to and so the one a page should describe.
sub find-dist(Str $name) {
    my $dir = STORE.add('dist');
    return Nil unless $dir.d;
    my @found;
    for $dir.dir -> $f {
        next unless $f.f;
        my $text = (try slurp($f)) // next;
        # a cheap substring test before paying for a JSON parse of every dist
        next unless $text.contains('"name":"' ~ $name ~ '"');
        my $meta = (try from-json($text)) // next;
        @found.push($meta) if ($meta<name> // '') eq $name;
    }
    return Nil unless @found;
    @found.sort({ Version.new(.<version> // '0') }).tail
}

# The body is the same for every unit; only the `use` line and the unit name
# change, so the probe is assembled rather than parameterised.
sub probe-source(Str $unit, Bool $deep --> Str) {
    q:to/HEAD/.subst('UNIT-NAME', $unit, :g).subst('DEEP-FLAG', $deep ?? 'True' !! 'False')
    use UNIT-NAME;
    my $U = 'UNIT-NAME';
    my $deep = DEEP-FLAG;

    sub sig(Mu $c --> Str) {
        my $s = (try { $c.signature.gist }) // '(?)';
        $s.subst(/ ^ '(' /, '').subst(/ ')' $ /, '').trim
    }
    sub kind-of(Mu \T --> Str) {
        my $how = (try { T.HOW.^name }) // '';
        return 'class'   if $how.contains('ClassHOW');
        return 'grammar' if $how.contains('GrammarHOW');
        return 'role'    if $how.contains('RoleHOW');
        return 'enum'    if $how.contains('EnumHOW');
        return 'subset'  if $how.contains('SubsetHOW');
        return 'module'  if $how.contains('ModuleHOW');
        return 'package' if $how.contains('PackageHOW');
        $how
    }

    # What a plain `use` drops into the caller's lexical scope.
    my $pkg = try ::($U ~ '::EXPORT::DEFAULT');
    my %who = ($pkg ~~ Failure|Nil) ?? {} !! ((try { $pkg.WHO.Hash }) // {});
    my (@subs, @syms);
    for %who.keys.sort -> $k {
        my \v = %who{$k};
        $k.starts-with('&') ?? @subs.push($k.substr(1) ~ '(' ~ sig(v) ~ ')')
                            !! @syms.push($k ~ ' — ' ~ kind-of(v));
    }
    if @subs { say '  exported subs:';    say '    ' ~ $_ for @subs }
    if @syms { say '  exported symbols:'; say '    ' ~ $_ for @syms }
    say '  (exports nothing by name — a pragma, a slang, or all-method)'
        unless @subs || @syms;

    # …and the type the unit itself names, if it names one.
    my \T = try ::($U);
    unless T ~~ Failure|Nil {
        my $kind = kind-of(T);
        unless $kind eq 'module' | 'package' | '' {
            say '  ' ~ $kind ~ ' ' ~ $U;
            my @m = ((try { T.^methods(:local) }) // ()).grep({
                        $deep || (try { .name }) !~~ / ^ <[A..Z]>+ $ /
                    }).sort({ (try { .name }) // '' });
            if @m {
                say '    methods:';
                for @m -> $m {
                    my $n = (try { $m.name }) // next;
                    say '      ' ~ $n ~ '(' ~ sig($m) ~ ')';
                }
            }
            my @a = ((try { T.^attributes(:local) }) // ()).map({ (try { .name }) // '?' });
            say '    attributes: ' ~ @a.join(', ') if @a;
            my @r = ((try { T.^roles(:!transitive) }) // ()).map({ (try { .^name }) // '?' });
            say '    does: ' ~ @r.join(', ') if @r;
            my @p = ((try { T.^parents(:local) }) // ()).map({ (try { .^name }) // '?' })
                        .grep({ $_ ne 'Any' });
            say '    is: ' ~ @p.join(', ') if @p;
        }
    }
    HEAD
}

sub probe-unit(Str $unit, Bool :$deep, Str :$exe = 'rakupp' --> Str) {
    my $tmp = $*TMPDIR.add('inspect-' ~ $*PID ~ '-' ~ $unit.subst('::', '-', :g) ~ '.raku');
    spurt $tmp, probe-source($unit, $deep);
    LEAVE { try unlink $tmp }
    my $p   = run($exe, $tmp, :out, :err);
    my $out = $p.out.slurp(:close);
    my $err = $p.err.slurp(:close);
    return $out if $out.trim;
    '  (could not be loaded for introspection: '
        ~ ($err.trim ?? $err.lines.head !! 'no output') ~ ')'
}

sub MAIN(Str $name, Bool :$install = False, Bool :$suite = False, Bool :$deep = False) {
    if $install {
        note "# installing $name …";
        my $p = run('rakupp', 'install', $name, :out, :err);
        $p.out.slurp(:close); $p.err.slurp(:close);
    }

    my $meta = find-dist($name);
    unless $meta {
        note "$name: not in the store — run with --install first";
        exit 2;
    }

    say '=' x 72;
    say "dist        $name {$meta<version> // '?'}  {$meta<auth> // ''}";
    say "license     {$meta<license> // '(none stated)'}";
    my @dep = flat($meta<depends> // ()).grep(*.defined).map({ $_ ~~ Str ?? $_ !! .gist });
    say 'depends     ' ~ (@dep ?? @dep.join(', ') !! '(nothing outside the core)');
    say "api         {$meta<api>}" if $meta<api>;
    # The two links a page's frontmatter carries, so they need not be hunted for.
    say "source      {$meta<source-url> // $meta<support><source> // '(none stated)'}";
    say "raku-land   https://raku.land/{$meta<auth> // '?'}/$name";
    # The description is the author's own one-liner. It is printed ONLY so the
    # page can avoid unconsciously echoing it — write your own, then check that
    # it says something different.
    say "their words (do not reuse): {$meta<description> // ''}";

    my %prov = $meta<provides> // {};
    say "provides    {%prov.elems} unit(s)";
    say '=' x 72;

    for %prov.keys.sort -> $unit {
        my $file  = (try { %prov{$unit}.keys[0] }) // '?';
        my $sha   = try { %prov{$unit}{$file}<file> };
        my $src   = $sha ?? STORE.add('sources').add($sha) !! Nil;
        my $lines = ($src && $src.e) ?? $src.lines.elems !! Int;
        say '';
        say "unit $unit   [$file" ~ ($lines.defined ?? ", $lines lines]" !! ']');
        print probe-unit($unit, :$deep);
    }

    if $suite {
        say '';
        say '=' x 72;
        my $t   = run('rakupp', 'test', $name, :out, :err);
        my $log = $t.out.slurp(:close) ~ $t.err.slurp(:close);
        # `suite:` in the frontmatter is written as "N files, green", so report
        # it in exactly that shape rather than making it be counted by hand.
        my $files = +$log.comb(/ ^^ \s* ['ok' | 'not ok' | 'FAILED'] \s /);
        my $m = $log ~~ / (\d+) \s+ 'file' /;
        $files = +$0 if $m;
        say 'suite       ' ~ ($files ?? "$files file" ~ ($files == 1 ?? '' !! 's') ~ ', ' !! '')
                          ~ ($log.contains('suite green') ?? 'green' !! 'NOT GREEN');
        say $log.lines.tail(3).join("\n");
    }
}
