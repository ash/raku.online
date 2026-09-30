# build.raku — Pace at raku.online/pace: how Raku++ got here, in chapters.
#
#   rakupp build.raku [--clean]
#
# The chapters are HTML fragments in src/pages, one per file, named by slug; the
# order, titles, dates and index blurbs live in src/site.raku, so reordering the
# story is an edit to one list. This wraps each fragment in the site's shell,
# adds the chapter strip and the previous/next links, builds the index, and
# writes out/data.json — the history series the charts draw, cut from the spec
# dashboard's data so both pages plot the same numbers.
#
# The fragments are HTML rather than Markdown because most of what they carry
# is figures, tables and stat blocks, which Markdown would only get in the way of.

use JSON::Fast;

my %SITE;
my $BASE = '';

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

# ---- the page shell -------------------------------------------------------

sub page(Str $title, Str $desc, Str $body --> Str) {
    my $repo = %SITE<repo>;
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
    <link rel="stylesheet" href="/theme/pace.css">
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
    <div class="content pace">
    $body
    <footer>
    <span>Every figure on these pages comes from the release notes, the plans and the measurements committed in the <a href="$repo">rakupp</a> repository.</span>
    <span><a href="/rakupp/">About Raku++</a>. <a href="/spec/dashboard/">The live dashboard</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/pace.js" defer></script>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

# The strip of chapter numbers at the top of every chapter: where you are in
# the story, and one click to anywhere else in it.
sub strip(@chapters, Int $here --> Str) {
    '<nav class="pc-strip" aria-label="Chapters"><a href="' ~ $BASE ~ '/">Pace</a>'
      ~ @chapters.kv.map(-> $i, %c {
            my $cur = $i == $here ?? ' aria-current="page"' !! '';
            '<a href="' ~ $BASE ~ '/' ~ %c<slug> ~ '/"' ~ $cur ~ ' title="' ~ esc(%c<title>) ~ '">'
              ~ ($i + 1) ~ '</a>'
        }).join
      ~ '</nav>'
}

sub prev-next(@chapters, Int $i --> Str) {
    my $out = '<nav class="pc-pn" aria-label="Previous and next chapter">';
    if $i > 0 {
        my %p = @chapters[$i - 1];
        $out ~= '<a class="prev" href="' ~ $BASE ~ '/' ~ %p<slug> ~ '/"><span>← Chapter ' ~ $i ~ '</span>'
              ~ esc(%p<title>) ~ '</a>';
    }
    else {
        $out ~= '<a class="prev" href="' ~ $BASE ~ '/"><span>← Pace</span>All chapters</a>';
    }
    if $i < @chapters.end {
        my %n = @chapters[$i + 1];
        $out ~= '<a class="next" href="' ~ $BASE ~ '/' ~ %n<slug> ~ '/"><span>Chapter ' ~ ($i + 2) ~ ' →</span>'
              ~ esc(%n<title>) ~ '</a>';
    }
    $out ~ '</nav>'
}

# ---- the chart data -------------------------------------------------------

# Only what the charts draw, so a reader does not download the dashboard's
# per-type conformance tables to see one line.
sub chart-data(Str $dash --> Str) {
    my %d = from-json(slurp($dash));
    my @releases = @(%d<releases>).grep({ .<tag>.starts-with(q<v>) || .<tag> eq q<main> }).map(-> %r {
        %( tag => (%r<tag> eq q<main> ?? q<v5.1.0> !! %r<tag>), date => %r<date>,
           files => %r<files_pass>, filesTotal => %r<files_total>,
           tests => %r<tests_pass>, testsTotal => %r<tests_total>,
           bench => %r<bench> // {} )
    });
    to-json(%(
        generated   => %d<generated>,
        dev         => %d<dev>,
        releases    => @releases,
        readings    => %d<roast_readings>,
        conformance => @(%d<conformance>).map({ %( date => .<date>, ok => .<ok>, differs => .<rakupp-differs> ) }),
        battery     => %d<modules>,
        sweep       => %d<sweep>,
        exeSize     => %SITE<exe-size>,
    ), :!pretty)
}

# ---- build ----------------------------------------------------------------

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my @chapters = @(%SITE<chapters>).map(-> %c { %c });
    for @chapters.kv -> $i, %c {
        my $file = 'src/pages/' ~ %c<slug> ~ '.html';
        die "no chapter file $file" unless $file.IO.f;
        my $head = '<p class="pc-eyebrow">Chapter ' ~ ($i + 1) ~ ' · ' ~ esc(%c<when>) ~ '</p>'
                 ~ '<h1>' ~ esc(%c<title>) ~ '</h1>';
        mkdir('out/' ~ %c<slug>);
        spurt('out/' ~ %c<slug> ~ '/index.html',
              page(%c<title> ~ ' — Pace', %c<blurb>,
                   strip(@chapters, $i) ~ "\n" ~ $head ~ "\n" ~ slurp($file) ~ "\n" ~ prev-next(@chapters, $i)));
    }

    # The index: the opening, the whole climb on one chart, then the chapters
    # in reading order under the arc each belongs to.
    my $list = @chapters.kv.map(-> $i, %c {
        '<li><a href="' ~ $BASE ~ '/' ~ %c<slug> ~ '/"><span class="n">' ~ ($i + 1) ~ '</span>'
          ~ '<span class="t">' ~ esc(%c<title>) ~ '</span>'
          ~ '<span class="w">' ~ esc(%c<when>) ~ '</span>'
          ~ '<span class="b">' ~ esc(%c<blurb>) ~ '</span></a></li>'
    }).join("\n");
    spurt('out/index.html',
          page(%SITE<title>, %SITE<tagline>,
               strip(@chapters, -1) ~ "\n"
               ~ '<h1>' ~ esc(%SITE<title>) ~ '</h1>'
               ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
               ~ slurp('src/index.html')
               ~ '<h2 id="chapters">The chapters</h2><ol class="pc-list">' ~ $list ~ '</ol>'));

    spurt('out/data.json', chart-data(%SITE<dashboard>));
    say "built {@chapters.elems} chapter(s) + index + data.json -> out/";
}
