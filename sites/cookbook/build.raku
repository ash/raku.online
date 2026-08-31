# build.raku — the Cookbook at raku.online/cookbook, from the Markdown in
# rakupp/docs/cookbook.
#
#   rakupp build.raku [--clean]
#
# The recipes are synced in by ./sync.sh; this turns them into pages wearing the
# site's shared theme. It handles the Markdown those recipes actually use —
# headings, fenced code, lists, tables, and inline emphasis/code/links — and
# nothing else, on purpose: a general Markdown engine here would be a lot of
# code standing between a typo and a visible page. The renderer is the FAQ
# generator's, which had already been taught exactly this subset.
#
# What is different from the FAQ: a recipe ships PROGRAMS as well as prose, and
# those are not copied here. A link to one resolves to the file in the rakupp
# repo, where the recipe is written — the reader gets the program under version
# control, with its history, rather than a copy this site would have to keep in
# step. sync.sh leaves their names behind in src/programs.txt so a link that no
# longer names a real file is caught by the build instead of by a reader.
#
# Code blocks are static rather than runnable editors. A recipe about DBIish is
# talking to a database server over a socket, which a browser sandbox cannot do,
# so a Run button here would be one that is guaranteed to fail.

my %SITE;
my $BASE = '';
my %TITLES;   # slug => recipe title, so a link to dbiish.md can name the recipe
my @TOC;      # [level, anchor, text] per heading of the page being rendered
my %PROGRAMS; # the programs the cookbook ships, path relative to docs/cookbook

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
    # An escaped pipe only exists to survive a Markdown table cell; the reader
    # wants the pipe.
    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code.subst('\\|', '|', :g)) ~ '</code>');
    }
    $s
}

# A link written as [dbiish.md](dbiish.md) names a file, which is right in
# a repo and wrong on a website — use the recipe's own title instead. Text the
# author actually wrote is left alone. A program's own name IS what the reader
# wants to see, so a .raku target keeps its filename, minus the directory that
# only means something in the repo.
sub link-text(Str $text, Str $target --> Str) {
    if $text eq $target && $target.ends-with('.raku') {
        return $target.split('/').tail;
    }
    return $text unless $text eq $target && $target.ends-with('.md');
    my $slug = $target.subst(/ '.md' $ /, '');
    %TITLES{$slug} // $text
}

# Where these recipes conceptually live inside the rakupp repo's docs/, which
# is what a ../ in a link is relative to.
my constant @HOME-DIR = <cookbook>;

# Where a path written relative to a recipe lands in the rakupp repo, which is
# the recipe's real home: docs/cookbook/ plus the path as written.
sub repo-path(Str $t --> Str) {
    %SITE<docs-base> ~ (|@HOME-DIR, $t).join('/')
}

sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    # ../SOMETHING.md — a rakupp doc that does not live on this site. The
    # recipes are written as if they sat in docs/cookbook/ of the rakupp repo,
    # so ../guide/FFI.md is docs/guide/FFI.md and ../status/ROAST.md is
    # docs/status/ROAST.md. The whole ../ chain has to be resolved here:
    # GitHub serves a blob URL literally and does not normalise a '..' in it.
    if $t.starts-with('../') {
        my @dirs = @HOME-DIR;
        my $rest = $t;
        while $rest.starts-with('../') {
            $rest = $rest.substr(3);
            @dirs.pop if @dirs;
        }
        return %SITE<docs-base> ~ (|@dirs, $rest).join('/');
    }
    # README.md — the index of this cookbook
    return "$BASE/" if $t eq 'README.md';
    # a program the recipe ships — dbiish/names-pg.raku, a path relative to the
    # page, which is exactly the path it has in the repo. That is where the link
    # goes. A name that is not in the manifest is still linked (the reader has
    # somewhere to go) but the build says so, because it will be a GitHub 404.
    if $t.ends-with('.raku') {
        note "link to a program the cookbook does not ship: $t" unless %PROGRAMS{$t};
        return repo-path($t);
    }
    # a directory of programs. GitHub serves a directory under /tree/, not the
    # /blob/ that docs-base is written for.
    if $t.ends-with('/') && !$t.starts-with('/') {
        return repo-path($t).subst('/blob/', '/tree/');
    }
    # another recipe
    if $t.ends-with('.md') {
        return "$BASE/" ~ $t.subst(/ '.md' $ /, '') ~ '/';
    }
    $t
}

# ---- headings and lists ---------------------------------------------------


sub anchor(Str $text --> Str) {
    my $a = $text.lc.subst(/ <-[a..z0..9]>+ /, '-', :g);
    $a.subst(/ ^ '-' /, '').subst(/ '-' $ /, '')
}


# Every section carries a link to itself, shown when the heading is hovered:
# base.css already styles `.anchor` that way, and the tour, the spec and the
# module handbook all emit this exact markup. A recipe is long enough that
# people quote a section of it rather than the page.
sub heading(Int $level, Str $text --> Str) {
    my $id = anchor($text);
    @TOC.push([$level, $id, $text]) if $level <= 2;
    "<h$level id=\"$id\">" ~ inline($text)
      ~ " <a class=\"anchor\" href=\"#$id\" aria-label=\"link\">#</a></h$level>"
}


sub bullet-of(Str $line) {
    # returns [indent, marker-length] for a list line, or Nil
    my $m = $line ~~ / ^ (\s*) ('- ' | \d+ '. ') /;
    $m ?? [ (~$m[0]).chars, (~$m[0]).chars + (~$m[1]).chars ] !! Nil
}


sub list-html(@lines, Int $start) {
    my $i = $start;
    my $ordered = so @lines[$i] ~~ / ^ \s* \d+ '. ' /;
    my @items;
    while $i < @lines.elems {
        my $b = bullet-of(@lines[$i]);
        last unless $b;
        if $b[0] > 0 && @items {
            # one level of nesting: collect it into the item just closed
            my @sub;
            while $i < @lines.elems && (my $s = bullet-of(@lines[$i])) && $s[0] > 0 {
                @sub.push('<li>' ~ inline(@lines[$i].substr($s[1])) ~ '</li>');
                $i++;
            }
            @items[@items.end] ~= '<ul>' ~ @sub.join ~ '</ul>';
            next;
        }
        my $text = @lines[$i].substr($b[1]);
        $i++;
        # continuation lines: an item wrapped over several lines in the source
        while $i < @lines.elems && @lines[$i].trim ne ''
              && !bullet-of(@lines[$i])
              && @lines[$i].starts-with(' ') {
            $text ~= ' ' ~ @lines[$i].trim;
            $i++;
        }
        @items.push('<li>' ~ inline($text) ~ '</li>');
    }
    my $html = ($ordered ?? Q[<ol>] !! Q[<ul>]) ~ @items.join ~ ($ordered ?? Q[</ol>] !! Q[</ul>]);
    ($html, $i)
}

# ---- syntax highlighting --------------------------------------------------

# `rakupp --highlight --html` emits Pygments class names inside a
# <div class="highlight"><pre>…</pre></div> wrapper, and base.css already
# colours those names for `pre.native-code` — the same markup the book, the
# module handbook and the example gallery use. The FAQ joins them rather than
# growing a second palette. The engine doing the highlighting is the one
# running this build, so a page is coloured by the interpreter it documents.
my $RAKUPP = $*EXECUTABLE.absolute;

# Tags off, entities back: what the reader would have if the colour were
# stripped away again.
sub strip-html(Str $h --> Str) {
    $h.subst(/ '<' <-[>]>* '>' /, '', :g)
      .subst('&quot;', '"', :g).subst('&#39;', "'", :g)
      .subst('&lt;', '<', :g).subst('&gt;', '>', :g)
      .subst('&amp;', '&', :g)
}

# The guarantee is checked rather than argued: the highlighted block must strip
# back to exactly the source it came from. These articles promise that every
# snippet is what was run on both engines, so a highlighter that dropped or
# duplicated a character would be breaking the page's own claim. A block that
# fails the round trip — or a highlighter that is not there at all, when the
# site is built by something other than rakupp — is emitted plain, and says so.
sub highlight(Str $code --> Str) {
    my $out = '';
    {
        my $p = run($RAKUPP, '--highlight', '--html', :in, :out, :err);
        $p.in.print($code);
        $p.in.close;
        $out = $p.out.slurp(:close);
        $p.err.slurp(:close);
        CATCH { default { return esc($code) } }
    }
    my $m = $out ~~ / '<pre>' (.*) '</pre>' /;
    return esc($code) unless $m;
    my $html = (~$0).subst(/ ^ '<span></span>' /, '').subst(/ \n+ $ /, '');
    unless strip-html($html) eq $code {
        note "highlight: round-trip failed, block left plain: " ~ ($code.lines[0] // '');
        return esc($code);
    }
    $html
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
            # Raku fences are coloured by the engine's own highlighter; a shell
            # transcript and an output block are shown as they are.
            my $src  = @code.join("\n");
            my $body = $lang eq 'raku' ?? highlight($src) !! esc($src);
            @out.push('<pre class="native-code"><code' ~ $cls ~ '>'
                      ~ $body ~ '</code></pre>');
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

        # block quote — a note set aside from the prose
        if $line.starts-with('> ') {
            my @quote;
            while $i < @lines.elems && @lines[$i].starts-with('> ') {
                @quote.push(@lines[$i].substr(2));
                $i++;
            }
            @out.push('<blockquote class="note"><p>' ~ inline(@quote.join(' ')) ~ '</p></blockquote>');
            next;
        }

        # a horizontal rule between sections
        if $line.trim eq '---' { @out.push('<hr>'); $i++; next; }

        if $line.starts-with('### ') { @out.push(heading(3, $line.substr(4).trim)); $i++; next; }
        if $line.starts-with('## ')  { @out.push(heading(2, $line.substr(3).trim)); $i++; next; }
        if $line.starts-with('# ')   { $i++; next; }   # the title, handled by the caller
        if $line.starts-with('#')    { $i++; next; }   # any deeper heading: never silently loop

        # lists — bullets and numbers, one level of nesting, and items that run
        # over several source lines
        if bullet-of($line) {
            my ($html, $next) = list-html(@lines, $i);
            @out.push($html);
            $i = $next;
            next;
        }

        if $line.trim eq '' { $i++; next; }

        # paragraph — runs until a blank line or the start of another block
        my @para;
        while $i < @lines.elems && @lines[$i].trim ne ''
              && !@lines[$i].starts-with('```') && !@lines[$i].starts-with('#')
              && !@lines[$i].starts-with('|') && !@lines[$i].starts-with('> ')
              && @lines[$i].trim ne '---'
              && !bullet-of(@lines[$i]) {
            @para.push(@lines[$i]);
            $i++;
        }
        @out.push('<p>' ~ inline(@para.join(' ')) ~ '</p>') if @para;
    }
    @out.join("\n")
}

# A cell may contain an escaped pipe inside a code span; splitting on a bare
# '|' would cut the row in the middle of it.
sub cells(Str $row) {
    $row.subst(/ ^ '|' /, '').subst(/ '|' $ /, '')
        .subst('\\|', "\x[1]", :g)
        .split('|').map({ .trim.subst("\x[1]", '\\|', :g) })
}

sub table-html(@rows --> Str) {
    my @head = cells(@rows[0]);
    my @body = @rows[2 .. *];
    # A comparison table can have no header — the two cells are "6.d" and "6.e"
    # in the rows themselves. An empty header row is noise.
    my $h = @head.grep({ $_ ne '' })
              ?? '<tr>' ~ @head.map({ '<th>' ~ inline($_) ~ '</th>' }).join ~ '</tr>'
              !! '';
    my $b = @body.map(-> $r {
        '<tr>' ~ cells($r).map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>'
    }).join("\n");
    '<div class="tablewrap"><table>' ~ $h ~ $b ~ '</table></div>'
}


# A long article gets a contents list under its title; a short one does not need
# one, so this is called only past a threshold.
sub toc-html(--> Str) {
    return '' unless @TOC;
    '<nav class="toc" aria-label="Contents"><ul>'
      ~ @TOC.map(-> @h { '<li><a href="#' ~ @h[1] ~ '">' ~ inline(@h[2]) ~ '</a></li>' }).join
      ~ '</ul></nav>'
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
    <link rel="stylesheet" href="/theme/cook.css">
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
    { $index ?? '' !! '<p class="crumb"><a href="' ~ $BASE ~ '/">← All recipes</a></p>' }
    $body
    <footer>
    <span>Every program on this page was run for it, against a real service where the recipe needs one; the output shown is what it printed.</span>
    <span>Written in the <a href="$repo">rakupp</a> repository. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

# A moved page, in the shape the rest of the site uses for one: no theme, no
# shell, nothing to load — a browser follows the refresh, and a crawler is told
# where the page went by the canonical link. build.sh's sitemap skips these.
# Braces around every $url on purpose: this is HTML, so a variable is usually
# followed by a '<', and "$url</title>" interpolates as a subscript.
sub redirect-page(Str $to --> Str) {
    my $url = "$BASE/$to/";
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="0; url={$url}">
    <link rel="canonical" href="https://raku.online{$url}">
    <title>Moved to raku.online{$url}</title>
    <p>This recipe lives at <a href="{$url}">raku.online{$url}</a> now.</p>
    </html>
    HTML
}

# ---- build ----------------------------------------------------------------

sub title-of(Str $md --> Str) {
    for $md.lines -> $l {
        return $l.substr(2).trim if $l.starts-with('# ');
    }
    'Cookbook'
}

# "Cookbook — DBIish: one program, three databases" reads well at the top of
# its own page, but on the index the prefix is noise on every line.
sub short-title(Str $t --> Str) {
    $t.subst(/ ^ 'Cookbook' \s* [ '—' | '-' ] \s* /, '')
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

    # The programs the cookbook ships, by the path a recipe links them under.
    # Nothing is copied — this is only so a link that names a file the repo does
    # not have is reported while the page is being built.
    my @programs = 'src/programs.txt'.IO.f
        ?? slurp('src/programs.txt').lines.grep(*.trim.chars)
        !! ();
    %PROGRAMS{$_} = True for @programs;

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
        @TOC = ();
        my $body = render($md);          # fills @TOC on the way through
        # Ten sections is where scrolling stops working as navigation. The
        # existing articles sit under that on purpose — a list of seven links
        # above four screens of text is furniture, not help.
        my $toc  = @TOC.elems >= 10 ?? toc-html() !! '';
        spurt("out/$slug/index.html",
              page($title, '<h1>' ~ esc(heading-case(short-title($title))) ~ '</h1>' ~ "\n"
                           ~ $toc ~ "\n" ~ $body));
        @entries.push({ slug => $slug, title => heading-case(short-title($title)) });
    }

    # One paragraph per recipe, the blurb on the line below the link: a
    # bulleted list of two-line entries is furniture, and a blurb behind an em
    # dash buries the title it belongs to.
    my $list = @entries.map(-> %e {
        my $blurb = %SITE<blurbs>{%e<slug>} // '';
        '<p class="cook-entry"><a href="' ~ $BASE ~ '/' ~ %e<slug> ~ '/">' ~ esc(%e<title>) ~ '</a>'
          ~ ($blurb ?? '<br><span class="cook-blurb">' ~ esc($blurb) ~ '</span>' !! '') ~ '</p>'
    }).join("\n");

    spurt('out/index.html',
          page(%SITE<title>, :index,
               '<h1>' ~ esc(%SITE<title>) ~ '</h1>'
               ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
               ~ '<div class="cook-index">' ~ $list ~ '</div>'));

    # A recipe that was renamed leaves its old address behind, and a static host
    # answers a directory that is no longer there with a 404. These stubs are
    # the only pages here that are not built from a recipe.
    my %redirects = %(%SITE<redirects> // {});
    for %redirects.keys.sort -> $from {
        my $to = %redirects{$from};
        note "redirect from $from points at no recipe: $to"
            unless @ordered.first(* eq $to);
        mkdir("out/$from");
        spurt("out/$from/index.html", redirect-page($to));
    }

    say "built {@entries.elems} recipe page(s) + index"
        ~ (%redirects ?? " + {%redirects.elems} redirect(s)" !! '')
        ~ " -> out/ ({@programs.elems} program(s) linked to the repo)";
}
