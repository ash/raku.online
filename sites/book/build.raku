# build.raku — Raku++ Internals at raku.online/book, from the Markdown in
# rakupp/docs/book/ch.
#
#   rakupp build.raku [--clean]
#
# The chapters are synced in by ./sync.sh; this turns them into pages wearing
# the site's shared theme, and copies the PDF across for download. Like the FAQ
# generator next door it handles the Markdown the source actually uses —
# headings, fenced code, tables, lists (including items that carry their own
# code block), blockquotes, and inline emphasis/code/links — and nothing else,
# on purpose.
#
# Two things it does that the FAQ does not:
#
#   * parts. A chapter file may open with a raw `\part{…}` line (or `\appendix`),
#     which is LaTeX for the PDF and grouping for the contents page here.
#   * cross-references. The prose says "Chapter 18" constantly, so a reference
#     to a chapter number becomes a link to that chapter.
#
# Code is rendered static rather than as runnable editors: these are C++
# excerpts from the compiler's own source, not Raku a reader can execute.

my %SITE;
my $BASE = '';
my @CHAPTERS;          # every chapter, in order
my %BY-NUMBER;         # chapter number => the chapter record

# ---- inline formatting ----------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

sub attr(Str $s --> Str) { esc($s).subst('"', '&quot;', :g) }

# Code spans are protected before anything else runs, so `**` or `_` inside a
# span is never mistaken for emphasis, and a cross-reference is never made
# inside one.
sub inline(Str $text --> Str) {
    my @spans;
    my $s = $text.subst(/ '`' (<-[`]>+) '`' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);

    $s = esc($s);

    # [text](target)
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ attr(link-target(~$1)) ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    $s = chapter-links($s);

    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code) ~ '</code>');
    }
    $s
}

# "Chapter 18", "Chapters 25 to 27", "Chapters 13 and 15" — one pass, so an
# already-linked reference can never be matched again inside its own anchor.
sub chapter-links(Str $s --> Str) {
    $s.subst(/ ('Chapter' 's'?) ' ' (\d+) [ ' ' ('to' | 'and') ' ' (\d+) ]? /, {
        my $word = ~$0;
        my $a    = (~$1).Int;
        my $join = $2 ?? ~$2 !! '';
        my $b    = $3 ?? (~$3).Int !! 0;
        my $out  = chapter-ref($word ~ ' ' ~ $a, $a);
        $out ~= ' ' ~ $join ~ ' ' ~ chapter-ref(~$b, $b) if $join;
        $out
    }, :g)
}

sub chapter-ref(Str $label, Int $n --> Str) {
    my $c = %BY-NUMBER{$n};
    return $label unless $c;
    '<a href="' ~ $BASE ~ '/' ~ $c<slug> ~ '/">' ~ $label ~ '</a>'
}

sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#') || $t.starts-with('/');
    $t
}

sub slugify(Str $s --> Str) {
    my $t = $s.lc;
    $t = $t.subst(/ <-[a..z0..9]>+ /, '-', :g);
    $t.subst(/ ^ '-' /, '').subst(/ '-' $ /, '')
}

# ---- block formatting -----------------------------------------------------

# Rendered headings are collected here so a chapter page can carry its own
# contents list; the caller resets it before each chapter.
my @HEADINGS;

sub render(Str $md --> Str) {
    my @out;
    my @lines = $md.lines;
    my $i = 0;

    while $i < @lines.elems {
        my $line = @lines[$i];

        # raw LaTeX the PDF needs and the web does not
        if $line.starts-with('\\part{') || $line.trim eq '\\appendix' {
            $i++; next;
        }

        # fenced code — copied through verbatim, only escaped
        if $line.starts-with('```') {
            my $lang = $line.substr(3).trim;
            my @code;
            $i++;
            while $i < @lines.elems && !@lines[$i].starts-with('```') {
                @code.push(@lines[$i]);
                $i++;
            }
            $i++;
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

        # blockquote
        if $line.starts-with('> ') || $line.trim eq '>' {
            my @quoted;
            while $i < @lines.elems
                  && (@lines[$i].starts-with('> ') || @lines[$i].trim eq '>') {
                @quoted.push(@lines[$i].subst(/ ^ '>' ' '? /, ''));
                $i++;
            }
            @out.push('<blockquote class="note">' ~ render(@quoted.join("\n"))
                      ~ '</blockquote>');
            next;
        }

        if $line.starts-with('### ') {
            @out.push('<h3>' ~ inline($line.substr(4).trim) ~ '</h3>');
            $i++; next;
        }
        if $line.starts-with('## ') {
            my $t  = $line.substr(3).subst(' {-}', '').trim;
            my $id = slugify($t);
            @HEADINGS.push({ id => $id, text => $t });
            @out.push('<h2 id="' ~ attr($id) ~ '">' ~ inline($t) ~ '</h2>');
            $i++; next;
        }
        if $line.starts-with('# ') { $i++; next; }   # the title, done by the caller

        # lists — an item runs to the next marker at column 0, and may carry
        # indented continuation lines and its own fenced code block
        if $line ~~ / ^ '- ' / || $line ~~ / ^ \d+ '. ' / {
            my $ordered = so $line ~~ / ^ \d+ '. ' /;
            my @items;
            while $i < @lines.elems
                  && (@lines[$i] ~~ / ^ '- ' / || @lines[$i] ~~ / ^ \d+ '. ' /) {
                my @body = @lines[$i].subst(/ ^ ('- ' | \d+ '. ') /, '');
                $i++;
                # continuation: indented lines, and blank lines that are
                # followed by one
                while $i < @lines.elems {
                    if @lines[$i].starts-with('  ') {
                        @body.push(@lines[$i].substr(2));
                        $i++;
                    } elsif @lines[$i].trim eq ''
                            && $i + 1 < @lines.elems
                            && @lines[$i + 1].starts-with('  ') {
                        @body.push('');
                        $i++;
                    } else {
                        last;
                    }
                }
                @items.push('<li>' ~ item-html(@body.join("\n")) ~ '</li>');

                # A blank line between items is still the same list. Without
                # this, an item that ends in a code block starts a second <ul>
                # for everything after it.
                if $i < @lines.elems && @lines[$i].trim eq ''
                   && $i + 1 < @lines.elems
                   && (@lines[$i + 1] ~~ / ^ '- ' / || @lines[$i + 1] ~~ / ^ \d+ '. ' /) {
                    $i++;
                }
            }
            @out.push(($ordered ?? '<ol>' !! '<ul>') ~ @items.join ~ ($ordered ?? '</ol>' !! '</ul>'));
            next;
        }

        if $line.trim eq '' { $i++; next; }

        # paragraph — runs until a blank line or the start of another block
        my @para;
        while $i < @lines.elems && @lines[$i].trim ne ''
              && !@lines[$i].starts-with('```') && !@lines[$i].starts-with('#')
              && !@lines[$i].starts-with('|') && !@lines[$i].starts-with('>')
              && !@lines[$i].starts-with('\\')
              && !(@lines[$i] ~~ / ^ '- ' /) && !(@lines[$i] ~~ / ^ \d+ '. ' /) {
            @para.push(@lines[$i]);
            $i++;
        }
        @out.push('<p>' ~ inline(@para.join(' ')) ~ '</p>') if @para;
    }
    @out.join("\n")
}

# A list item is rendered as a block so it can hold a code fence, then unwrapped
# when it turned out to be a single paragraph — which is nearly always.
sub item-html(Str $text --> Str) {
    my $html = render($text);
    if $html.starts-with('<p>') && $html.ends-with('</p>')
       && $html.substr(3, $html.chars - 7).index('<p>') === Nil {
        return $html.substr(3, $html.chars - 7);
    }
    $html
}

# `\|` inside a cell is an escaped pipe, not a column separator.
sub cells(Str $row) {
    my $r = $row.subst('\\|', "\x[1]", :g);
    $r = $r.subst(/ ^ '|' /, '').subst(/ '|' $ /, '');
    $r.split('|').map({ .trim.subst("\x[1]", '|', :g) })
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
    my $t    = ($index ?? $title !! $title ~ ' — ' ~ %SITE<title>).subst('`', '', :g);
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($t)}</title>
    <script>window.__SITE_BASE='{$BASE}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/book.css">
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
    <div class="content book">
    { $index ?? '' !! '<p class="crumb"><a href="' ~ $BASE ~ '/">← Contents</a></p>' }
    $body
    <footer>
    <span>The book is written in the <a href="$repo">rakupp</a> repository, under <code>docs/book</code>, and built from the same sources as the PDF.</span>
    <span><a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    </body>
    </html>
    HTML
}

# ---- reading a chapter ----------------------------------------------------

sub title-of(Str $md --> Str) {
    for $md.lines -> $l {
        return $l.substr(2).subst(' {-}', '').trim if $l.starts-with('# ');
    }
    'Untitled'
}

sub part-of(Str $md --> Str) {
    for $md.lines -> $l {
        return $l.substr(6).subst(/ '}' $ /, '').trim if $l.starts-with('\\part{');
        return 'Appendices' if $l.trim eq '\\appendix';
        last if $l.starts-with('# ');
    }
    ''
}

# 00 is front matter, 01..89 are numbered chapters, 90+ are appendices.
sub label-of(Int $prefix --> Str) {
    return ''                                             if $prefix == 0;
    return 'Appendix ' ~ chr(65 + $prefix - 90)           if $prefix >= 90;
    'Chapter ' ~ $prefix
}

# ---- build ----------------------------------------------------------------

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my @files = dir('src/pages').grep({ .IO.f && .Str.ends-with('.md') })
                                .map(*.IO.basename).sort;
    die 'no chapters in src/pages — run ./sync.sh first' unless @files;

    # Pass one: read everything, so a cross-reference can point at any chapter
    # before the first page is rendered.
    my $part = '';
    for @files -> $f {
        my $md     = slurp("src/pages/$f");
        my $prefix = $f.substr(0, 2).Int;
        my $slug   = $f.subst(/ ^ \d+ '-' /, '').subst(/ '.md' $ /, '');
        my $p      = part-of($md);
        $part = $p if $p;
        my %c =
            slug   => $slug,
            file   => $f,
            md     => $md,
            title  => title-of($md),
            label  => label-of($prefix),
            number => ($prefix > 0 && $prefix < 90) ?? $prefix !! 0,
            part   => $part;
        @CHAPTERS.push(%c);
        %BY-NUMBER{%c<number>} = %c if %c<number>;
    }

    # Pass two: the pages.
    for @CHAPTERS.kv -> $idx, %c {
        @HEADINGS = ();
        my $body = render(%c<md>);

        my $head = %c<label>
            ?? '<p class="ch-label">' ~ esc(%c<label>) ~ '</p>'
            !! '';
        my $toc = @HEADINGS.elems >= 3
            ?? '<nav class="ch-toc"><p>On this page</p><ul>'
               ~ @HEADINGS.map({
                     '<li><a href="#' ~ attr(.<id>) ~ '">' ~ inline(.<text>) ~ '</a></li>'
                 }).join
               ~ '</ul></nav>'
            !! '';

        my @nav;
        if $idx > 0 {
            my %p = @CHAPTERS[$idx - 1];
            @nav.push('<a class="prev" href="' ~ $BASE ~ '/' ~ %p<slug>
                      ~ '/"><span>Previous</span>' ~ inline(%p<title>) ~ '</a>');
        }
        if $idx < @CHAPTERS.end {
            my %n = @CHAPTERS[$idx + 1];
            @nav.push('<a class="next" href="' ~ $BASE ~ '/' ~ %n<slug>
                      ~ '/"><span>Next</span>' ~ inline(%n<title>) ~ '</a>');
        }
        my $nav = '<nav class="ch-nav">' ~ @nav.join ~ '</nav>';

        mkdir("out/{%c<slug>}");
        spurt("out/{%c<slug>}/index.html",
              page(%c<title>,
                   $head ~ '<h1>' ~ inline(%c<title>) ~ '</h1>' ~ $toc ~ "\n" ~ $body ~ $nav));
    }

    # Pass three: the contents page.
    my @toc;
    my $seen = '';
    for @CHAPTERS -> %c {
        if %c<part> ne $seen {
            @toc.push('</ol>') if $seen;
            @toc.push('<h2 class="part">' ~ esc(%c<part>) ~ '</h2><ol class="chapters">');
            $seen = %c<part>;
        } elsif !$seen && !@toc {
            @toc.push('<ol class="chapters">');
            $seen = ' ';
        }
        @toc.push('<ol class="chapters">') unless @toc;
        my $blurb = %SITE<blurbs>{%c<slug>} // '';
        @toc.push('<li><a href="' ~ $BASE ~ '/' ~ %c<slug> ~ '/">'
                  ~ (%c<label> ?? '<span class="n">' ~ esc(%c<label>) ~ '</span>' !! '')
                  ~ '<span class="t">' ~ inline(%c<title>) ~ '</span></a>'
                  ~ ($blurb ?? '<span class="b">' ~ esc($blurb) ~ '</span>' !! '')
                  ~ '</li>');
    }
    @toc.push('</ol>');

    my $pdf = %SITE<pdf>;
    my $dl  = "src/$pdf".IO.e
        ?? '<p class="dl"><a class="btn-start" href="' ~ $BASE ~ '/' ~ $pdf
           ~ '">Download the PDF</a> <span class="dl-note">'
           ~ esc(%SITE<pdf-note> // '') ~ ' · '
           ~ (("src/$pdf".IO.s / 1024 / 1024) * 10).round / 10 ~ ' MB</span></p>'
        !! '';

    spurt('out/index.html',
          page(%SITE<title>, :index,
               '<h1>' ~ esc(%SITE<title>) ~ '</h1>'
               ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
               ~ $dl
               ~ '<div class="book-toc">' ~ @toc.join ~ '</div>'));

    if "src/$pdf".IO.e {
        run('cp', "src/$pdf", "out/$pdf");
    } else {
        note "warning: src/$pdf is missing — the download link is omitted";
    }

    say "built {@CHAPTERS.elems} chapter page(s) + contents -> out/";
}
