# build.raku — the showcase at raku.online/showcase, and /live beside it,
# from the READMEs in rakupp/showcase and rakupp/live.
#
#   rakupp build.raku [--clean]
#
# One page per project, rendered from the project's own README; the index is
# driven by the table in showcase/README.md, so a directory that the table
# does not name (raytracer) cannot reach the site. live/ — other people's
# software run unmodified — is two pages and does not warrant a generator of
# its own, so this one builds out/showcase/ and out/live/ side by side.
#
# It also builds out/in-use/ — the hub the three sections hang off, and the
# adoptions list behind it. The hub used to be hand-written HTML in www/, which
# meant a row added to rakupp's live/ADOPTIONS.md had to be re-typed here; now
# both the cards and the page behind them come from that one synced file.
#
# The sources are synced in by ./sync.sh; the Markdown handled here is what
# those READMEs actually use — headings, fenced code, lists, tables, quotes,
# inline emphasis/code/links — and nothing more, on purpose.

my %SITE;
my $BASE = '';
my $LIVE = '';
my @CTX;         # repo directory the page being rendered sits in, e.g. <showcase chat>
my @PROJECTS;    # showcase slugs, from the README table (+ extras)
my @ENTRIES;     # live slugs

# ---- inline formatting ----------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

# Code spans are protected before anything else runs, so `**` or `<key>` inside
# a span is never mistaken for markup. Longest fence first: a ````…```` span
# exists to show ``` literally, and a ``…`` span to show a backtick — so each
# must be taken before a shorter fence can see into it.
sub inline(Str $text --> Str) {
    my @spans;
    my $s = $text.subst(/ '````' ' '? (.+?) ' '? '````' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);
    $s = $s.subst(/ '``' ' '? (.+?) ' '? '``' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);
    $s = $s.subst(/ '`' (<-[`]>+) '`' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);

    $s = esc($s);

    # <https://…> — Markdown's bare autolink.
    $s = $s.subst(/ '&lt;' (< h > 'ttp' <-[&\s]>+) '&gt;' /, {
        '<a href="' ~ ~$0 ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    # [text](target) — targets resolved against the page's place in the repo.
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ link-target(~$1) ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code.subst('\\|', '|', :g)) ~ '</code>');
    }
    $s
}

# A README link is written from inside its repo directory (@CTX). Resolve the
# ../ chain against that, then decide: another page on this site, or GitHub.
sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    my @dirs = @CTX;
    my $rest = $t.subst(/ '/' $ /, '');
    while $rest.starts-with('../') || $rest eq '..' {
        $rest = $rest eq '..' ?? '' !! $rest.substr(3);
        @dirs.pop if @dirs;
    }
    my @path = (|@dirs, |$rest.split('/').grep(* ne ''));
    @path.pop if @path && @path[@path.end] eq 'README.md';
    my $path = @path.join('/');

    return $BASE ~ '/' if $path eq 'showcase';
    return $LIVE ~ '/' if $path eq 'live';
    return '/in-use/adoptions/' if $path eq 'live/ADOPTIONS.md';
    if @path.elems == 2 && @path[0] eq 'showcase' && @path[1] eq any(@PROJECTS) {
        return $BASE ~ '/' ~ @path[1] ~ '/';
    }
    if @path.elems == 2 && @path[0] eq 'live' && @path[1] eq any(@ENTRIES) {
        return $LIVE ~ '/' ~ @path[1] ~ '/';
    }
    # Everything else lives in the repo: a file (has an extension) or a tree.
    @path[@path.end].contains('.')
        ?? %SITE<gh-base> ~ $path
        !! %SITE<gh-tree> ~ $path
}

# ---- headings and lists ---------------------------------------------------

sub anchor(Str $text --> Str) {
    my $a = $text.lc.subst(/ <-[a..z0..9]>+ /, '-', :g);
    $a.subst(/ ^ '-' /, '').subst(/ '-' $ /, '')
}

sub heading(Int $level, Str $text --> Str) {
    # A heading may carry a link ("## The other direction — [ADOPTIONS.md](…)").
    # The id is made from what a reader sees, not from the Markdown around it.
    my $id = anchor($text.subst(/ '[' (<-[\]]>+) ']' '(' <-[)]>+ ')' /, { ~$0 }, :g));
    "<h$level id=\"$id\">" ~ inline($text) ~ "</h$level>"
}

sub bullet-of(Str $line) {
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

# ---- block formatting -----------------------------------------------------

sub render(Str $md --> Str) {
    my @out;
    my @lines = $md.lines;
    my $i = 0;

    while $i < @lines.elems {
        my $line = @lines[$i];

        # A fence may sit inside a list item, indented; the indent belongs to
        # the list, not the code, so it is stripped from every body line.
        if $line.trim.starts-with('```') {
            my $ind = $line.chars - $line.subst(/ ^ ' '+ /, '').chars;
            my $pad = ' ' x $ind;
            my $lang = $line.trim.substr(3).trim;
            my @code;
            $i++;
            while $i < @lines.elems && !@lines[$i].trim.starts-with('```') {
                my $l = @lines[$i];
                $l = $l.starts-with($pad) ?? $l.substr($ind) !! $l.trim eq '' ?? '' !! $l;
                @code.push($l);
                $i++;
            }
            $i++;
            my $cls = $lang ?? ' class="lang-' ~ $lang ~ '"' !! '';
            @out.push('<pre class="native-code"><code' ~ $cls ~ '>'
                      ~ esc(@code.join("\n")) ~ '</code></pre>');
            next;
        }

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

        if $line.starts-with('> ') {
            my @quote;
            while $i < @lines.elems && @lines[$i].starts-with('> ') {
                @quote.push(@lines[$i].substr(2));
                $i++;
            }
            @out.push('<blockquote class="note"><p>' ~ inline(@quote.join(' ')) ~ '</p></blockquote>');
            next;
        }

        if $line.trim eq '---' { @out.push('<hr>'); $i++; next; }

        if $line.starts-with('#### ') { @out.push(heading(4, $line.substr(5).trim)); $i++; next; }
        if $line.starts-with('### ') { @out.push(heading(3, $line.substr(4).trim)); $i++; next; }
        if $line.starts-with('## ')  { @out.push(heading(2, $line.substr(3).trim)); $i++; next; }
        if $line.starts-with('#')    { $i++; next; }   # the title, handled by the caller

        if bullet-of($line) {
            my ($html, $next) = list-html(@lines, $i);
            @out.push($html);
            $i = $next;
            next;
        }

        if $line.trim eq '' { $i++; next; }

        my @para;
        while $i < @lines.elems && @lines[$i].trim ne ''
              && !@lines[$i].trim.starts-with('```') && !@lines[$i].starts-with('#')
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

sub cells(Str $row) {
    $row.subst(/ ^ '|' /, '').subst(/ '|' $ /, '')
        .subst('\\|', "\x[1]", :g)
        .split('|').map({ .trim.subst("\x[1]", '\\|', :g) })
}

sub table-html(@rows --> Str) {
    my @head = cells(@rows[0]);
    my @body = @rows[2 .. *];
    my $h = @head.grep({ $_ ne '' })
              ?? '<tr>' ~ @head.map({ '<th>' ~ inline($_) ~ '</th>' }).join ~ '</tr>'
              !! '';
    my $b = @body.map(-> $r {
        '<tr>' ~ cells($r).map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>'
    }).join("\n");
    '<div class="tablewrap"><table>' ~ $h ~ $b ~ '</table></div>'
}

# ---- the page shell -------------------------------------------------------

sub page(Str $title, Str $body, Str $foot, :$css = 'showcase',
         :$body-class = 'home', :$desc = '' --> Str) {
    my $repo = %SITE<repo>;
    my $meta = $desc ?? "\n<meta name=\"description\" content=\"{esc($desc)}\">" !! '';
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>$meta
    <script>window.__SITE_BASE='{$BASE}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/{$css}.css">
    </head>
    <body class="{$body-class}">
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
    $body
    <footer>
    <span>{$foot}</span>
    <span>Written in the <a href="$repo">rakupp</a> repository. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

my constant FOOT-SHOWCASE =
    'Every showcase runs under the interpreter and compiles to a standalone native binary with <code>rakupp --exe</code>.';
my constant FOOT-INUSE =
    'Everything here runs under the same interpreter — in your browser, from the command line, or compiled to a standalone native binary.';
my constant FOOT-LIVE =
    'The tools here are other people\'s work — installed from the ecosystem, run unmodified, credited, and checked against Rakudo.';

# ---- parsing the index table ----------------------------------------------

sub title-of(Str $md --> Str) {
    for $md.lines -> $l {
        return $l.substr(2).trim if $l.starts-with('# ');
    }
    ''
}

# The table in showcase/README.md: | [**lisp/**](lisp) | Axis — detail | how |
sub parse-index(Str $md) {
    my @projects;
    for $md.lines -> $line {
        next unless $line.starts-with('|');
        my @c = cells($line);
        next unless @c[0] ~~ / '[' '**' (<-[*/]>+) '/'? '**' ']' /;
        my $slug = ~$0;
        my ($shelf, $detail) = @c[1].split(' — ', 2);
        @projects.push({
            slug  => $slug,
            shelf => $shelf // @c[1],
            axis  => $detail // '',
            how   => @c[2] // '',
        });
    }
    @projects
}

# ---- pages -----------------------------------------------------------------

sub actions-html(Str $slug --> Str) {
    my @a;
    if %SITE<play>{$slug} -> $play {
        @a.push('<a class="sc-btn" href="' ~ $play ~ '">Run it in the playground ↗</a>');
    }
    @a.push('<a class="sc-btn ghost" href="' ~ %SITE<gh-tree> ~ @CTX.join('/')
        ~ '">Source on GitHub ↗</a>');
    '<p class="sc-actions">' ~ @a.join(' ') ~ '</p>'
}

sub project-page(Str $slug --> Str) {
    my $md = slurp("src/showcase/$slug.md");
    @CTX = 'showcase', $slug;
    my $title = title-of($md) || $slug;
    my $body = '<p class="crumb"><a href="' ~ $BASE ~ '/">← All showcases</a></p>'
        ~ "\n<h1>" ~ inline($title) ~ '</h1>'
        ~ "\n" ~ actions-html($slug)
        ~ "\n" ~ render($md);
    page("$slug — Raku++ showcase", $body, FOOT-SHOWCASE)
}

sub live-page(Str $slug --> Str) {
    my $md = slurp("src/live/$slug.md");
    @CTX = 'live', $slug;
    my $title = title-of($md) || $slug;
    my $body = '<p class="crumb"><a href="' ~ $LIVE ~ '/">← Software that already existed</a></p>'
        ~ "\n<h1>" ~ inline($title) ~ '</h1>'
        ~ "\n<p class=\"sc-actions\"><a class=\"sc-btn ghost\" href=\"" ~ %SITE<gh-tree>
        ~ 'live/' ~ $slug ~ '">The harness on GitHub ↗</a></p>'
        ~ "\n" ~ render($md);
    page("$slug — run under Raku++, unmodified", $body, FOOT-LIVE)
}

sub live-index(--> Str) {
    my $md = slurp('src/live/README.md');
    @CTX = 'live',;
    my $title = title-of($md) || %SITE<live-title>;
    my $body = '<p class="crumb"><a href="/in-use/">← Raku++ in use</a></p>'
        ~ "\n<h1>" ~ inline($title) ~ '</h1>'
        ~ "\n" ~ render($md);
    page(%SITE<live-title>, $body, FOOT-LIVE)
}

# ---- /in-use/ — the hub, and the adoptions list behind it ------------------

# The table at the top of live/ADOPTIONS.md, one row per adoption:
#   | [**Name**](https://the-project/) | Who | what it does with Raku++ |
# Its first cell links to the thing itself, so a row is already a whole card
# and the hub needs nothing this generator has to be told separately.
sub parse-adoptions(Str $md) {
    my @rows;
    for $md.lines -> $line {
        next unless $line.starts-with('|');
        my @c = cells($line);
        next unless @c[0] ~~ / '[' '**' (<-[*]>+) '**' ']' '(' (< h > 'ttp' <-[)]>+) ')' /;
        @rows.push({ name => ~$0, url => ~$1, who => @c[1] // '', what => @c[2] // '' });
    }
    @rows
}

sub adoptions-page(--> Str) {
    my $md = slurp('src/live/ADOPTIONS.md');
    @CTX = 'live',;
    my $title = (title-of($md) || 'adoptions').tc;
    my $body = '<p class="crumb"><a href="/in-use/">← Raku++ in use</a></p>'
        ~ "\n<h1>" ~ inline($title) ~ '</h1>'
        ~ "\n<p class=\"sc-actions\"><a class=\"sc-btn ghost\" href=\"" ~ %SITE<gh-base>
        ~ 'live/ADOPTIONS.md">The list on GitHub ↗</a></p>'
        ~ "\n" ~ render($md);
    page('Adoptions — software that adopted Raku++', $body, FOOT-INUSE)
}

# Counts on the hub are written out, and they change: the showcase card said
# "Fifteen" for a sixteenth project's first day on the site. Spell what was
# actually built rather than what someone last typed.
sub spell(Int $n --> Str) {
    my @w = <zero one two three four five six seven eight nine ten eleven twelve
             thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty
             twenty-one twenty-two twenty-three twenty-four twenty-five twenty-six
             twenty-seven twenty-eight twenty-nine thirty>;
    $n < @w.elems ?? @w[$n] !! ~$n
}

# The hub, in the order a stranger needs it: what other people did with the
# engine on their own, then what is here to try. Both halves are generated —
# the cards below come from the same file as the page behind them.
sub inuse-page(@adoptions, Int $showcases --> Str) {
    @CTX = 'live',;
    my @body;
    # The shelves first — what a visitor can open right now — then what other
    # people did with the engine somewhere else.
    @body.push(qq:to/SHELVES/);
        <div class="sr-hero">
          <p class="sr-eyebrow"><a href="/">← the front page</a> · <b>Raku++ in use</b></p>

          <h1>The Raku language, in use</h1>

          <p class="sr-lede">
            Two kinds of evidence, and neither of them is slides. Code running
            under the engine here — complete programs with live editors,
            mid-size projects, and whole tools from the ecosystem driven
            unmodified — and, elsewhere, software other people built that
            reached for the engine on its own. Every output on these pages was
            printed by the program beside it, captured from the interpreter
            itself.
          </p>
        </div>

        <section class="sr-sec" id="try-it">
          <p class="sr-kicker">Try it yourself</p>
          <h2>Code to read and run <a class="anchor" href="#try-it" aria-label="link">#</a></h2>
          <p class="sr-intro">
            Not snippets: working code, on three shelves — and only the first
            two were written here. Complete programs you can edit and re-run on
            their own page; mid-size projects that answer "what can it actually
            build?"; and then other people's software again, whole tools
            installed from the ecosystem the way any user installs them and run
            unmodified. Nothing on that third shelf is in this repository
            either: what is kept there is the harness that drives it.
          </p>

          <div class="sr-grid three">
            <div class="sr-card link">
              <h3><a href="/examples/">Raku by example</a></h3>
              <p>
                Twenty-four self-contained programs, one page each: the README's story,
                the full source in a live editor, and what it prints. Twenty-one run
                right on the page, in your browser; the three that need real threads or
                sockets say so and show their native output.
              </p>
              <p class="sr-more">
                <a href="/examples/mandel/">The Mandelbrot set</a>
                <span class="sep">·</span>
                <a href="/examples/calculator/">a grammar as a calculator</a>
                <span class="sep">·</span>
                <a href="/examples/nqueens/">8 queens</a>
              </p>
            </div>

            <div class="sr-card link">
              <h3><a href="/showcase/">The showcase</a></h3>
              <p>
                {spell($showcases).tc} mid-size projects, each stressing a different part of the
                language: interpreters for five other languages, servers on raw sockets,
                a SQLite client over NativeCall, seventeen ecosystem distributions
                composing. Each page is the project's own README; each project compiles
                to a standalone binary.
              </p>
              <p class="sr-more">
                <a href="/showcase/lisp/">A Scheme interpreter</a>
                <span class="sep">·</span>
                <a href="/showcase/sqlite/">the SQLite client</a>
                <span class="sep">·</span>
                <a href="/showcase/pastebin/">a pastebin server</a>
              </p>
            </div>

            <div class="sr-card link">
              <h3><a href="/live/">Software that already existed</a></h3>
              <p>
                The opposite discipline: whole tools from the Raku ecosystem — other
                people's work — installed the way any user installs them, run
                unmodified, and diffed against Rakudo's output. Code nobody wrote for
                this implementation reaches for corners nobody here would have thought
                to test.
              </p>
              <p class="sr-more">
                <a href="/live/sparrow/">Sparrow6, and what starting an interpreter costs</a>
              </p>
            </div>
          </div>

          <p class="sr-fine" style="margin-top:1.6rem">
            The example outputs are captured from the native interpreter and committed —
            a page cannot show output its program did not produce — and every
            deterministic capture is verified byte-identical under Rakudo. The five
            showcase interpreters are also loaded in
            <a href="/play/">the playground</a>, program in the input box, ready to run.
          </p>

          <p class="sr-cta" style="margin-top:1.6rem">
            <a class="sr-btn" href="/examples/">Start with the examples</a>
            <a class="sr-btn ghost" href="/showcase/">Browse the showcase</a>
          </p>
        </section>

        <section class="sr-sec" id="adoptions">
          <p class="sr-kicker">Elsewhere</p>
          <h2>Adoptions <a class="anchor" href="#adoptions" aria-label="link">#</a></h2>
          <p class="sr-intro">
            Nobody here wrote these, and nobody here was asked: a paclet in
            Wolfram's own repository, a browser playground that offers Raku++ as
            one runtime among four, a Guix channel, a port of the release matrix
            to somebody else's CI. Each link goes to whoever built it.
          </p>
        SHELVES

    my @cards;
    for @adoptions -> %a {
        my $what = %a<what> ?? %a<what>.tc ~ '.' !! '';
        @cards.push('  <div class="sr-card link">'
            ~ "\n    <h3><a href=\"" ~ %a<url> ~ '">' ~ esc(%a<name>) ~ ' ↗</a></h3>'
            ~ "\n    <p>" ~ inline($what) ~ '</p>'
            ~ "\n    <p class=\"sr-more\">" ~ inline(%a<who>) ~ '</p>'
            ~ "\n  </div>");
    }
    @body.push('  <div class="sr-grid two">' ~ "\n" ~ @cards.join("\n") ~ "\n  </div>");

    @body.push(q:to/TAIL/);

          <p class="sr-cta" style="margin-top:1.6rem">
            <a class="sr-btn ghost" href="/in-use/adoptions/">What each one actually does →</a>
          </p>
        </section>
        TAIL

    page('The Raku language, in use', @body.join("\n"), FOOT-INUSE,
         css => 'showroom', body-class => 'showroom',
         desc => 'Two halves: software other people built on Raku++ — a Wolfram '
               ~ 'paclet, a browser playground, a Guix channel — and the example '
               ~ 'programs, showcase projects and ecosystem tools you can run here.')
}

sub index-page(@projects --> Str) {
    @CTX = 'showcase',;
    my @body;
    @body.push('<p class="crumb"><a href="/in-use/">← Raku++ in use</a></p>');
    @body.push('<h1>' ~ esc(%SITE<title>) ~ '</h1>');
    @body.push('<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>');
    @body.push('<p>Every one of them runs under the interpreter and compiles to a
        standalone native binary. Five are interpreters for other languages, and
        run in your browser — the <a href="/play/">playground</a> has them as
        examples. For single-file programs rather than projects, see
        <a href="/examples/">the examples</a>.</p>');

    my $shelf = '';
    for @projects -> %p {
        if %p<shelf> ne $shelf {
            $shelf = %p<shelf>;
            @body.push('<h2 id="' ~ anchor($shelf) ~ '">' ~ esc($shelf) ~ '</h2>');
        }
        my $blurb = %p<axis> ?? %p<axis>.tc ~ '. ' !! '';
        $blurb ~= %p<how>.tc ~ '.' if %p<how>;
        my $play = %SITE<play>{%p<slug>}:exists
            ?? ' <span class="badge-play">runs in the browser</span>'
            !! '';
        @body.push('<p class="sc-entry"><a href="' ~ $BASE ~ '/' ~ %p<slug> ~ '/"><code>'
            ~ %p<slug> ~ '</code></a>' ~ $play
            ~ '<br><span class="sc-blurb">' ~ inline($blurb) ~ '</span></p>');
    }

    @body.push('<h2 id="live">Software that already existed</h2>');
    @body.push('<p>The showcases were written here, for Raku++. <a href="'
        ~ $LIVE ~ '/">live</a> is the opposite discipline: whole tools from the
        Raku ecosystem — other people\'s work — installed the way any user
        installs them and run unmodified, their output checked against
        Rakudo\'s. <a href="' ~ $LIVE ~ '/">How that works, and what it has
        found →</a></p>');

    page(%SITE<title>, @body.join("\n"), FOOT-SHOWCASE)
}

# ---- build -----------------------------------------------------------------

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';
    $LIVE = %SITE<live-base> // '';

    my @projects = parse-index(slurp('src/showcase/README.md'));
    for @(%SITE<extras>) -> %x {
        @projects.push(%x);
    }
    @PROJECTS = @projects.map({ $_<slug> });
    # ADOPTIONS.md sits in live/ but is not a live entry — it is the list of
    # software that adopted Raku++ rather than the other way round, and it
    # becomes /in-use/ and /in-use/adoptions/ instead.
    @ENTRIES  = dir('src/live').grep(*.Str.ends-with('.md'))
                    .map(*.basename.subst(/ '.md' $ /, ''))
                    .grep({ $_ ne 'README' && $_ ne 'ADOPTIONS' }).sort;
    my @adoptions = parse-adoptions(slurp('src/live/ADOPTIONS.md'));
    die 'no rows parsed out of live/ADOPTIONS.md — has its table changed shape?'
        unless @adoptions;

    # The synced pages and the index table must agree, loudly: a project the
    # table does not know stays off the site (that is the raytracer rule), and
    # that is only safe if it fails the build instead of passing silently.
    die 'raytracer must never reach the site' if 'raytracer' eq any(@PROJECTS);
    my @files = dir('src/showcase').grep(*.Str.ends-with('.md'))
                    .map(*.basename.subst(/ '.md' $ /, ''))
                    .grep(* ne 'README').sort;
    for @files -> $f {
        die "$f has a synced README but no row in showcase/README.md's table (and no extras entry)"
            unless $f eq any(@PROJECTS);
    }
    for @PROJECTS -> $p {
        die "$p is in the index table but src/showcase/$p.md is missing — run ./sync.sh"
            unless "src/showcase/$p.md".IO.e;
    }

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');
    mkdir('out/showcase');
    mkdir('out/live');
    mkdir('out/in-use');
    mkdir('out/in-use/adoptions');

    for @PROJECTS -> $slug {
        mkdir("out/showcase/$slug");
        spurt("out/showcase/$slug/index.html", project-page($slug));
    }
    spurt('out/showcase/index.html', index-page(@projects));

    for @ENTRIES -> $slug {
        mkdir("out/live/$slug");
        spurt("out/live/$slug/index.html", live-page($slug));
    }
    spurt('out/live/index.html', live-index());

    spurt('out/in-use/index.html', inuse-page(@adoptions, @PROJECTS.elems));
    spurt('out/in-use/adoptions/index.html', adoptions-page());

    say "built {@PROJECTS.elems} showcase page(s) + {@ENTRIES.elems} live page(s)"
        ~ " + 2 indexes + the /in-use/ hub ({@adoptions.elems} adoptions) -> out/";
}
