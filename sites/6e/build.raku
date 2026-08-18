# build.raku — the 6.e page at raku.online/6e, from the Markdown in
# rakupp/docs/guide/LANGUAGE-6E.md.
#
#   rakupp build.raku [--clean]
#
# The article is synced in by ./sync.sh; this turns it into one page wearing the
# site's shared theme. It handles the Markdown the article actually uses —
# headings, fenced code, tables, lists (one level of nesting), block quotes,
# rules, and inline emphasis/code/links — and nothing else, on purpose, for the
# same reason the FAQ generator does: a general Markdown engine here would be a
# lot of code standing between a typo and a visible page.
#
# Code blocks are rendered static rather than as runnable editors. Nearly every
# snippet needs `use v6.e.PREVIEW` and is shown next to its 6.d output, so a Run
# button would answer a question the page is not asking.

my %SITE;
my $BASE = '';
my @TOC;      # [level, anchor, text] for the contents list

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

    # [text](target) — .md targets are rewritten to where the file actually is.
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ link-target(~$1) ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    # put the code spans back, escaped now that no pattern can see into them.
    # An escaped pipe only exists to survive a Markdown table cell; the reader
    # wants the pipe.
    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code.subst('\\|', '|', :g)) ~ '</code>');
    }
    $s
}

sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    # docs/… or ../SOMETHING.md — a rakupp file that does not live on this site
    return %SITE<docs-base> ~ $t.subst('../', '')   if $t.starts-with('../');
    return %SITE<docs-base> ~ $t.subst('docs/', '') if $t.starts-with('docs/');
    $t
}

# ---- headings -------------------------------------------------------------

sub anchor(Str $text --> Str) {
    my $a = $text.lc.subst(/ <-[a..z0..9]>+ /, '-', :g);
    $a.subst(/ ^ '-' /, '').subst(/ '-' $ /, '')
}

sub heading(Int $level, Str $text --> Str) {
    my $id = anchor($text);
    @TOC.push([$level, $id, $text]) if $level <= 2;
    "<h$level id=\"$id\">" ~ inline($text) ~ "</h$level>"
}

# ---- tables ---------------------------------------------------------------

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
    # The comparison tables in this article have no header — the two cells are
    # "6.d" and "6.e" in the rows themselves. An empty header row is noise.
    my $h = @head.grep({ $_ ne '' })
              ?? '<tr>' ~ @head.map({ '<th>' ~ inline($_) ~ '</th>' }).join ~ '</tr>'
              !! '';
    my $b = @body.map(-> $r {
        '<tr>' ~ cells($r).map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>'
    }).join("\n");
    '<div class="tablewrap"><table>' ~ $h ~ $b ~ '</table></div>'
}

# ---- block formatting -----------------------------------------------------

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

        # block quote — the article opens with one, saying what was verified
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

# ---- the page shell -------------------------------------------------------

sub toc-html(--> Str) {
    return '' unless @TOC;
    '<nav class="toc" aria-label="Contents"><ul>'
      ~ @TOC.map(-> @h { '<li><a href="#' ~ @h[1] ~ '">' ~ inline(@h[2]) ~ '</a></li>' }).join
      ~ '</ul></nav>'
}

sub page(Str $title, Str $body --> Str) {
    my $repo = %SITE<repo>;
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <meta name="description" content="Everything the Raku 6.e language revision changes relative to 6.d: new syntax, subs and methods, the behaviour changes, the new errors — each with both outputs.">
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
    $body
    <footer>
    <span>Every line was run on Rakudo 2026.07 under both revisions and on Raku++; the outputs are those runs, not predictions.</span>
    <span>Written in the <a href="$repo">rakupp</a> repository. <a href="/faq/">FAQ</a> · <a href="/rakupp/">About Raku++</a>.</span>
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
    'Raku 6.e'
}

sub MAIN(Bool :$clean = False) {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my $md    = slurp(%SITE<source>);
    my $title = title-of($md);
    my $body  = render($md);          # fills @TOC on the way through

    spurt('out/index.html',
          page($title,
               '<h1>' ~ esc($title) ~ '</h1>' ~ "\n" ~ toc-html() ~ "\n" ~ $body));

    say "built the 6.e page ({@TOC.elems} sections) -> out/";
}
