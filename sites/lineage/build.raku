# build.raku — Lineage at raku.online/lineage: what other languages took from
# the Perl 6 design, one page per section of the report.
#
#   rakupp build.raku [--clean]
#
# src/report.md is rakupp's docs/dev/PERL6-FEATURES-IN-OTHER-LANGUAGES.md,
# copied in by sync.sh. Its `## ` sections become the chapters listed in
# src/site.raku; the title and the opening paragraph become the index.
#
# The report cites a primary source for every claim. src/evidence/*.json says,
# per link, who said what, where and when, so a page can show it under the
# paragraph or table that cites it: each such link gets a numbered marker, and
# the block is followed by "What the sources say". An entry's `says` is our
# paraphrase; its `quote`, when someone has filled it in, is shown instead.
# See src/evidence/README.md.

use JSON::Fast;

my %SITE;
my $BASE = '';
my %EV;           # page slug → link target → that page's evidence entry
my %ANY;          # link target → the first entry any page has for it
my %QUOTE;        # link target → the exact wording, from whichever file has it
my %SEEN;         # page slug → link target → True once that page has cited it
my $PAGE = '';    # the slug of the page being rendered

# Per page: the number each cited source got, the sources the current block
# introduced, and the running count.
my %NUM;
my @BLOCK;
my $N = 0;

my constant FIELDS = <who where when says quote note>;

# ---- inline formatting ----------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g).subst('"', '&quot;', :g)
}

sub emph(Str $s --> Str) {
    $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ $0 ~ '</strong>' }, :g)
      .subst(/ (^^ | <-[\w:*]>) '*' (<-[*\s]> <-[*]>*? <-[*\s]> | <-[*\s]>) '*' /,
             { $0 ~ '<em>' ~ $1 ~ '</em>' }, :g)
}

# The report's relative links are written from rakupp/docs/dev/.
sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    my $path = $t.subst(/ '/README.md' $ /, '/');
    $path.ends-with('/') || !$path.split('/').tail.contains('.')
        ?? %SITE<gh-tree> ~ $path.subst(/ '/' $ /, '')
        !! %SITE<gh-base> ~ $path
}

# A page's own evidence file wins; a source cited on a page whose file has no
# entry for it borrows another page's. A quote, added once in any file, is
# shown wherever the source is cited.
sub ev(Str $url) {
    my %e = %EV{$PAGE}{$url} // %ANY{$url} // return Nil;
    %e<quote> = %QUOTE{$url} if %QUOTE{$url}:exists;
    %e
}

sub cite(Str $url, Bool $refs --> Str) {
    return '' unless $refs;
    my %e = ev($url) // return '';
    %SEEN{$PAGE}{$url} = True;
    unless %NUM{$url}:exists {
        %NUM{$url} = ++$N;
        @BLOCK.push($url);
    }
    my $n = %NUM{$url};
    '<sup class="lg-ref"><a href="#ev-' ~ $n ~ '" title="' ~ esc(%e<who> ~ ', ' ~ %e<when>) ~ '">' ~ $n ~ '</a></sup>'
}

# Code spans and links are lifted out before anything is escaped, so `**` or
# `<` inside a span is never mistaken for markup, and a link's target is looked
# up in the evidence exactly as the Markdown spells it. A target may carry one
# level of parentheses (Wikipedia's `Raku_(programming_language)`).
sub inline(Str $text, Bool :$refs = True --> Str) {
    my @code;
    my @links;
    my $s = $text.subst(/ '``' ' '? (.+?) ' '? '``' /, { @code.push(~$0); "\x[0]{ @code.end }\x[0]" }, :g);
    $s = $s.subst(/ '`' (<-[`]>+) '`' /, { @code.push(~$0); "\x[0]{ @code.end }\x[0]" }, :g);
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' ( [ <-[()\s]> | '(' <-[()\s]>* ')' ]+ ) ')' /,
                  { @links.push([~$0, ~$1]); "\x[1]{ @links.end }\x[1]" }, :g);
    $s = emph(esc($s));
    $s = $s.subst(/ \x[1] (\d+) \x[1] /, {
        my ($label, $url) = @links[+$0];
        '<a href="' ~ esc(link-target($url)) ~ '">' ~ emph(esc($label)) ~ '</a>' ~ cite($url, $refs)
    }, :g);
    $s.subst(/ \x[0] (\d+) \x[0] /, { '<code>' ~ esc(@code[+$0].subst('\\|', '|', :g)) ~ '</code>' }, :g)
}

# Evidence text is plain prose; only code spans are honoured in it.
sub prose(Str $text --> Str) {
    my @code;
    my $s = $text.subst(/ '`' (<-[`]>+) '`' /, { @code.push(~$0); "\x[0]{ @code.end }\x[0]" }, :g);
    esc($s).subst(/ \x[0] (\d+) \x[0] /, { '<code>' ~ esc(@code[+$0]) ~ '</code>' }, :g)
}

# ---- evidence -------------------------------------------------------------

# One file per page, named by its slug.
sub load-evidence(@slugs) {
    for dir('src/evidence').grep(*.extension eq 'json').sort -> $f {
        my $slug = $f.basename.subst(/ '.json' $ /, '');
        die "$f: no chapter is called '$slug'" unless $slug eq any(@slugs);
        my %file = from-json(slurp($f));
        for %file.kv -> $url, %e {
            for %e.keys -> $k {
                die "$f: $url: unknown field '$k'" unless $k eq any(FIELDS);
            }
            for <who where when says> -> $k {
                die "$f: $url: '$k' is missing or empty" unless %e{$k} && %e{$k}.trim;
            }
            %EV{$slug}{$url} = %e;
            %ANY{$url} //= %e;
            if %e<quote> && %e<quote>.trim {
                note "$f: $url has a different quote in another file; the first is used"
                    if (%QUOTE{$url}:exists) && %QUOTE{$url} ne %e<quote>.trim;
                %QUOTE{$url} //= %e<quote>.trim;
            }
        }
    }
}

# "What the sources say" under a block: the sources it introduced, numbered as
# they were cited. Open by default, since that is the point; a long one can be
# folded away.
sub aside(--> Str) {
    return '' unless @BLOCK;
    my $items = @BLOCK.map(-> $url {
        my %e = ev($url);
        my $n = %NUM{$url};
        my $src = '<p class="lg-ev-src"><b>' ~ esc(%e<who>) ~ '</b> <span>' ~ esc(%e<where>) ~ '</span> '
                ~ '<time>' ~ esc(%e<when>) ~ '</time> <a href="' ~ esc($url) ~ '">source ↗</a></p>';
        my $body = %e<quote> && %e<quote>.trim
            ?? '<blockquote class="lg-ev-q"><p>' ~ esc(%e<quote>.trim) ~ '</p></blockquote>'
            !! '<p class="lg-ev-says">' ~ prose(%e<says>) ~ '</p>';
        '<li id="ev-' ~ $n ~ '" value="' ~ $n ~ '">' ~ $src ~ $body ~ '</li>'
    }).join("\n");
    my $count = @BLOCK.elems;
    @BLOCK = ();
    "\n" ~ '<details class="lg-ev" open><summary>What the sources say <span class="c">' ~ $count ~ '</span></summary>'
         ~ '<ol>' ~ $items ~ '</ol></details>'
}

# ---- blocks ---------------------------------------------------------------

sub cells(Str $row) {
    $row.subst(/ ^ '|' /, '').subst(/ '|' $ /, '')
        .subst('\\|', "\x[2]", :g)
        .split('|').map({ .trim.subst("\x[2]", '\\|', :g) })
}

sub table-html(@rows --> Str) {
    my @head = cells(@rows[0]);
    my $h = '<tr>' ~ @head.map({ '<th>' ~ inline($_, :!refs) ~ '</th>' }).join ~ '</tr>';
    my $b = @rows[2 .. *].map(-> $r {
        '<tr>' ~ cells($r).map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>'
    }).join("\n");
    '<div class="tablewrap lg-t"><table><thead>' ~ $h ~ '</thead><tbody>' ~ $b ~ '</tbody></table></div>'
}

sub anchor(Str $text --> Str) {
    $text.lc.subst(/ <-[a..z0..9]>+ /, '-', :g).subst(/ ^ '-' /, '').subst(/ '-' $ /, '')
}

sub render(Str $md --> Str) {
    my @out;
    my @lines = $md.lines;
    my $i = 0;
    while $i < @lines.elems {
        my $line = @lines[$i];
        if $line.trim eq '' { $i++; next }

        if $line.starts-with('|') && $i + 1 < @lines.elems && @lines[$i + 1] ~~ / ^ '|' <[\-\|\s:]>+ $ / {
            my @rows;
            while $i < @lines.elems && @lines[$i].starts-with('|') { @rows.push(@lines[$i]); $i++ }
            @out.push(table-html(@rows) ~ aside());
            next;
        }
        if $line ~~ / ^ ('###' '#'?) ' ' (.+) / {
            my $level = (~$0).chars;
            my $text = (~$1).trim;
            @out.push("<h$level id=\"{ anchor($text) }\">" ~ inline($text, :!refs) ~ "</h$level>");
            $i++;
            next;
        }
        if $line.starts-with('- ') {
            my @items;
            while $i < @lines.elems && @lines[$i].starts-with('- ') {
                my $text = @lines[$i].substr(2);
                $i++;
                while $i < @lines.elems && @lines[$i].starts-with('  ') { $text ~= ' ' ~ @lines[$i].trim; $i++ }
                @items.push('<li>' ~ inline($text) ~ '</li>');
            }
            @out.push('<ul>' ~ @items.join ~ '</ul>' ~ aside());
            next;
        }
        my @para;
        while $i < @lines.elems && @lines[$i].trim ne '' && !@lines[$i].starts-with('|')
              && !@lines[$i].starts-with('#') && !@lines[$i].starts-with('- ') {
            @para.push(@lines[$i]);
            $i++;
        }
        @out.push('<p>' ~ inline(@para.join(' ')) ~ '</p>' ~ aside());
    }
    @out.join("\n")
}

# ---- the page shell -------------------------------------------------------

sub page(Str $title, Str $desc, Str $body --> Str) {
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <meta name="description" content="{esc($desc)}">
    <script>window.__SITE_BASE='{$BASE}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/lineage.css">
    </head>
    <body class="home">
    <span class="theme-switch">
      <button class="theme-btn" aria-label="Theme" aria-haspopup="true" aria-expanded="false">◐</button>
      <ul class="theme-menu" hidden>
        <li><button data-theme-set="system"><span class="ti">◐</span> System</button></li>
        <li><button data-theme-set="light"><span class="ti">☀</span> Light</button></li>
        <li><button data-theme-set="dark"><span class="ti">☾</span> Dark</button></li>
      </ul>
    </span>
    <main>
    <div class="content lineage">
    $body
    <footer>
    <span>These pages render <a href="{%SITE<report>}">PERL6-FEATURES-IN-OTHER-LANGUAGES.md</a> from the <a href="{%SITE<repo>}">rakupp</a> repository; the research notes behind it are in <a href="{%SITE<notes>}">perl6-influence-notes</a>.</span>
    <span>Under each claim, “What the sources say” gives every cited source in our words, or in its own where the exact wording has been added (<a href="{%SITE<evidence>}">evidence files</a>).</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

sub strip(@chapters, Int $here --> Str) {
    '<nav class="lg-strip" aria-label="Chapters"><a href="' ~ $BASE ~ '/"'
      ~ ($here < 0 ?? ' aria-current="page"' !! '') ~ '>Lineage</a>'
      ~ @chapters.kv.map(-> $i, %c {
            '<a href="' ~ $BASE ~ '/' ~ %c<slug> ~ '/"' ~ ($i == $here ?? ' aria-current="page"' !! '')
              ~ ' title="' ~ esc(%c<heading>) ~ '">' ~ esc(%c<short>) ~ '</a>'
        }).join
      ~ '</nav>'
}

sub prev-next(@chapters, Int $i --> Str) {
    my $out = '<nav class="lg-pn" aria-label="Previous and next chapter">';
    $out ~= $i > 0
        ?? '<a class="prev" href="' ~ $BASE ~ '/' ~ @chapters[$i - 1]<slug> ~ '/"><span>← ' ~ $i ~ '. ' ~ esc(@chapters[$i - 1]<short>) ~ '</span>' ~ inline(@chapters[$i - 1]<heading>, :!refs) ~ '</a>'
        !! '<a class="prev" href="' ~ $BASE ~ '/"><span>← Lineage</span>All chapters</a>';
    $out ~= '<a class="next" href="' ~ $BASE ~ '/' ~ @chapters[$i + 1]<slug> ~ '/"><span>' ~ ($i + 2) ~ '. ' ~ esc(@chapters[$i + 1]<short>) ~ ' →</span>' ~ inline(@chapters[$i + 1]<heading>, :!refs) ~ '</a>'
        if $i < @chapters.end;
    $out ~ '</nav>'
}

# ---- build ----------------------------------------------------------------

# The report's title, its opening (everything before the first `## `), and its
# sections, each as [heading, body].
sub split-report(Str $md) {
    my $title = '';
    my @intro;
    my @sections;
    for $md.lines -> $line {
        if $line.starts-with('# ') && !$title && !@sections { $title = $line.substr(2).trim; next }
        if $line.starts-with('## ') { @sections.push([$line.substr(3).trim, []]); next }
        @sections ?? @sections.tail[1].push($line) !! @intro.push($line);
    }
    ($title, @intro.join("\n"), |@sections.map({ [.[0], .[1].join("\n")] }))
}

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';
    load-evidence(@(%SITE<chapters>).map(*<slug>));

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my ($title, $intro, @sections) = split-report(slurp('src/report.md'));
    my @chapters = @(%SITE<chapters>).map(-> %c { %c });
    die "src/report.md has {@sections.elems} sections, site.raku lists {@chapters.elems} chapters"
        unless @sections.elems == @chapters.elems;
    for @chapters.kv -> $i, %c {
        die "chapter {$i + 1} ({%c<slug>}) should start '{%c<starts>}' but the report has '{@sections[$i][0]}'"
            unless @sections[$i][0].starts-with(%c<starts>);
        %c<heading> = @sections[$i][0];
    }

    my @stats;
    for @chapters.kv -> $i, %c {
        %NUM = ();
        @BLOCK = ();
        $N = 0;
        $PAGE = %c<slug>;
        my $head = '<p class="lg-eyebrow">Chapter ' ~ ($i + 1) ~ ' of ' ~ @chapters.elems ~ '</p>'
                 ~ '<h1>' ~ inline(%c<heading>, :!refs) ~ '</h1>';
        my $body = render(@sections[$i][1]);
        mkdir('out/' ~ %c<slug>);
        spurt('out/' ~ %c<slug> ~ '/index.html',
              page(%c<heading> ~ ' — Lineage', %c<blurb>,
                   strip(@chapters, $i) ~ "\n" ~ $head ~ "\n" ~ $body ~ "\n" ~ prev-next(@chapters, $i)));
        my $quotes = %NUM.keys.grep({ %QUOTE{$_}:exists }).elems;
        @stats.push("{%c<slug>}: $N source(s) with evidence, $quotes quoted");
    }

    %NUM = ();
    @BLOCK = ();
    $N = 0;
    $PAGE = '';
    my $list = @chapters.kv.map(-> $i, %c {
        '<li><a href="' ~ $BASE ~ '/' ~ %c<slug> ~ '/"><span class="n">' ~ ($i + 1) ~ '</span>'
          ~ '<span class="t">' ~ inline(%c<heading>, :!refs) ~ '</span>'
          ~ '<span class="b">' ~ esc(%c<blurb>) ~ '</span></a></li>'
    }).join("\n");
    my $how = '<p class="lg-how">Every claim links its primary source. A numbered marker after a link means the page says what that source says: look under the paragraph or table, in “What the sources say”. There each source is given in our words, or as a quotation where its exact wording has been added.</p>';
    spurt('out/index.html',
          page(%SITE<title> ~ ' — ' ~ $title, %SITE<tagline>,
               strip(@chapters, -1) ~ "\n"
               ~ '<p class="lg-eyebrow">Read · Lineage</p>'
               ~ '<h1>' ~ inline($title, :!refs) ~ '</h1>'
               ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
               ~ render($intro) ~ "\n" ~ $how
               ~ '<h2 id="chapters">The chapters</h2><ol class="lg-list">' ~ $list ~ '</ol>'));

    # An entry is stale when its own page no longer cites the link.
    my @stale = %EV.kv.map(-> $slug, %f { %f.keys.grep({ !%SEEN{$slug}{$_} }).map({ "$slug.json: $_" }) }).flat.sort;
    note "stale evidence (its page no longer links it): $_" for @stale;
    .say for @stats;
    my $entries = [+] %EV.values.map(*.elems);
    say "built {@chapters.elems} chapter(s) + index -> out/; $entries evidence entries for {%ANY.elems} sources, {%QUOTE.elems} quoted, {@stale.elems} stale";
}
