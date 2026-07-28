# build.raku — the FAQ at raku.online/faq, from the Markdown in rakupp/docs/faq.
#
#   rakupp build.raku [--clean]
#
# The articles are synced in by ./sync.sh; this turns them into pages wearing
# the site's shared theme. It handles the Markdown those articles actually use —
# headings, fenced code, lists, tables, and inline emphasis/code/links — and
# nothing else, on purpose: a general Markdown engine here would be a lot of
# code standing between a typo and a visible page.
#
# Code blocks are rendered static rather than as runnable editors. Much of this
# FAQ is about `run`, `shell` and compiling to a binary, none of which a browser
# sandbox can do, so live editors would offer the reader a Run button that was
# guaranteed to fail.

my %SITE;
my $BASE = '';
my %TITLES;   # slug => article title, so a link to shell.md can name the article

# ---- inline formatting ----------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

# Code spans are protected before anything else runs, so `**` or `_` inside a
# span is never mistaken for emphasis, and a link's text can contain code.
sub inline(Str $text --> Str) {
    my @spans;
    my $s = $text.subst(/ '`' (<-[`]>+) '`' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);

    $s = esc($s);

    # <https://…> — Markdown's bare autolink, which these articles use for URLs.
    $s = $s.subst(/ '&lt;' (< h > 'ttp' <-[&\s]>+) '&gt;' /, {
        '<a href="' ~ ~$0 ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    # [text](target) — .md targets are rewritten to where the page actually is.
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ link-target(~$1) ~ '">' ~ link-text(~$0, ~$1) ~ '</a>'
    }, :g);

    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    # put the code spans back, escaped now that no pattern can see into them
    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code) ~ '</code>');
    }
    $s
}

# A link written as [shell.md](shell.md) names a file, which is right in a repo
# and wrong on a website — use the article's own title instead. Text the author
# actually wrote is left alone.
sub link-text(Str $text, Str $target --> Str) {
    return $text unless $text eq $target && $target.ends-with('.md');
    my $slug = $target.subst(/ '.md' $ /, '');
    %TITLES{$slug} // $text
}

sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    # ../SOMETHING.md — a rakupp doc that does not live on this site
    if $t.starts-with('../') {
        return %SITE<docs-base> ~ $t.subst('../', '');
    }
    # README.md — the index of this FAQ
    return "$BASE/" if $t eq 'README.md';
    # another article
    if $t.ends-with('.md') {
        return "$BASE/" ~ $t.subst(/ '.md' $ /, '') ~ '/';
    }
    $t
}

# ---- block formatting -----------------------------------------------------

sub render(Str $md --> Str) {
    my @out;
    my @lines = $md.lines;
    my $i = 0;

    while $i < @lines.elems {
        my $line = @lines[$i];

        # fenced code — copied through verbatim, only escaped
        if $line.starts-with('```') {
            my $lang = $line.substr(3).trim;
            my @code;
            $i++;
            while $i < @lines.elems && !@lines[$i].starts-with('```') {
                @code.push(@lines[$i]);
                $i++;
            }
            $i++;   # the closing fence
            my $cls = $lang ?? ' class="lang-' ~ $lang ~ '"' !! '';
            @out.push('<pre class="native-code"><code' ~ $cls ~ '>'
                      ~ esc(@code.join("\n")) ~ '</code></pre>');
            next;
        }

        # table — a header row, a separator, then body rows
        if $line.starts-with('|') && $i + 1 < @lines.elems
           && @lines[$i + 1] ~~ / ^ '|' <[\-\|\s:]>+ $ / {
            my @rows;
            while $i < @lines.elems && @lines[$i].starts-with('|') {
                @rows.push(@lines[$i]);
                $i++;
            }
            @out.push(table-html(@rows));
            next;
        }

        if $line.starts-with('## ')  { @out.push('<h2>' ~ inline($line.substr(3))  ~ '</h2>'); $i++; next; }
        if $line.starts-with('### ') { @out.push('<h3>' ~ inline($line.substr(4))  ~ '</h3>'); $i++; next; }
        if $line.starts-with('# ')   { $i++; next; }   # the title, handled by the caller

        # lists — bullets and numbers, each item one line in these articles
        if $line ~~ / ^ '- ' / || $line ~~ / ^ \d+ '. ' / {
            my $ordered = so $line ~~ / ^ \d+ '. ' /;
            my @items;
            while $i < @lines.elems
                  && (@lines[$i] ~~ / ^ '- ' / || @lines[$i] ~~ / ^ \d+ '. ' /) {
                my $item = @lines[$i].subst(/ ^ ('- ' | \d+ '. ') /, '');
                @items.push('<li>' ~ inline($item) ~ '</li>');
                $i++;
            }
            @out.push(($ordered ?? '<ol>' !! '<ul>') ~ @items.join ~ ($ordered ?? '</ol>' !! '</ul>'));
            next;
        }

        if $line.trim eq '' { $i++; next; }

        # paragraph — runs until a blank line or the start of another block
        my @para;
        while $i < @lines.elems && @lines[$i].trim ne ''
              && !@lines[$i].starts-with('```') && !@lines[$i].starts-with('#')
              && !@lines[$i].starts-with('|')
              && !(@lines[$i] ~~ / ^ '- ' /) && !(@lines[$i] ~~ / ^ \d+ '. ' /) {
            @para.push(@lines[$i]);
            $i++;
        }
        @out.push('<p>' ~ inline(@para.join(' ')) ~ '</p>') if @para;
    }
    @out.join("\n")
}

sub cells(Str $row) {
    $row.subst(/ ^ '|' /, '').subst(/ '|' $ /, '').split('|').map(*.trim)
}

sub table-html(@rows --> Str) {
    my @head = cells(@rows[0]);
    my @body = @rows[2 .. *];
    my $h = '<tr>' ~ @head.map({ '<th>' ~ inline($_) ~ '</th>' }).join ~ '</tr>';
    my $b = @body.map(-> $r {
        '<tr>' ~ cells($r).map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>'
    }).join("\n");
    '<div class="tablewrap"><table>' ~ $h ~ $b ~ '</table></div>'
}

# ---- the page shell -------------------------------------------------------

sub page(Str $title, Str $body, :$index = False --> Str) {
    my $repo = %SITE<repo>;
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
    <div class="content">
    { $index ?? '' !! '<p class="crumb"><a href="' ~ $BASE ~ '/">← All questions</a></p>' }
    $body
    <footer>
    <span>Every snippet here is run on both Raku++ and Rakudo and produces identical output; where they differ, the page says so.</span>
    <span>Written in the <a href="$repo">rakupp</a> repository. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

# ---- build ----------------------------------------------------------------

sub title-of(Str $md --> Str) {
    for $md.lines -> $l {
        return $l.substr(2).trim if $l.starts-with('# ');
    }
    'FAQ'
}

# "FAQ — running external commands" reads well at the top of its own page, but
# on the index the prefix is noise on every line.
sub short-title(Str $t --> Str) {
    $t.subst(/ ^ 'FAQ' \s* [ '—' | '-' ] \s* /, '')
}

# Headings and index entries get a capital; the same title used as link text
# inside a sentence ("See turning a program into a binary") keeps the author's
# lower case, which is why %TITLES stores the uncapitalised form.
sub heading-case(Str $t --> Str) { $t.tc }

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my @files = dir('src/pages').grep({ .IO.f && .Str.ends-with('.md') }).map(*.IO.basename).sort;
    my @slugs = @files.map({ .subst(/ '.md' $ /, '') });

    # configured order first, then anything new that has not been placed yet
    my @ordered = @(%SITE<order>).grep(-> $s { so @slugs.first(* eq $s) });
    for @slugs -> $s {
        @ordered.push($s) unless @ordered.first(* eq $s);
    }

    # Titles first: an article can link to any other, so they must all be known
    # before the first page is rendered.
    for @ordered -> $slug {
        %TITLES{$slug} = short-title(title-of(slurp("src/pages/$slug.md")));
    }

    my @entries;
    for @ordered -> $slug {
        my $md    = slurp("src/pages/$slug.md");
        my $title = title-of($md);
        mkdir("out/$slug");
        spurt("out/$slug/index.html",
              page($title, '<h1>' ~ esc(heading-case(short-title($title))) ~ '</h1>' ~ "\n" ~ render($md)));
        @entries.push({ slug => $slug, title => heading-case(short-title($title)) });
    }

    my $list = @entries.map(-> %e {
        my $blurb = %SITE<blurbs>{%e<slug>} // '';
        '<li><a href="' ~ $BASE ~ '/' ~ %e<slug> ~ '/">' ~ esc(%e<title>) ~ '</a>'
          ~ ($blurb ?? ' — ' ~ esc($blurb) !! '') ~ '</li>'
    }).join("\n");

    spurt('out/index.html',
          page(%SITE<title>, :index,
               '<h1>' ~ esc(%SITE<title>) ~ '</h1>'
               ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
               ~ '<ul class="home-nav">' ~ $list ~ '</ul>'));

    say "built {@entries.elems} FAQ page(s) + index -> out/";
}
