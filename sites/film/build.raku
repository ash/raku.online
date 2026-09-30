# build.raku — Film at raku.online/film: Raku++ Internals, short animated films
# about one mechanism of the interpreter each.
#
#   rakupp build.raku [--clean]
#
# A film is text plus audio, and the two live apart. The player, each episode's
# scenes, its narration scripts and its subtitles are in the rakupp repository
# (docs/film, or $RAKUPP_FILM). The narration audio is here, in audio/<slug>/,
# one track and one timing table per style, written there by rakupp's
# docs/film/tools/voice.py. This joins them: it wraps each episode in the site's
# shell with its timing tables embedded, copies the player, the scenes and the
# audio next to it, and builds the episode list.

use JSON::Fast;

my $BASE = '/film';
my $SRC  = %*ENV<RAKUPP_FILM> // $*HOME ~ '/raku++/docs/film';

# The narration styles, in the order the player offers them; the first plays by
# default. A style with subs has its own subtitles; the others show the
# captions written into the scenes.
my @STYLES =
    { id => 'casual',     label => 'Casual',     note => 'a friendlier, rewritten script', subs => 'casual-subs.txt' },
    { id => 'enterprise', label => 'Enterprise', note => 'a documentary read of the original script' };

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

# An 8-hex cache tag over some files, so a changed player or scene file is
# fetched again rather than served from a browser's cache.
sub tag(*@files --> Str) {
    my $p = run('sh', '-c', 'cat "$@" | shasum', 'sh', |@files, :out);
    $p.out.slurp(:close).substr(0, 8)
}

sub spoken(Str $file --> List) {
    $file.IO.slurp.lines.grep(*.chars).List
}

# ---- the page shell -------------------------------------------------------

sub page(Str $title, Str $desc, Str $body, Str $tail = '' --> Str) {
    my $ptag = tag("$SRC/player/film.css");
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
    <link rel="stylesheet" href="{$BASE}/film.css?v={$ptag}">
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
    <div class="content film-page">
    $body
    <footer>
    <span>Each film is drawn from the plans, commits and code in the <a href="https://github.com/ash/rakupp">rakupp</a> repository, where its scenes and scripts live under <code>docs/film</code>.</span>
    <span><a href="/rakupp/">About Raku++</a>. <a href="/pace/">Pace</a>, the project's history.</span>
    </footer>
    </div>
    </main>
    $tail
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

sub prev-next(@eps, Int $i --> Str) {
    my $out = '<nav class="film-pn" aria-label="Previous and next episode">';
    if $i > 0 {
        my %p = @eps[$i - 1];
        $out ~= '<a class="prev" href="' ~ $BASE ~ '/' ~ %p<slug> ~ '/"><span>← Episode ' ~ %p<number> ~ '</span>'
              ~ esc(%p<title>) ~ '</a>';
    }
    else {
        $out ~= '<a class="prev" href="' ~ $BASE ~ '/"><span>← Film</span>All episodes</a>';
    }
    if $i < @eps.end {
        my %n = @eps[$i + 1];
        $out ~= '<a class="next" href="' ~ $BASE ~ '/' ~ %n<slug> ~ '/"><span>Episode ' ~ %n<number> ~ ' →</span>'
              ~ esc(%n<title>) ~ '</a>';
    }
    $out ~ '</nav>'
}

# ---- one episode ------------------------------------------------------------

sub episode(%e, @eps, Int $i) {
    my $slug = %e<slug>;
    my $dir  = %e<dir>;
    my $out  = 'out/' ~ $slug;
    mkdir($out);

    # Every script, the subtitles and every timing table must agree on the number
    # of spoken lines, or the voice drifts away from the picture.
    my $count;
    my @styles;
    for @STYLES -> %s {
        my $id    = %s<id>;
        my @lines = spoken($dir ~ '/' ~ $id ~ '.txt');
        my @clips = @(from-json(slurp('audio/' ~ $slug ~ '/' ~ $id ~ '.json')));
        $count //= @lines.elems;
        die "$slug: $id.txt has {@lines.elems} spoken lines, the first style has $count"
            unless @lines.elems == $count;
        die "$slug: $id.json times {@clips.elems} clips for {@lines.elems} lines; run voice.py again"
            unless @clips.elems == @lines.elems;
        my %o = id => $id, label => %s<label>, note => %s<note>, src => $id ~ '.mp4', clips => @clips;
        if %s<subs> {
            my @subs = spoken($dir ~ '/' ~ %s<subs>);
            die "$slug: {%s<subs>} has {@subs.elems} lines for $count spoken lines"
                unless @subs.elems == $count;
            %o<subs> = @subs;
        }
        @styles.push(%o);
        copy('audio/' ~ $slug ~ '/' ~ $id ~ '.mp4', $out ~ '/' ~ $id ~ '.mp4');
    }
    copy($dir ~ '/scenes.js', $out ~ '/scenes.js');

    my $vo = to-json(%( credit => 'George and Alice', styles => @styles ), :!pretty).subst('</', '<\/', :g);
    my $player = slurp($SRC ~ '/player/player.html')
        .subst('{{ARIA}}', esc(%e<aria>))
        .subst('{{SOURCES}}', %e<sources>);
    my $body = '<p class="film-eyebrow"><a href="' ~ $BASE ~ '/">Raku++ Internals</a> · Episode ' ~ %e<number> ~ '</p>'
             ~ '<h1>' ~ esc(%e<title>) ~ '</h1>'
             ~ '<p class="tagline">' ~ esc(%e<blurb>) ~ '</p>' ~ "\n"
             ~ $player ~ "\n" ~ prev-next(@eps, $i);
    my $tail = '<script>window.FILM_VO = ' ~ $vo ~ ';</script>' ~ "\n"
             ~ '<script src="' ~ $BASE ~ '/film.js?v=' ~ tag($SRC ~ '/player/film.js') ~ '"></script>' ~ "\n"
             ~ '<script src="scenes.js?v=' ~ tag($dir ~ '/scenes.js') ~ '"></script>';
    spurt($out ~ '/index.html',
          page(%e<title> ~ ' — Raku++ Internals', %e<blurb>, $body, $tail));
}

# ---- build ----------------------------------------------------------------

sub MAIN(Bool :$clean = False) {
    die "no film sources at $SRC (set RAKUPP_FILM)" unless ($SRC ~ '/episodes').IO.d;
    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my @eps = dir($SRC ~ '/episodes').grep({ .d && .add('episode.json').f }).map(-> $d {
        my %e = from-json(slurp($d.add('episode.json')));
        %e<slug> = $d.basename;
        %e<dir>  = ~$d;
        %e
    }).sort({ $^a<number> <=> $^b<number> });

    for @eps.kv -> $i, %e { episode(%e, @eps, $i) }
    copy($SRC ~ '/player/film.js',  'out/film.js');
    copy($SRC ~ '/player/film.css', 'out/film.css');

    my $list = @eps.map(-> %e {
        '<li><a href="' ~ $BASE ~ '/' ~ %e<slug> ~ '/"><span class="n">' ~ %e<number> ~ '</span>'
          ~ '<span class="t">' ~ esc(%e<title>) ~ '</span>'
          ~ '<span class="b">' ~ esc(%e<blurb>) ~ '</span>'
          ~ '<span class="m">Episode ' ~ %e<number> ~ ' · narrated · Casual or Enterprise</span></a></li>'
    }).join("\n");
    my $intro = 'Short animated films, each about one mechanism inside the Raku++ interpreter. '
              ~ 'Each film states a problem, draws the data structures that solve it, traces one example '
              ~ 'through them, and shows what stays outside the mechanism.';
    spurt('out/index.html',
          page('Film — Raku++ Internals', $intro,
               '<p class="film-eyebrow">Raku++ Internals</p><h1>Film</h1>'
               ~ '<p class="tagline">' ~ esc($intro) ~ '</p>'
               ~ '<ol class="film-list">' ~ $list ~ '</ol>'));
    say "built {@eps.elems} episode(s) + index -> out/";
}
