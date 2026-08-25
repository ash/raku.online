# build.raku — the Rakugrid explorer at raku.online/grid.
#
#   rakupp build.raku [--clean] [--grid=PATH] [--only=FAMILY]
#
# Reads a Rakugrid checkout (the .grid files themselves — see docs/FORMAT.md in
# that repo) and renders it as a browsable site: one page per atom, a family
# index each, and the whole suite as a one-pixel-per-test overview. The suite is
# ~172k tests, so the site never renders them as one list: everything aggregates
# first — family → atom → matrix cell — and the full record detail is fetched
# per atom as JSON when a page is opened.
#
# The checkout is only needed here, at build time. What gets committed under
# www/grid is a self-contained snapshot; a machine without the checkout serves
# and rebuilds every other part of the site unchanged.
#
# The parser below is a port of bin/rakugrid's own (same field rules, same
# authoritative-oracle and comparable() semantics), so the numbers on the site
# agree with what `rakugrid stats` prints in the checkout.

my %SITE;
my $BASE = '';
my $GRID;                 # IO of the rakugrid checkout
my $V = '';               # cache tag for data fetches, derived from the totals

# ------------------------------------------------------------ small helpers

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

sub attr(Str $s --> Str) {
    esc($s).subst('"', '&quot;', :g)
}

sub commify(Int $n --> Str) {
    my $s = $n.Str;
    my $out = '';
    my $c = 0;
    for $s.comb.reverse -> $d {
        $out = ',' ~ $out if $c && $c %% 3;
        $out = $d ~ $out;
        $c++;
    }
    $out
}

sub short(Str $s, Int $n --> Str) {
    $s.chars > $n ?? $s.substr(0, $n - 1) ~ '…' !! $s
}

# JSON string escaping by hand: the observations can carry anything an engine
# ever printed, including control characters, and the emitted files must stay
# valid JSON. NUL is constructed at runtime — a literal one in this source would
# trip the engines this script must run on.
sub jstr(Str $s0 --> Str) {
    my $s = $s0;
    if $s.contains('\\') {
        $s = $s.subst('\\', '\\\\', :g);
    }
    if $s.contains('"') {
        $s = $s.subst('"', '\\"', :g);
    }
    if $s.contains("\n") {
        $s = $s.subst("\n", '\\n', :g);
    }
    if $s.contains("\t") {
        $s = $s.subst("\t", '\\t', :g);
    }
    if $s.contains("\r") {
        $s = $s.subst("\r", '\\r', :g);
    }
    if $s.contains(0.chr) {
        $s = $s.subst(0.chr, '\\u0000', :g);
    }
    if $s ~~ / <[\x01..\x1f]> / {
        $s = $s.comb.map({ .ord < 32 ?? sprintf('\\u%04x', .ord) !! $_ }).join;
    }
    '"' ~ $s ~ '"'
}

sub jarr($items --> Str) { '[' ~ $items.join(',') ~ ']' }

# ------------------------------------------------------------ the .grid parser

# One recorded cell holds bytes that are not valid UTF-8 — an engine printed
# them, so the suite keeps them. utf8-c8 lets the read survive; before anything
# lands in a page or a JSON file, the synthetic codepoints are folded to U+FFFD
# so what this site serves is valid UTF-8 throughout.
my $REPL = 0xFFFD.chr;
sub scrub(Str $s --> Str) {
    my $out = '';
    for $s.comb -> $ch {
        my $o = $ch.ord;
        $out ~= ($o > 0x10FFFF || (0xD800 <= $o <= 0xDFFF)) ?? $REPL !! $ch;
    }
    $out
}

my %TAINTED;   # file path → 1, files that are not valid UTF-8 on disk

sub find-tainted() {
    my $p = run('sh', '-c',
        'cd ' ~ $GRID.Str ~ ' && for f in $(find atoms generated molecules -name "*.grid" 2>/dev/null); do '
        ~ 'iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1 || echo "$f"; done',
        :out, :err);
    for $p.out.slurp(:close).lines -> $rel {
        %TAINTED{$GRID.add($rel).Str} = 1;
    }
    $p.err.slurp(:close);
    note "  { %TAINTED.elems } file(s) carry raw non-UTF-8 bytes; folding those to U+FFFD" if %TAINTED;
}

# A .grid file: `name value` header lines at column 0, then records. A record
# opens with `- id <n>`; fields are two-space indented; a field with an empty
# value takes the four-space block that follows; oracle/from accumulate.
sub parse-grid($path) {
    my %header;
    my @records;
    my %cur;
    my $taint = %TAINTED{$path.Str}:exists;
    my @lines = $path.lines(:enc<utf8-c8>);
    if $taint {
        @lines = @lines.map({ scrub($_) });
    }
    my $n = @lines.elems;
    my $i = 0;

    sub flush() {
        if %cur {
            my %r = %cur;
            @records.push: %r;
            %cur = ();
        }
    }

    while $i < $n {
        my $line = @lines[$i];
        $i++;

        my $t = $line.trim;
        if $t eq '' {
            flush();
            next;
        }
        if $t.starts-with('#') && !$line.starts-with('  ') {
            next;
        }

        if $line.starts-with('- ') {
            flush();
            my $rest = $line.substr(2).trim-leading;
            my $sp = $rest.index(' ');
            if $sp.defined {
                %cur{$rest.substr(0, $sp)} = $rest.substr($sp).trim;
            }
            next;
        }

        if $line.starts-with('  ') && !$line.starts-with('   ') {
            my $body = $line.substr(2);
            my $sp = $body.index(' ');
            my $name  = $sp.defined ?? $body.substr(0, $sp) !! $body;
            my $value = $sp.defined ?? $body.substr($sp).trim !! '';

            if $value eq '' {
                my @block;
                while $i < $n && (@lines[$i].starts-with('    ') || @lines[$i].trim eq '') {
                    last if @lines[$i].trim eq ''
                            && !((@lines[$i + 1] // '').starts-with('    '));
                    @block.push: @lines[$i].starts-with('    ') ?? @lines[$i].substr(4) !! '';
                    $i++;
                }
                $value = @block.join("\n");
            }
            if $name eq 'oracle' || $name eq 'from' {
                %cur{$name} = [] unless %cur{$name}:exists;
                %cur{$name}.push: $value;
            }
            else {
                %cur{$name} = $value;
            }
            next;
        }

        # header line at column 0
        my $sp = $line.index(' ');
        if $sp.defined && $sp > 0 {
            %header{$line.substr(0, $sp)} = $line.substr($sp).trim;
        }
    }
    flush();

    return { header => %header, records => @records };
}

sub grid-files() {
    my @out;
    for <atoms generated molecules> -> $dir {
        my $d = $GRID.add($dir);
        next unless $d.e;
        @out.append: find-grid($d);
    }
    @out.sort({ .Str })
}

sub find-grid($dir) {
    my @out;
    for $dir.dir -> $e {
        if $e.d {
            @out.append: find-grid($e);
        }
        elsif $e.extension eq 'grid' {
            @out.push: $e;
        }
    }
    @out
}

sub rel-of($path --> Str) {
    my $root = $GRID.Str ~ '/';
    my $s = $path.Str;
    $s.starts-with($root) ?? $s.substr($root.chars) !! $s
}

# ------------------------------------------------------------ oracle algebra

sub engine-of(Str $line --> Str) {
    my $sp = $line.index(' ');
    $sp.defined ?? $line.substr(0, $sp) !! $line
}

sub obs-of(Str $line --> Str) {
    my $i = $line.index('→');
    $i.defined ?? $line.substr($i + 1).trim !! ''
}

# A rejection's wording is not specified; two engines refusing the same fragment
# agree even when they say so differently. Same rule as the harness.
sub comparable(Str $o --> Str) {
    $o.starts-with('rejected:') ?? 'rejected' !! $o
}

# rakudo-2026.07 → 2026·7·0·0; rakupp-v3.14.0-114-gc779017-modified → 3·14·0·114.
# Only ever compared within one implementation, so the two scales never meet.
my %SCORE;
sub engine-score(Str $e --> Int) {
    return %SCORE{$e} if %SCORE{$e}:exists;
    my $score = 0;
    my $i = $e.index('-');
    if $i.defined {
        my $v = $e.substr($i + 1);
        $v = $v.substr(1) if $v.starts-with('v');
        my @seg = $v.split('-');
        my @n = @seg[0].split('.').map({ my $x = try .Int; $x // 0 });
        my $dist = 0;
        if @seg.elems > 1 {
            my $d = try @seg[1].Int;
            $dist = $d // 0;
        }
        $score = (((@n[0] // 0) * 100 + (@n[1] // 0)) * 1000 + (@n[2] // 0)) * 100000 + $dist;
    }
    %SCORE{$e} = $score;
    $score
}

sub is-crashy(Str $o --> Bool) {
    $o.starts-with('CRASH:') || $o.starts-with('HANG:') || $o.starts-with('TIMEOUT:')
}

# The display form of what a record asserts. Exactly one assertion field is
# present by the format's rules; `type` may accompany `is`.
sub expect-of(%r --> Str) {
    return %r<is> if %r<is>:exists;
    return 'throws ' ~ %r<throws> if %r<throws>:exists;
    return 'output ' ~ %r<output> if %r<output>:exists;
    return 'same as ' ~ %r<same-as> if %r<same-as>:exists;
    if %r<parses>:exists {
        return %r<parses> eq 'yes' ?? 'compiles' !! 'is rejected';
    }
    return 'is rejected' if %r<no-parse>:exists;
    return 'finishes' if %r<finishes>:exists;
    return 'type ' ~ %r<type> if %r<type>:exists;
    ''
}

# ------------------------------------------------------------ the model

# One entry per atom, keyed by the atom name, merging files that continue the
# same atom (the operator ladders grew across two directories).
my %ATOM;          # name → { name, family, slug, header, files, records }
my @ATOM-ORDER;    # names in first-seen file order

sub slug-of(Str $name --> Str) {
    my $i = $name.index('/');
    ($i.defined ?? $name.substr($i + 1) !! $name).subst('/', '--', :g)
}

sub family-of(Str $name --> Str) {
    my $i = $name.index('/');
    $i.defined ?? $name.substr(0, $i) !! 'misc'
}

sub axes-split(Str $s) {
    my @out = $s.contains(' · ') ?? $s.split(' · ') !! $s.split(' | ');
    @out
}

# Per-record status, the one classification everything on the site colors by:
#   r ruled     a signed verdict stands on this record
#   c crash     the newest rakupp observation is a crash/hang
#   d differs   the newest rakupp observation disagrees with the reference
#   f fixed     an older rakupp disagreed; the newest one agrees
#   a agree     every rakupp observation on record agrees with the reference
#   n no data   one of the two sides was never recorded
sub classify(%r) {
    my @oracle = (%r<oracle> // []).list;
    my $ref = '';
    my $ref-score = -1;
    my @pp;
    for @oracle -> $line {
        my $e = engine-of($line);
        if $e.starts-with('rakudo') {
            my $s = engine-score($e);
            if $s >= $ref-score {
                $ref-score = $s;
                $ref = $line;
            }
        }
        elsif $e.starts-with('rakupp') {
            @pp.push: $line;
        }
    }
    @pp = @pp.sort({ engine-score(engine-of($_)) });

    my $status;
    if %r<verdict>:exists {
        $status = 'r';
    }
    elsif !$ref || !@pp {
        $status = 'n';
    }
    else {
        my $ref-obs = comparable(obs-of($ref));
        my $new-obs = obs-of(@pp[*-1]);
        if comparable($new-obs) ne $ref-obs {
            $status = is-crashy($new-obs) ?? 'c' !! 'd';
        }
        else {
            $status = 'a';
            if @pp.elems > 1 {
                for 0 ..^ (@pp.elems - 1) -> $k {
                    if comparable(obs-of(@pp[$k])) ne $ref-obs {
                        $status = 'f';
                        last;
                    }
                }
            }
        }
    }
    return { status => $status, ref => $ref, pp => @pp };
}

# Fields already rendered somewhere on the page; whatever else a record carries
# (baseline, facets, level, …) goes to the drawer verbatim.
my %KNOWN = ('id', 1, 'cell', 1, 'code', 1, 'oracle', 1, 'verdict', 1, 'why', 1,
             'ruled', 1, 'is', 1, 'throws', 1, 'output', 1, 'parses', 1,
             'no-parse', 1, 'same-as', 1, 'finishes', 1).hash;

sub load-suite(Str $only) {
    my $files = 0;
    for grid-files() -> $f {
        my %parsed = parse-grid($f);
        my $name = %parsed<header><atom> // 'unknown';
        next if $only && family-of($name) ne $only;
        $files++;
        if %ATOM{$name}:exists {
            %ATOM{$name}<files>.push: $f;
            %ATOM{$name}<records>.append: %parsed<records>.list;
        }
        else {
            %ATOM{$name} = {
                name    => $name,
                family  => family-of($name),
                slug    => slug-of($name),
                header  => %parsed<header>,
                files   => [$f],
                records => %parsed<records>,
            };
            @ATOM-ORDER.push: $name;
        }
    }
    note "  read $files .grid files, { %ATOM.elems } atoms";
}

# ------------------------------------------------------------ derived views

my %COUNTS;        # atom name → { a f d c r n, total }
my %ENGINES;       # engine → 1, across the suite
my @CLUSTERS;      # divergence clusters against the newest rakupp per record
my @RULINGS;       # grouped signed rulings
my @CRASHES;       # crash clusters

sub one-line(Str $code --> Str) {
    $code.contains("\n") ?? $code.lines.join(' ') !! $code
}

sub mask-shape(Str $o --> Str) {
    my $s = $o;
    $s = $s.subst(/ \x22 <-[\x22]>* \x22 /, '"…"', :g);
    $s = $s.subst(/ <[0..9]> <[0..9.e+-]>* /, 'N', :g);
    $s
}

sub derive-all() {
    my %cluster;   # shape key → { ref, got, engine, members [] }
    my %ruling;    # verdict|why → { verdict, why, ruled, members [] }
    my %crash;     # engine + obs → members

    for @ATOM-ORDER -> $name {
        my %a = %ATOM{$name};
        my %c = ('a', 0, 'f', 0, 'd', 0, 'c', 0, 'r', 0, 'n', 0).hash;
        my $idx = 0;
        for %a<records>.list -> %r {
            my %cl = classify(%r);
            %r<_status> = %cl<status>;
            %r<_ref>    = %cl<ref>;
            %r<_pp>     = %cl<pp>;
            %c{%cl<status>}++;

            for (%r<oracle> // []).list -> $line {
                %ENGINES{engine-of($line)} = 1;
                my $obs = obs-of($line);
                if $obs.starts-with('CRASH:') || $obs.starts-with('HANG:') {
                    my $key = engine-of($line) ~ "\t" ~ $obs;
                    unless %crash{$key}:exists {
                        %crash{$key} = { engine => engine-of($line), obs => $obs, members => [] };
                    }
                    %crash{$key}<members>.push:
                        { atom => $name, idx => $idx, code => one-line(%r<code> // ''), id => %r<id> // '' };
                }
            }

            if %cl<status> eq 'd' || %cl<status> eq 'c' {
                my $ref-obs = obs-of(%cl<ref>);
                my $pp-obs  = obs-of(%cl<pp>[*-1]);
                my $key = mask-shape($ref-obs) ~ "\x[1F]" ~ mask-shape($pp-obs);
                unless %cluster{$key}:exists {
                    %cluster{$key} = { ref => $ref-obs, got => $pp-obs,
                                       engine => engine-of(%cl<pp>[*-1]), members => [] };
                }
                %cluster{$key}<members>.push:
                    { atom => $name, idx => $idx, code => one-line(%r<code> // ''), id => %r<id> // '' };
            }

            if %r<verdict>:exists {
                my $key = (%r<verdict> // '') ~ "\x[1F]" ~ (%r<why> // '');
                unless %ruling{$key}:exists {
                    %ruling{$key} = { verdict => %r<verdict> // '', why => %r<why> // '',
                                      ruled => %r<ruled> // '', members => [] };
                }
                %ruling{$key}<members>.push:
                    { atom => $name, idx => $idx, code => one-line(%r<code> // ''), id => %r<id> // '' };
            }
            $idx++;
        }
        %c<total> = %a<records>.elems;
        %COUNTS{$name} = %c;
    }

    @CLUSTERS = %cluster.values.sort({ -.<members>.elems });
    @RULINGS  = %ruling.values.sort({ -.<members>.elems });
    @CRASHES  = %crash.values.sort({ -.<members>.elems });
}

sub sum-counts(@names) {
    my %t = ('a', 0, 'f', 0, 'd', 0, 'c', 0, 'r', 0, 'n', 0, 'total', 0).hash;
    for @names -> $n {
        for <a f d c r n total> -> $k {
            %t{$k} += %COUNTS{$n}{$k};
        }
    }
    %t
}

# Families actually present, in the configured order, stragglers appended.
sub family-list() {
    my %seen;
    for @ATOM-ORDER -> $n {
        %seen{%ATOM{$n}<family>} = 1;
    }
    my @out;
    for %SITE<families>.list -> $f {
        @out.push: $f if %seen{$f}:exists;
    }
    for %seen.keys.sort -> $f {
        @out.push: $f unless @out.first({ $_ eq $f });
    }
    @out
}

sub atoms-in(Str $family) {
    my @out = @ATOM-ORDER.grep({ %ATOM{$_}<family> eq $family }).sort;
    @out
}

# ------------------------------------------------------------ JSON emission

sub emit-atom-json(%a) {
    my %h = %a<header>;
    my %eng-seen;
    for %a<records>.list -> %r {
        for (%r<oracle> // []).list -> $line {
            %eng-seen{engine-of($line)} = 1;
        }
    }
    my @rd = %eng-seen.keys.grep({ .starts-with('rakudo') }).sort({ engine-score($_) });
    my @pp = %eng-seen.keys.grep({ !.starts-with('rakudo') }).sort({ engine-score($_) });
    my @engines = flat @rd, @pp;
    my %eng-idx;
    for @engines.kv -> $i, $e {
        %eng-idx{$e} = $i;
    }

    my $def-from = '';
    if %a<records>.elems && (%a<records>[0]<from>:exists) {
        $def-from = %a<records>[0]<from>.list.join(' · ');
    }

    my @recs;
    for %a<records>.list -> %r {
        my @obs = @engines.map({ 'null' });
        for (%r<oracle> // []).list -> $line {
            @obs[%eng-idx{engine-of($line)}] = jstr(obs-of($line));
        }
        my $ruling = '0';
        if %r<verdict>:exists {
            $ruling = '{"v":' ~ jstr(%r<verdict> // '') ~ ',"w":' ~ jstr(%r<why> // '')
                    ~ ',"d":' ~ jstr(%r<ruled> // '') ~ '}';
        }
        my @extra;
        my $from = (%r<from> // []).list.join(' · ');
        if $from && $from ne $def-from {
            @extra.push: jarr([jstr('from'), jstr($from)]);
        }
        for %r.keys.sort -> $k {
            next if %KNOWN{$k}:exists || $k.starts-with('_') || $k eq 'from';
            @extra.push: jarr([jstr($k), jstr(%r{$k}.Str)]);
        }
        @recs.push: jarr([
            jstr(%r<id> // ''),
            jstr(%r<cell> // ''),
            jstr(%r<code> // ''),
            jstr(expect-of(%r)),
            jstr(%r<_status>),
            jarr(@obs),
            $ruling,
            (@extra.elems ?? jarr(@extra) !! '0'),
        ]);
    }

    my @head-pairs;
    for %h.keys.sort -> $k {
        @head-pairs.push: jstr($k) ~ ':' ~ jstr(%h{$k});
    }
    my %c = %COUNTS{%a<name>};
    my $axes = (%h<axes>:exists) ?? jarr(axes-split(%h<axes>).map({ jstr($_) })) !! 'null';
    my $cols = (%h<cols>:exists) ?? jarr(axes-split(%h<cols>).map({ jstr($_) })) !! 'null';
    my $kinds = jarr(@engines.map({ jstr($_.starts-with('rakudo') ?? 'ref' !! 'pp') }));

    '{"atom":' ~ jstr(%a<name>) ~ ',"family":' ~ jstr(%a<family>) ~ ',"slug":' ~ jstr(%a<slug>)
      ~ ',"header":{' ~ @head-pairs.join(',') ~ '}'
      ~ ',"axes":' ~ $axes ~ ',"cols":' ~ $cols
      ~ ',"engines":' ~ jarr(@engines.map({ jstr($_) })) ~ ',"kinds":' ~ $kinds
      ~ ',"defFrom":' ~ jstr($def-from)
      ~ ',"counts":{' ~ <a f d c r n>.map({ '"' ~ $_ ~ '":' ~ %c{$_} }).join(',') ~ '}'
      ~ ',"files":' ~ jarr(%a<files>.map({ jstr(rel-of($_)) }))
      ~ ',"records":[' ~ @recs.join(',') ~ ']}'
}

sub emit-ribbon-json(@families) {
    my @fam-json;
    for @families -> $fam {
        my @atoms;
        for atoms-in($fam) -> $name {
            my %a = %ATOM{$name};
            my $rle = '';
            my $run = 0;
            my $cur = '';
            for %a<records>.list -> %r {
                my $s = %r<_status>;
                if $s eq $cur {
                    $run++;
                }
                else {
                    $rle ~= $run ~ $cur if $run;
                    $cur = $s;
                    $run = 1;
                }
            }
            $rle ~= $run ~ $cur if $run;
            @atoms.push: '{"s":' ~ jstr(%a<slug>) ~ ',"name":' ~ jstr($name)
                       ~ ',"n":' ~ %a<records>.elems ~ ',"rle":' ~ jstr($rle) ~ '}';
        }
        @fam-json.push: '{"family":' ~ jstr($fam) ~ ',"atoms":[' ~ @atoms.join(',') ~ ']}';
    }
    '{"families":[' ~ @fam-json.join(',') ~ ']}'
}

# The atom index the home-page search box filters.
sub emit-search-json(@families) {
    my @rows;
    for @families -> $fam {
        for atoms-in($fam) -> $name {
            my %a = %ATOM{$name};
            my %c = %COUNTS{$name};
            @rows.push: jarr([jstr($name), jstr($fam), jstr(%a<slug>),
                              %c<total>, (%c<d> + %c<c>), %c<r>]);
        }
    }
    '[' ~ @rows.join(',') ~ ']'
}

# ------------------------------------------------------------ the page shell

my $TODAY = Date.today.Str;
my $GRID-COMMIT = '';

my %STATUS-NAME = ('a', 'agree', 'f', 'fixed', 'd', 'differs',
                   'c', 'crash', 'r', 'ruled', 'n', 'no data').hash;

sub nav-html(Str $active --> Str) {
    my @items =
        ['overview',    "$BASE/",             'Overview'],
        ['divergences', "$BASE/divergences/", 'Divergences'],
        ['rulings',     "$BASE/rulings/",     'Rulings'],
        ['crashes',     "$BASE/crashes/",     'Crashes'];
    '<nav class="grid-nav" aria-label="Rakugrid">'
      ~ @items.map(-> @i {
            my $cur = @i[0] eq $active ?? ' aria-current="page"' !! '';
            '<a href="' ~ @i[1] ~ '"' ~ $cur ~ '>' ~ @i[2] ~ '</a>'
        }).join
      ~ '</nav>'
}

sub page(Str $title, Str $body, Str :$kind = 'page', Str :$active = '', Str :$desc = '' --> Str) {
    my $d = $desc || %SITE<tagline>;
    my $repo = %SITE<repo>;
    my $commit-note = $GRID-COMMIT ?? ' at ' ~ esc($GRID-COMMIT) !! '';
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <meta name="description" content="{attr($d)}">
    <script>window.__SITE_BASE='{$BASE}';window.__GRID_V='{$V}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/grid.css">
    </head>
    <body class="home grid-page" data-grid-page="{$kind}">
    <span class="theme-switch">
      <button class="theme-btn" aria-label="Theme" aria-haspopup="true" aria-expanded="false">◐</button>
      <ul class="theme-menu" hidden>
        <li><button data-theme-set="system"><span class="ti">◐</span> System</button></li>
        <li><button data-theme-set="light"><span class="ti">☀</span> Light</button></li>
        <li><button data-theme-set="dark"><span class="ti">☾</span> Dark</button></li>
      </ul>
    </span>
    <main>
    <div class="content">
    {nav-html($active)}
    $body
    <footer>
    <span>Data read from the <a href="$repo">Rakugrid checkout</a>$commit-note on $TODAY. The grid records what each engine actually printed; nothing here is hand-copied.</span>
    <span>Rakugrid is engine-neutral: <a href="$repo">run it</a> against any Raku implementation. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    <script src="/theme/grid.js" defer></script>
    </body>
    </html>
    HTML
}

# ------------------------------------------------------------ page pieces

sub chips-html(%c --> Str) {
    my @out;
    for <a f d c r n> -> $k {
        next unless %c{$k};
        @out.push: '<span class="st-chip st-' ~ $k ~ '"><i></i>' ~ commify(%c{$k}) ~ ' ' ~ %STATUS-NAME{$k} ~ '</span>';
    }
    '<p class="st-chips">' ~ @out.join(' ') ~ '</p>'
}

sub bar-html(%c --> Str) {
    my $total = %c<total> || 1;
    my @out;
    for <a f d c r n> -> $k {
        next unless %c{$k};
        my $pct = 100 * %c{$k} / $total;
        @out.push: '<i class="st-' ~ $k ~ '" style="width:' ~ sprintf('%.3f', $pct) ~ '%"></i>';
    }
    '<span class="st-bar">' ~ @out.join ~ '</span>'
}

sub atom-url(Str $name --> Str) {
    my %a = %ATOM{$name};
    $BASE ~ '/atom/' ~ %a<family> ~ '/' ~ %a<slug> ~ '/'
}

sub test-link(%m --> Str) {
    my $url = atom-url(%m<atom>) ~ '#t=' ~ %m<idx>;
    '<a class="mono" href="' ~ $url ~ '">' ~ esc(%m<atom>) ~ '#' ~ esc(%m<id>) ~ '</a>'
}

# The header fields worth a line on an atom page, in reading order.
sub atom-meta-html(%a --> Str) {
    my %h = %a<header>;
    my @rows;
    for <form pattern law operator forms callform ladder kind facets from-inventory> -> $k {
        next unless %h{$k}:exists;
        @rows.push: '<div><dt>' ~ $k ~ '</dt><dd class="mono">' ~ esc(%h{$k}) ~ '</dd></div>';
    }
    my $src = %h<source> // '';
    my $gen = %h<gen> // '';
    my $origin = ($src eq 'generated' && $gen)
        ?? 'generated by <a href="' ~ %SITE<repo> ~ '/blob/main/' ~ attr($gen) ~ '"><code>' ~ esc($gen) ~ '</code></a>'
        !! 'curated';
    my $files = %a<files>.map({
        my $rel = rel-of($_);
        '<a href="' ~ %SITE<repo> ~ '/blob/main/' ~ attr($rel) ~ '"><code>' ~ esc($rel) ~ '</code></a>'
    }).join(', ');
    '<p class="atom-origin">' ~ $origin ~ ' · ' ~ $files ~ '</p>'
      ~ (@rows.elems ?? '<dl class="atom-meta">' ~ @rows.join ~ '</dl>' !! '')
}

sub render-atom-page(%a, Str $prev, Str $next) {
    my %c = %COUNTS{%a<name>};
    my $navline = '';
    if $prev || $next {
        $navline = '<p class="atom-steps">'
          ~ ($prev ?? '<a href="' ~ atom-url($prev) ~ '">← ' ~ esc($prev) ~ '</a>' !! '<span></span>')
          ~ ($next ?? '<a href="' ~ atom-url($next) ~ '">' ~ esc($next) ~ ' →</a>' !! '<span></span>')
          ~ '</p>';
    }
    my $body = '<p class="crumb"><a href="' ~ $BASE ~ '/">Rakugrid</a> › '
      ~ '<a href="' ~ $BASE ~ '/family/' ~ %a<family> ~ '/">' ~ esc(%a<family>) ~ '</a></p>'
      ~ '<h1 class="mono atom-title">' ~ esc(%a<name>) ~ '</h1>'
      ~ atom-meta-html(%a)
      ~ '<p class="atom-count">' ~ commify(%c<total>) ~ ' tests</p>'
      ~ chips-html(%c)
      ~ '<div id="grid-app" data-atom="' ~ attr(%a<family> ~ '/' ~ %a<slug>) ~ '">'
      ~ '<p class="grid-loading">Loading the grid …</p>'
      ~ '<noscript><p>The interactive grid needs JavaScript; the raw records are in '
      ~ '<a href="' ~ $BASE ~ '/data/atom/' ~ %a<family> ~ '/' ~ %a<slug> ~ '.json">this JSON</a> '
      ~ 'and in the .grid files linked above.</p></noscript></div>'
      ~ $navline;
    page('Rakugrid — ' ~ %a<name>, $body, :kind<atom>,
         :desc(%a<name> ~ ' — ' ~ commify(%c<total>) ~ ' behavioural tests on the Rakugrid.'))
}

sub render-family-page(Str $fam) {
    my @names = atoms-in($fam);
    my %t = sum-counts(@names);
    my @rows;
    for @names -> $name {
        my %c = %COUNTS{$name};
        my %a = %ATOM{$name};
        my $label = %a<header><form> // %a<header><pattern> // %a<header><law>
                 // %a<header><forms> // %a<header><kind> // '';
        @rows.push: '<tr>'
          ~ '<td><a class="mono" href="' ~ atom-url($name) ~ '">' ~ esc($name) ~ '</a>'
          ~ ($label ?? '<br><span class="atom-label mono">' ~ esc(short($label, 80)) ~ '</span>' !! '') ~ '</td>'
          ~ '<td data-n="' ~ %c<total> ~ '">' ~ commify(%c<total>) ~ '</td>'
          ~ '<td data-n="' ~ (%c<d> + %c<c>) ~ '">' ~ ((%c<d> + %c<c>) ?? commify(%c<d> + %c<c>) !! '·') ~ '</td>'
          ~ '<td data-n="' ~ %c<r> ~ '">' ~ (%c<r> ?? commify(%c<r>) !! '·') ~ '</td>'
          ~ '<td data-n="' ~ %c<f> ~ '">' ~ (%c<f> ?? commify(%c<f>) !! '·') ~ '</td>'
          ~ '<td class="bar-cell">' ~ bar-html(%c) ~ '</td>'
          ~ '</tr>';
    }
    my $body = '<p class="crumb"><a href="' ~ $BASE ~ '/">Rakugrid</a></p>'
      ~ '<h1>' ~ esc($fam) ~ '</h1>'
      ~ '<p class="tagline">' ~ commify(%t<total>) ~ ' tests across ' ~ @names.elems
      ~ ' atom' ~ (@names.elems == 1 ?? '' !! 's') ~ '.</p>'
      ~ chips-html(%t)
      ~ '<div class="tablewrap"><table class="atom-table" data-sortable>'
      ~ '<thead><tr><th data-sort="text">Atom</th><th data-sort="num">Tests</th>'
      ~ '<th data-sort="num">Differ</th><th data-sort="num">Ruled</th><th data-sort="num">Fixed</th>'
      ~ '<th></th></tr></thead>'
      ~ '<tbody>' ~ @rows.join("\n") ~ '</tbody></table></div>';
    page('Rakugrid — ' ~ $fam, $body, :kind<family>,
         :desc('The ' ~ $fam ~ ' family of the Rakugrid: ' ~ commify(%t<total>) ~ ' tests in ' ~ @names.elems ~ ' atoms.'))
}

sub members-html(@members, Int $cap = 12 --> Str) {
    my @rows;
    for @members.head($cap) -> %m {
        @rows.push: '<li><code>' ~ esc(short(%m<code>, 110)) ~ '</code> — ' ~ test-link(%m) ~ '</li>';
    }
    my $more = @members.elems > $cap
        ?? '<li class="more">… and ' ~ commify(@members.elems - $cap) ~ ' more</li>'
        !! '';
    '<ul class="member-list">' ~ @rows.join ~ $more ~ '</ul>'
}

# Beyond this many clusters the long tail is one- and two-test shapes; the atom
# pages carry every one of them, so the page stops here rather than growing
# without bound.
my $CLUSTER-CAP = 400;

sub render-divergences() {
    my $total = @CLUSTERS.map({ .<members>.elems }).sum // 0;
    my @blocks;
    for @CLUSTERS.head($CLUSTER-CAP) -> %cl {
        my $n = %cl<members>.elems;
        @blocks.push: '<details class="cluster"><summary>'
          ~ '<span class="cluster-n">' ~ commify($n) ~ '</span>'
          ~ '<span class="cluster-shape"><code class="ref">' ~ esc(short(%cl<ref>, 60)) ~ '</code>'
          ~ ' <span class="vs">vs</span> <code class="got">' ~ esc(short(%cl<got>, 60)) ~ '</code></span>'
          ~ '</summary>'
          ~ '<p class="cluster-detail">reference says <code>' ~ esc(%cl<ref>) ~ '</code> — '
          ~ '<code>' ~ esc(%cl<engine>) ~ '</code> says <code>' ~ esc(%cl<got>) ~ '</code></p>'
          ~ members-html(%cl<members>)
          ~ '</details>';
    }
    my $tail = '';
    if @CLUSTERS.elems > $CLUSTER-CAP {
        my $rest = @CLUSTERS.elems - $CLUSTER-CAP;
        my $rest-tests = @CLUSTERS[$CLUSTER-CAP .. *].map({ .<members>.elems }).sum;
        $tail = '<p class="note-line">… and ' ~ commify($rest) ~ ' smaller clusters covering '
              ~ commify($rest-tests) ~ ' tests; every one is visible on its atom’s page.</p>';
    }
    my $body = '<h1>Divergences</h1>'
      ~ '<p class="tagline">' ~ commify($total) ~ ' tests where the newest rakupp observation on record '
      ~ 'disagrees with the reference, in ' ~ commify(@CLUSTERS.elems) ~ ' clusters by message shape. '
      ~ 'A cluster is usually one root cause; the big ones are the fix-drivers.</p>'
      ~ '<p class="note-line">Each count reflects what stood when the cell was last probed — the '
      ~ 'engine build is named on every record. Adjudicated divergences carry a signed verdict '
      ~ 'and live under <a href="' ~ $BASE ~ '/rulings/">Rulings</a>.</p>'
      ~ @blocks.join("\n") ~ $tail;
    page('Rakugrid — divergences', $body, :kind<divergences>, :active<divergences>,
         :desc('Every unresolved divergence between the engines on record, clustered by message shape.'))
}

sub render-rulings() {
    my $total = @RULINGS.map({ .<members>.elems }).sum // 0;
    my @blocks;
    for @RULINGS -> %ru {
        my $n = %ru<members>.elems;
        @blocks.push: '<details class="cluster ruling"><summary>'
          ~ '<span class="cluster-n">' ~ commify($n) ~ '</span>'
          ~ '<span class="verdict-tag">' ~ esc(%ru<verdict>) ~ '</span> '
          ~ '<span class="cluster-shape">' ~ esc(short(%ru<why>, 110)) ~ '</span>'
          ~ '</summary>'
          ~ '<p class="cluster-detail">' ~ esc(%ru<why>) ~ '</p>'
          ~ (%ru<ruled> ?? '<p class="ruled-line">ruled ' ~ esc(%ru<ruled>) ~ '</p>' !! '')
          ~ members-html(%ru<members>)
          ~ '</details>';
    }
    my $body = '<h1>Rulings</h1>'
      ~ '<p class="tagline">' ~ commify($total) ~ ' signed rulings under ' ~ commify(@RULINGS.elems)
      ~ ' distinct verdicts.</p>'
      ~ '<p>Rakudo is the oracle, not the arbiter. Every test records what the reference '
      ~ 'implementation actually printed — but where the engines disagree, the disagreement '
      ~ 'is not allowed to stand unexamined: either it is a bug to fix, or somebody signs a '
      ~ 'verdict saying which behaviour is right and why, and the build fails until one of the '
      ~ 'two happens. These are the signed verdicts.</p>'
      ~ @blocks.join("\n");
    page('Rakugrid — rulings', $body, :kind<rulings>, :active<rulings>,
         :desc('The signed verdicts: divergences where the reference implementation is not automatically right.'))
}

sub render-crashes() {
    my $total = @CRASHES.map({ .<members>.elems }).sum // 0;
    my @blocks;
    for @CRASHES -> %cr {
        my $n = %cr<members>.elems;
        @blocks.push: '<details class="cluster crash"><summary>'
          ~ '<span class="cluster-n">' ~ commify($n) ~ '</span>'
          ~ '<span class="cluster-shape"><code>' ~ esc(%cr<obs>) ~ '</code> on <code>'
          ~ esc(%cr<engine>) ~ '</code></span>'
          ~ '</summary>'
          ~ members-html(%cr<members>)
          ~ '</details>';
    }
    my $body = '<h1>Crashes</h1>'
      ~ '<p class="tagline">' ~ commify($total) ~ ' recorded observations where an engine did not '
      ~ 'fail a test — it went down. Every one is a one-line program.</p>'
      ~ '<p class="note-line">A crash recorded against an older engine snapshot may be gone in a '
      ~ 'newer one; the atom pages show each record’s full engine history.</p>'
      ~ @blocks.join("\n");
    page('Rakugrid — crashes', $body, :kind<crashes>, :active<crashes>,
         :desc('The one-line programs that took an engine down, grouped by signal.'))
}

# ---- the history charts ----------------------------------------------------

my $CH-W = 460;
my $CH-H = 150;
my $CH-PAD = 10;

sub x-at(Int $i, Int $n) {
    $CH-PAD + ($CH-W - 2 * $CH-PAD) * $i / (($n - 1) || 1)
}

sub y-at($v, $max) {
    $CH-H - $CH-PAD - ($CH-H - 2 * $CH-PAD) * $v / ($max || 1)
}

sub chart-frame(Str $label, Str $last, Str $inner --> Str) {
    '<figure class="hist-chart"><svg viewBox="0 0 ' ~ $CH-W ~ ' ' ~ $CH-H ~ '" role="img" aria-label="'
      ~ attr($label) ~ '">' ~ $inner ~ '</svg><figcaption>' ~ esc($label)
      ~ ' <span class="hist-last">latest: ' ~ $last ~ '</span></figcaption></figure>'
}

# The sweep log: date commit ran failed parked roast_pass roast_files note.
# `failed` is only comparable while `ran` stays put, so the failed series is
# drawn as separate segments with a visible break wherever the suite grew.
sub history-html(--> Str) {
    my $path = %SITE<history>.IO;
    return '' unless $path.e;
    my @rows;
    for $path.lines -> $l {
        next if $l.starts-with('#') || $l.trim eq '' || $l.starts-with('date');
        my @c = $l.split("\t");
        next unless @c.elems >= 5;
        my $ran = try @c[2].Int;
        my $failed = try @c[3].Int;
        next unless $ran.defined && $failed.defined;
        @rows.push: { date => @c[0], ran => $ran, failed => $failed, note => (@c[7] // '') };
    }
    return '' if @rows.elems < 3;
    my $n = @rows.elems;

    my @ran;
    my @failed;
    for @rows -> %r {
        @ran.push: %r<ran>;
        @failed.push: %r<failed>;
    }

    my $ran-max = @ran.max;
    my @pts;
    my @dots;
    for 0 ..^ $n -> $i {
        @pts.push: sprintf('%.1f,%.1f', x-at($i, $n), y-at(@ran[$i], $ran-max));
        @dots.push: sprintf('<circle cx="%.1f" cy="%.1f" r="2.4"/>', x-at($i, $n), y-at(@ran[$i], $ran-max));
    }
    my $svg-size = chart-frame('suite size (tests run)', commify(@ran[*-1]),
        '<polyline class="hist-line" points="' ~ @pts.join(' ') ~ '"/>' ~ @dots.join);

    my $fail-max = @failed.max;
    my @parts;
    my @fdots;
    my @cur;
    for 0 ..^ $n -> $i {
        if @cur.elems && @ran[$i] != @ran[@cur[*-1]] {
            @parts.push: [@cur];
            @cur = ();
        }
        @cur.push: $i;
    }
    @parts.push: [@cur] if @cur.elems;
    my @segs;
    for @parts -> @ixs {
        next unless @ixs.elems > 1;
        my @sp;
        for @ixs -> $i {
            @sp.push: sprintf('%.1f,%.1f', x-at($i, $n), y-at(@failed[$i], $fail-max));
        }
        @segs.push: '<polyline class="hist-line fail" points="' ~ @sp.join(' ') ~ '"/>';
    }
    for 0 ..^ $n -> $i {
        @fdots.push: sprintf('<circle class="fail" cx="%.1f" cy="%.1f" r="2.4"/>',
                             x-at($i, $n), y-at(@failed[$i], $fail-max));
    }
    my $svg-fail = chart-frame('failing on the engine under test', commify(@failed[*-1]),
        @segs.join ~ @fdots.join);

    my @trows;
    for @rows -> %r {
        @trows.push: '<tr><td>' ~ esc(%r<date>) ~ '</td><td>' ~ commify(%r<ran>) ~ '</td><td>'
                   ~ commify(%r<failed>) ~ '</td><td>' ~ esc(%r<note>) ~ '</td></tr>';
    }
    my $table = '<details class="hist-data"><summary>the measured points</summary>'
      ~ '<div class="tablewrap"><table><thead><tr><th>date</th><th>ran</th><th>failed</th><th>note</th></tr></thead><tbody>'
      ~ @trows.join
      ~ '</tbody></table></div></details>';

    '<section class="grid-section"><h2 id="history">The sweep, over time</h2>'
      ~ '<p>Each point is one measured run of the whole suite against a rakupp build. '
      ~ 'The failing count only means something while the suite holds still, so its line '
      ~ 'breaks wherever the suite grew.</p>'
      ~ '<div class="hist-charts">' ~ $svg-size ~ $svg-fail ~ '</div>'
      ~ $table
      ~ '</section>'
}

# ---- the home page ---------------------------------------------------------

sub sample-record-html(--> Str) {
    my $sample = q:to/REC/;
    - id     0005
      from   ladder:mixed×mixed
      cell   0 | NaN
      code   (0) cmp (NaN)
      is     Order::Less
      type   Order
      oracle rakudo-2026.07 → Order::Less
      oracle rakupp-v3.14.0-77-gf431f48-dirty → Order::Less
    REC
    '<pre class="native-code"><code>' ~ esc($sample.trim-trailing) ~ '</code></pre>'
}

sub ruling-example-html(--> Str) {
    my $name = 'numeric/transcendental-correctly-rounded';
    return '' unless %ATOM{$name}:exists;
    my %a = %ATOM{$name};
    my %r = %a<records>[0];
    return '' unless %r<verdict>:exists;
    my $ref = %r<_ref> ?? obs-of(%r<_ref>) !! '';
    my $pp  = %r<_pp>.elems ?? obs-of(%r<_pp>[*-1]) !! '';
    '<div class="ruling-card">'
      ~ '<p class="mono rc-code">' ~ esc(%r<code> // '') ~ '</p>'
      ~ '<table class="rc-table">'
      ~ '<tr><td>reference</td><td class="mono">' ~ esc($ref) ~ '</td></tr>'
      ~ '<tr><td>rakupp</td><td class="mono">' ~ esc($pp) ~ '</td></tr>'
      ~ '<tr><td>ruling</td><td><span class="verdict-tag">' ~ esc(%r<verdict>) ~ '</span> '
      ~ esc(%r<why> // '') ~ '</td></tr>'
      ~ '</table>'
      ~ '<p class="rc-link"><a href="' ~ atom-url($name) ~ '">the whole atom →</a></p>'
      ~ '</div>'
}

sub render-home(@families) {
    my %t = sum-counts(@ATOM-ORDER);
    my $crash-total = @CRASHES.map({ .<members>.elems }).sum // 0;
    my $differ = %t<d> + %t<c>;
    my $agree  = %t<a> + %t<f>;

    # "7 engines" would be misleading: six of the names are rakupp build
    # snapshots, kept so a sweep re-probes only what changed. Count
    # implementations, and let the subtitle own the snapshot story.
    my %impl;
    for %ENGINES.keys -> $e {
        my $i = $e.index('-');
        %impl{$i.defined ?? $e.substr(0, $i) !! $e} = 1;
    }
    my $pp-snaps = %ENGINES.keys.grep({ .starts-with('rakupp') }).elems;

    my @tiles =
        [commify(%t<total>), 'tests', 'every one a single recorded behaviour'],
        [commify(%ATOM.elems), 'atoms', 'one construct probed across a ladder of values'],
        [%impl.elems.Str, 'engines', 'Rakudo as the reference · rakupp across '
                                     ~ $pp-snaps ~ ' build snapshots'],
        [commify($agree), 'agree',
         %t<f> ?? commify(%t<f>) ~ ' of them fixed along the way' !! 'newest observations, both engines'],
        [commify($differ), 'differ', commify(%t<c>) ~ ' of them crash an engine'],
        [commify(%t<r>), 'ruled', 'signed verdicts — the oracle is not the arbiter'];
    my @tile-html;
    for @tiles -> @t {
        @tile-html.push: '<div class="stat-tile"><b>' ~ @t[0] ~ '</b><span>' ~ @t[1]
                       ~ '</span><small>' ~ @t[2] ~ '</small></div>';
    }
    my $tiles = '<div class="stat-tiles">' ~ @tile-html.join ~ '</div>';

    my @fam-blocks;
    for @families -> $fam {
        my @names = atoms-in($fam);
        my %c = sum-counts(@names);
        @fam-blocks.push: '<div class="fam-block">'
          ~ '<h3><a href="' ~ $BASE ~ '/family/' ~ $fam ~ '/">' ~ esc($fam) ~ '</a>'
          ~ '<span class="fam-n">' ~ commify(%c<total>) ~ ' tests · ' ~ @names.elems
          ~ ' atom' ~ (@names.elems == 1 ?? '' !! 's') ~ '</span></h3>'
          ~ '<canvas class="ribbon" data-family="' ~ attr($fam) ~ '" height="1" width="1"></canvas>'
          ~ '</div>';
    }

    my @legend-chips;
    for <a f d c r n> -> $k {
        next unless %t{$k};
        @legend-chips.push: '<button class="st-chip st-' ~ $k ~ '" data-st="' ~ $k ~ '"><i></i>'
                          ~ %STATUS-NAME{$k} ~ ' <span>' ~ commify(%t{$k}) ~ '</span></button>';
    }
    my $legend = '<div class="ribbon-legend">' ~ @legend-chips.join(' ') ~ '</div>';

    my $body = '<h1>Rakugrid</h1>'
      ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
      ~ '<p>Roast asks whether an implementation <em>is</em> Raku. Rakugrid asks whether it '
      ~ 'survives real programs: small constructs (<em>atoms</em>) and their combinations '
      ~ '(<em>molecules</em>), each crossed against a ladder of awkward values, each cell '
      ~ 'recording what every engine on record actually printed. The suite is its own dataset — '
      ~ 'this site is that dataset, browsable.</p>'
      ~ $tiles
      ~ '<section class="grid-section"><h2 id="the-grid">The whole suite, one pixel per test</h2>'
      ~ '<p>Every test in the suite, grouped by family — a gap separates atoms. '
      ~ 'Hover names the atom; click opens it. The colored streaks are divergence clusters: '
      ~ 'one root cause is usually one streak.</p>'
      ~ $legend
      ~ '<p class="ribbon-tip" id="ribbon-tip" hidden></p>'
      ~ '<div class="fam-search"><input id="atom-search" type="search" '
      ~ 'placeholder="find an atom — e.g. cmp, methods/Str, spelling" autocomplete="off">'
      ~ '<ul id="atom-search-hits" hidden></ul></div>'
      ~ @fam-blocks.join("\n")
      ~ '</section>'
      ~ '<section class="grid-section"><h2 id="reading">How to read a cell</h2>'
      ~ '<p>A test is one record in a <code>.grid</code> file: the code, the asserted behaviour, '
      ~ 'and one <code>oracle</code> line per engine that ever ran it — newest observation last:</p>'
      ~ sample-record-html()
      ~ '<p>The colors compare each record’s <em>newest</em> rakupp observation with the '
      ~ 'reference: <b>agree</b> and <b>differs</b> mean what they say; '
      ~ '<b>crash</b> means the engine went down rather than answering; <b>ruled</b> means the '
      ~ 'divergence was adjudicated by hand; <b>no data</b> means one side was never recorded. '
      ~ 'An observation is a snapshot, not a verdict on today’s binary: a differing cell says '
      ~ 'the engines disagreed when that cell was last probed, and the drawer names the exact '
      ~ 'build that said it. The rakupp snapshots accumulate on purpose — a sweep re-probes '
      ~ 'only what changed, so an untouched cell keeps the build that last ran it instead of '
      ~ 'costing a fresh run of the whole grid.</p>'
      ~ '</section>'
      ~ '<section class="grid-section"><h2 id="arbiter">The oracle is not the arbiter</h2>'
      ~ '<p>Where the engines disagree, Rakudo’s answer is the <em>default</em>, not the law. '
      ~ 'A divergence must either be fixed or receive a signed verdict naming which behaviour is '
      ~ 'right and why — otherwise the build fails. Sometimes the verdict goes against the '
      ~ 'reference:</p>'
      ~ ruling-example-html()
      ~ '<p>All ' ~ commify(%t<r>) ~ ' signed rulings are on the '
      ~ '<a href="' ~ $BASE ~ '/rulings/">rulings page</a>; the '
      ~ commify($crash-total) ~ ' recorded crash observations have '
      ~ '<a href="' ~ $BASE ~ '/crashes/">their own</a>.</p>'
      ~ '</section>'
      ~ history-html()
      ~ '<section class="grid-section"><h2 id="run">Run it yourself</h2>'
      ~ '<p>The suite is engine-neutral and lives at '
      ~ '<a href="' ~ %SITE<repo> ~ '">github.com/ash/rakugrid</a>. The harness runs unchanged '
      ~ 'under any implementation:</p>'
      ~ '<pre class="native-code"><code>raku bin/rakugrid fire --engine=/path/to/rakupp   # run everything, emit TAP'
      ~ "\nraku bin/rakugrid matrix operators/infix-cmp      # one atom as a matrix"
      ~ "\nraku bin/rakugrid isolate 'grid:operators/infix-cmp#0005'   # one test, standalone"
      ~ "\nraku bin/rakugrid check                           # the build rule: no unsigned divergences</code></pre>"
      ~ '<p>Every test on this site has a “run in the playground” button — the code runs in your '
      ~ 'browser on the same engine that powers <a href="/play/">the playground</a>.</p>'
      ~ '</section>';

    page('Rakugrid', $body, :kind<home>, :active<overview>,
         :desc('The behavioural grid of the Raku language: ' ~ commify(%t<total>)
               ~ ' recorded tests across ' ~ commify(%ATOM.elems) ~ ' atoms, on every engine on record.'))
}

# ------------------------------------------------------------ build

sub MAIN(Bool :$clean = False, Str :$grid = '', Str :$only = '') {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';
    $GRID = ($grid || %SITE<grid-src>).IO;

    unless $GRID.d {
        note "no Rakugrid checkout at $GRID — pass --grid=PATH";
        exit 1;
    }

    my $t0 = now;
    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    $GRID-COMMIT = do {
        my $p = run('git', '-C', $GRID.Str, 'rev-parse', '--short', 'HEAD', :out, :err);
        my $s = $p.out.slurp(:close).trim;
        $p.err.slurp(:close);
        $s.chars > 0 && $s.chars < 20 ?? $s !! ''
    };

    note "reading the grid at $GRID …";
    find-tainted();
    load-suite($only);
    note "  classifying …";
    derive-all();

    my @families = family-list();
    my %t = sum-counts(@ATOM-ORDER);
    $V = %t<total> ~ '-' ~ (%t<d> + %t<c>) ~ '-' ~ %t<r>;

    note "  emitting data …";
    mkdir('out/data');
    mkdir('out/data/atom');
    mkdir('out/family');
    mkdir('out/atom');
    for @families -> $fam {
        mkdir("out/data/atom/$fam");
        mkdir("out/family/$fam");
        mkdir("out/atom/$fam");
    }
    for @ATOM-ORDER -> $name {
        my %a = %ATOM{$name};
        spurt('out/data/atom/' ~ %a<family> ~ '/' ~ %a<slug> ~ '.json', emit-atom-json(%a));
    }
    spurt('out/data/ribbon.json', emit-ribbon-json(@families));
    spurt('out/data/atoms.json', emit-search-json(@families));

    note "  emitting pages …";
    for @families -> $fam {
        my @names = atoms-in($fam);
        spurt("out/family/$fam/index.html", render-family-page($fam));
        for @names.kv -> $i, $name {
            my %a = %ATOM{$name};
            my $dir = 'out/atom/' ~ $fam ~ '/' ~ %a<slug>;
            mkdir($dir);
            spurt($dir ~ '/index.html',
                  render-atom-page(%a, ($i ?? @names[$i - 1] !! ''), (@names[$i + 1] // '')));
        }
    }
    mkdir('out/divergences');
    spurt('out/divergences/index.html', render-divergences());
    mkdir('out/rulings');
    spurt('out/rulings/index.html', render-rulings());
    mkdir('out/crashes');
    spurt('out/crashes/index.html', render-crashes());
    spurt('out/index.html', render-home(@families));

    my $dt = (now - $t0).Int;
    note "built { %ATOM.elems } atom pages, { @families.elems } families, "
       ~ "{ commify(%t<total>) } tests -> out/ in {$dt}s";
}
