# build.raku — generated RakuMap programs at raku.online/map.
#
#   rakupp build.raku [--clean] [--map=PATH]
#
# Reads the small, committed fixture corpus from a RakuMap checkout. Campaign
# output under RakuMap's ignored out/ directory is deliberately never published.

my %SITE;
my $BASE = '';

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

sub page(Str $title, Str $body, Bool :$editor = False --> Str) {
    my $engine = $editor ?? "\n" ~ '<script src="/raku.js?v=00000000"></script>' !! '';
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <script>window.__SITE_BASE='{$BASE}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/map.css">
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
    <main><div class="content">
    $body
    <footer>
      <span>Programs are generated deterministically from recorded seeds.</span>
      <span><a href="{%SITE<repo>}">RakuMap on GitHub ↗</a></span>
    </footer>
    </div></main>
    <script src="/theme/shell.js" defer></script>{$engine}
    </body>
    </html>
    HTML
}

sub read-cases(IO::Path $root) {
    my $generated = $root.add('fixtures/generated');
    die "no committed generated corpus at {$generated.Str}" unless $generated.d;
    my @cases;
    for $generated.dir.grep(*.d).sort(*.basename) -> $group {
        for $group.dir.grep({ .f && .extension eq 'raku' }).sort(*.basename) -> $file {
            my $name = $file.basename.subst(/ '.raku' $ /, '');
            my $seed = $name ~~ / (\d ** 8) $ / ?? +$0 !! 0;
            @cases.push: {
                group => $group.basename, name => $name, seed => $seed,
                code => $file.slurp,
                repo-path => 'fixtures/generated/' ~ $group.basename ~ '/' ~ $file.basename,
            };
        }
    }
    @cases
}

sub index-page(@cases --> Str) {
    my @body = '<h1>' ~ esc(%SITE<title>) ~ '</h1>',
        '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>',
        '<p>These are the fixed programs checked into RakuMap for review and regression. '
        ~ 'Choose one to edit and run it directly in the browser. A generated difference '
        ~ 'is evidence to investigate—not automatically a Raku++ defect.</p>';
    my $group = '';
    for @cases.kv -> $i, %case {
        if %case<group> ne $group {
            @body.push('</div>') if $group;
            $group = %case<group>;
            @body.push('<h2>' ~ esc($group) ~ '</h2>');
            @body.push('<div class="map-programs">');
        }
        @body.push('<a class="map-program" href="' ~ $BASE ~ '/' ~ %case<name> ~ '/">'
            ~ '<code>' ~ esc(%case<name>) ~ '</code><span>seed ' ~ %case<seed> ~ '</span></a>');
    }
    @body.push('</div>') if $group;
    page(%SITE<title>, @body.join("\n"))
}

sub case-page(%case, $prev, $next --> Str) {
    my $rows = min(%case<code>.lines.elems + 1, 28);
    my @body = '<p class="crumb"><a href="' ~ $BASE ~ '/">← All generated programs</a></p>',
        '<div class="map-meta"><span>' ~ esc(%case<group>) ~ '</span><span>seed ' ~ %case<seed> ~ '</span></div>',
        '<h1><code>' ~ esc(%case<name>) ~ '.raku</code></h1>',
        '<p>Edit the generated case and press Run. It executes locally in your browser using Raku++.</p>',
        '<pre data-raku data-rows="' ~ $rows ~ '">' ~ esc(%case<code>.chomp) ~ '</pre>',
        '<p class="map-links"><a href="' ~ %SITE<repo> ~ '/blob/main/' ~ %case<repo-path>
        ~ '">Source on GitHub ↗</a></p>';
    my @nav;
    @nav.push('<a href="' ~ $BASE ~ '/' ~ $prev<name> ~ '/">← ' ~ $prev<name> ~ '</a>') if $prev;
    @nav.push('<a class="next" href="' ~ $BASE ~ '/' ~ $next<name> ~ '/">' ~ $next<name> ~ ' →</a>') if $next;
    @body.push('<nav class="map-next">' ~ @nav.join(' ') ~ '</nav>') if @nav;
    page(%case<name> ~ ' — RakuMap', @body.join("\n"), :editor)
}

sub MAIN(Bool :$clean = False, Str :$map = '') {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base>;
    my $root = ($map || %SITE<map-src>).IO.absolute.IO;
    my @cases = read-cases($root);
    die 'RakuMap generated corpus is empty' unless @cases;
    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');
    for @cases.kv -> $i, %case {
        mkdir("out/{%case<name>}");
        my $prev = $i > 0 ?? @cases[$i - 1] !! Nil;
        my $next = $i < @cases.end ?? @cases[$i + 1] !! Nil;
        spurt("out/{%case<name>}/index.html", case-page(%case, $prev, $next));
    }
    spurt('out/index.html', index-page(@cases));
    say "built {@cases.elems} RakuMap program page(s) + index -> out/";
}
