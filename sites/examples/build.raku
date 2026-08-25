# build.raku — the example gallery at raku.online/examples, from rakupp/examples.
#
#   rakupp build.raku [--clean]           build out/ from src/
#   rakupp build.raku --capture           re-run every program natively and
#                                         refresh src/outputs/*.txt first
#   rakupp build.raku --capture --oracle=raku
#                                         also run each program under Rakudo and
#                                         fail on any output difference
#   rakupp build.raku --rakupp=PATH       interpreter used for --capture
#
# One page per program: the README's prose about it, the full source in a live
# editor (raku.online/raku.js), and what it actually prints. The outputs are
# captured from the real interpreter and committed under src/outputs/, so an
# ordinary build runs nothing — and a page can never show output the program
# did not produce.
#
# The programs and their README are synced in by ./sync.sh; the README stays
# the source of truth for the order, the categories, and the prose. A program
# that appears in src/programs/ but not in the README table fails the build
# rather than silently missing from the site.

my %SITE;
my $BASE = '';
my $RAKUPP = 'rakupp';   # also the highlighter; MAIN points it at --rakupp

# ---- inline formatting ----------------------------------------------------
# The subset of Markdown the examples README actually uses: code spans, links,
# bold and italics. Same approach as the FAQ generator: code spans are
# protected first, so nothing inside them is ever mistaken for markup.

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}

sub esc-attr(Str $s --> Str) {
    esc($s).subst('"', '&quot;', :g)
}

sub inline(Str $text --> Str) {
    my @spans;
    my $s = $text.subst(/ '`' (<-[`]>+) '`' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);

    $s = esc($s);

    # [text](target) — repo-relative targets are rewritten to GitHub.
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ link-target(~$1) ~ '">' ~ ~$0 ~ '</a>'
    }, :g);

    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code) ~ '</code>');
    }
    $s
}

# A link in the README is written from inside rakupp/examples/, so that is what
# a ../ chain is relative to. Whatever it names lives on GitHub, not here.
sub link-target(Str $t --> Str) {
    return $t if $t.starts-with('http') || $t.starts-with('#');
    my @dirs = 'examples',;
    my $rest = $t;
    while $rest.starts-with('../') {
        $rest = $rest.substr(3);
        @dirs.pop if @dirs;
    }
    %SITE<gh-base> ~ (|@dirs, $rest).join('/')
}

# ---- README parsing --------------------------------------------------------
# Two passes over examples/README.md. The index table gives the order, the
# category shelves, the one-line "what it shows" and the feature focus; the
# `### name.raku` sections give each page its prose.

sub cells(Str $row) {
    $row.subst(/ ^ '|' /, '').subst(/ '|' $ /, '').split('|').map(*.trim)
}

sub parse-readme(Str $md) {
    my @examples;          # ordered hashes: slug what focus category prose
    my %by-slug;
    my $category = '';

    for $md.lines -> $line {
        next unless $line.starts-with('|');
        my @c = cells($line);
        next if @c[0] ~~ / ^ <[-\s:]>* $ /;                  # the separator row
        next if @c[0] eq 'File';                             # the header row
        if @c[0] ~~ / ^ '**' (<-[*]>+) '**' $ / {            # a category row
            $category = ~$0;
            next;
        }
        if @c[0] ~~ / '`' (<-[`]>+) '.raku' '`' / {
            my %e = slug => ~$0, what => @c[1], focus => @c[2],
                    category => $category, prose => [];
            @examples.push(%e);
            %by-slug{~$0} = %e;    # same Hash object: prose pushed later lands in both
        }
    }

    # The prose: everything under `### name.raku` until the next heading.
    my $slug = '';
    for $md.lines -> $line {
        if $line ~~ / ^ '### ' \s* '`' (<-[`]>+) '.raku' '`' / {
            $slug = ~$0;
            next;
        }
        if $line.starts-with('## ') || $line.starts-with('# ') || $line.trim eq '---' {
            $slug = '';
            next;
        }
        %by-slug{$slug}<prose>.push($line) if $slug && (%by-slug{$slug}:exists);
    }
    @examples
}

# The README sections often close with a sample of the output. The page shows
# the real, full output right below, so a trailing fence would say the same
# thing twice — drop it. A fence in mid-prose is part of the writing and stays.
sub drop-trailing-fence(@lines) {
    my @l = @lines;
    @l.pop while @l && @l[@l.end].trim eq '';
    return @l unless @l && @l[@l.end].starts-with('```');
    my $close = @l.end;
    my $open = $close - 1;
    $open-- while $open >= 0 && !@l[$open].starts-with('```');
    return @l if $open < 0;
    @l[0 .. $open - 1]
}

# Paragraphs and fenced code are all the block structure these sections use.
sub prose-html(@lines --> Str) {
    my @out;
    my $i = 0;
    while $i < @lines.elems {
        my $line = @lines[$i];
        if $line.starts-with('```') {
            my @code;
            $i++;
            while $i < @lines.elems && !@lines[$i].starts-with('```') {
                @code.push(@lines[$i]);
                $i++;
            }
            $i++;
            @out.push('<pre class="native-code"><code>' ~ esc(@code.join("\n")) ~ '</code></pre>');
            next;
        }
        if $line.trim eq '' { $i++; next; }
        my @para;
        while $i < @lines.elems && @lines[$i].trim ne '' && !@lines[$i].starts-with('```') {
            @para.push(@lines[$i]);
            $i++;
        }
        @out.push('<p>' ~ inline(@para.join(' ')) ~ '</p>') if @para;
    }
    @out.join("\n")
}

# The engine's own highlighter, for the three programs that are shown static
# rather than as an editor (the editor colours itself). `rakupp --highlight
# --html` emits Pygments class names that base.css already colours — same sub
# as the ecosystem handbook's. A highlighter that fails for any reason falls
# back to escaped plain text: a page with grey code is a small loss, a page
# with no code is not a page.
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
    (~$0).subst(/ ^ '<span></span>' /, '').subst(/ \n+ $ /, '')
}

# ---- capture ---------------------------------------------------------------
# Run every program for real and store what it printed. Committed, so the
# ordinary build never executes anything — and the site never shows output
# that is aspirational rather than actual.

sub strip-ansi(Str $s --> Str) {
    # life.raku homes the cursor before each frame; on a page the frames
    # simply follow each other.
    $s.subst(/ \x[1B] '[' <[0..9;]>* <[A..Za..z]> /, '', :g)
}

sub run-program(Str $bin, Str $slug --> List) {
    my @args = @(%SITE<capture-args>{$slug} // []);
    my $proc = run($bin, "src/programs/$slug.raku", |@args, :out, :err);
    my $out = $proc.out.slurp(:close);
    my $err = $proc.err.slurp(:close);
    ($proc.exitcode, strip-ansi($out), $err)
}

sub capture(@examples, Str $rakupp, Str $oracle) {
    mkdir('src/outputs');
    my $oracle-fail = 0;
    for @examples -> %e {
        my $slug = %e<slug>;
        my ($rc, $out, $err) = run-program($rakupp, $slug);
        if $rc != 0 {
            note "capture: $slug.raku exited $rc under $rakupp";
            note $err if $err;
            exit 1;
        }
        spurt("src/outputs/$slug.txt", $out);
        say "captured $slug ({$out.lines.elems} lines)";

        next unless $oracle;
        next if $slug eq any(@(%SITE<nondeterministic>));
        my ($orc, $oout, $oerr) = run-program($oracle, $slug);
        if $orc != 0 || $oout ne $out {
            $oracle-fail++;
            note "ORACLE MISMATCH: $slug.raku differs under $oracle (exit $orc)";
        }
    }
    if $oracle {
        my $n = @examples.elems - @(%SITE<nondeterministic>).elems;
        say $oracle-fail
            ?? "oracle: $oracle-fail mismatch(es) vs $oracle"
            !! "oracle: all $n deterministic outputs identical under $oracle";
        exit 1 if $oracle-fail;
    }
}

# ---- the page shell --------------------------------------------------------

sub page(Str $title, Str $body, Bool :$editor = False --> Str) {
    my $engine = $editor
        ?? "\n" ~ '<script src="/raku.js?v=00000000"></script>'
        !! '';
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
    <link rel="stylesheet" href="/theme/examples.css">
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
    <span>Every output on this page was printed by the program above it, captured from the real interpreter.</span>
    <span>The programs live in the <a href="{%SITE<gh-dir>}">rakupp</a> repository. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>{$engine}
    </body>
    </html>
    HTML
}

# ---- pages -----------------------------------------------------------------

sub output-html(Str $slug --> Str) {
    my $out = slurp("src/outputs/$slug.txt");
    my @lines = $out.lines;
    my $cap = %SITE<output-cap>{$slug} // 0;
    my $folded = '';
    if $cap && @lines.elems > $cap {
        $folded = '<div class="out-folded">⋯ ' ~ (@lines.elems - $cap)
                ~ ' more lines</div>';
        @lines = @lines[0 .. $cap - 1];
    }
    my $note = $slug eq any(@(%SITE<nondeterministic>))
        ?? '<span class="out-note">from one run — it is random every time</span>'
        !! '';
    '<div class="expected"><span class="expected-label">Output</span>' ~ $note
      ~ '<pre class="output"><code>' ~ esc(@lines.join("\n")) ~ '</code></pre>' ~ $folded ~ '</div>'
}

sub example-page(%e, $prev, $next --> Str) {
    my $slug = %e<slug>;
    my $code = slurp("src/programs/$slug.raku").chomp;
    my @body;

    @body.push('<p class="crumb"><a href="' ~ $BASE ~ '/">← All examples</a></p>');
    @body.push('<h1><code>' ~ $slug ~ '.raku</code></h1>');
    @body.push('<p class="tagline">' ~ inline(%e<what>) ~ '.</p>');
    @body.push(prose-html(drop-trailing-fence(@(%e<prose>))));

    my $gh = %SITE<gh-base> ~ "examples/$slug.raku";
    if %SITE<native-only>{$slug} -> $why {
        # No Run button that is guaranteed to fail: the program needs
        # $why, so it is shown static, with the way to run it for real.
        @body.push('<h2>The program</h2>');
        @body.push('<p class="native-note">This one needs ' ~ $why
            ~ ' — so there is no Run button here. <a href="/install/">Install Raku++</a> and run it from a checkout:</p>');
        @body.push('<pre class="native-code"><code>rakupp examples/' ~ $slug ~ '.raku</code></pre>');
        @body.push('<pre class="native-code src-listing"><code>' ~ highlight($code) ~ '</code></pre>');
        @body.push('<p class="ex-links"><a href="' ~ $gh ~ '">Source on GitHub ↗</a></p>');
    }
    else {
        my $rows = min($code.lines.elems + 1, 24);
        @body.push('<h2>The program</h2>');
        @body.push('<p class="edit-note">Edit it and press Run — it executes in your browser.</p>');
        @body.push('<pre data-raku data-rows="' ~ $rows ~ '">' ~ esc($code) ~ '</pre>');
        @body.push('<p class="ex-links"><a href="/play/?ex=' ~ $slug ~ '">Open in the playground ↗</a>'
            ~ ' <a href="' ~ $gh ~ '">Source on GitHub ↗</a></p>');
    }

    @body.push(output-html($slug));
    @body.push('<p class="focus">Feature focus: ' ~ inline(%e<focus>) ~ '.</p>');

    my @nav;
    @nav.push('<a class="nav-prev" href="' ~ $BASE ~ '/' ~ $prev<slug> ~ '/">← '
        ~ $prev<slug> ~ '.raku</a>') if $prev;
    @nav.push('<a class="nav-next" href="' ~ $BASE ~ '/' ~ $next<slug> ~ '/">'
        ~ $next<slug> ~ '.raku →</a>') if $next;
    @body.push('<nav class="ex-nav">' ~ @nav.join(' ') ~ '</nav>') if @nav;

    page("$slug.raku — {%SITE<title>}", @body.join("\n"),
         editor => !(%SITE<native-only>{$slug}:exists))
}

sub index-page(@examples --> Str) {
    my @body;
    @body.push('<p class="crumb"><a href="/in-use/">← Raku++ in use</a></p>');
    @body.push('<h1>' ~ esc(%SITE<title>) ~ '</h1>');
    @body.push('<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>');
    @body.push('<p>Each program is complete and self-contained — no arguments, no
        setup, no network. Twenty-one of them run right on their page, in your
        browser, on Raku++ compiled to WebAssembly; the three that need real
        threads or sockets are shown with the output they print natively.
        For snippet-sized pieces of the language rather than whole programs,
        the <a href="/tour/">tour</a> is the place; for mid-size projects,
        the <a href="/showcase/">showcase</a>.</p>');

    my $category = '';
    for @examples -> %e {
        if %e<category> ne $category {
            $category = %e<category>;
            my $id = $category.lc.subst(/ <-[a..z0..9]>+ /, '-', :g)
                              .subst(/ ^ '-' /, '').subst(/ '-' $ /, '');
            @body.push("<h2 id=\"$id\">" ~ esc($category) ~ '</h2>');
        }
        my $badge = %SITE<native-only>{%e<slug>}:exists
            ?? ' <span class="badge-native">native</span>'
            !! '';
        @body.push('<p class="ex-entry"><a href="' ~ $BASE ~ '/' ~ %e<slug> ~ '/"><code>'
            ~ %e<slug> ~ '.raku</code></a>' ~ $badge
            ~ '<br><span class="ex-blurb">' ~ inline(%e<what>) ~ ' — ' ~ inline(%e<focus>) ~ '.</span></p>');
    }
    page(%SITE<title>, @body.join("\n"))
}

# ---- build -----------------------------------------------------------------

sub MAIN(Bool :$clean = False, Bool :$capture = False,
         Str :$rakupp = 'rakupp', Str :$oracle = '') {
    $RAKUPP = $rakupp;
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base> // '';

    my @examples = parse-readme(slurp('src/programs/README.md'));

    # Every synced program must be in the README table, and the other way
    # around — a new example that is not written up, or a table row whose file
    # is gone, is a build error, not a page quietly missing.
    my @table = @examples.map({ $_<slug> });
    my @files = dir('src/programs').grep(*.Str.ends-with('.raku'))
                                   .map(*.basename.subst(/ '.raku' $ /, '')).sort;
    for @files -> $f {
        die "$f.raku is in src/programs but not in the README table" unless $f eq any(@table);
    }
    for @table -> $t {
        die "$t.raku is in the README table but not in src/programs" unless $t eq any(@files);
    }

    capture(@examples, $rakupp, $oracle) if $capture;

    for @table -> $t {
        die "no captured output for $t.raku — run: rakupp build.raku --capture"
            unless "src/outputs/$t.txt".IO.e;
    }

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    for @examples.kv -> $i, %e {
        my $prev = $i > 0                 ?? @examples[$i - 1] !! Nil;
        my $next = $i < @examples.end     ?? @examples[$i + 1] !! Nil;
        mkdir("out/{%e<slug>}");
        spurt("out/{%e<slug>}/index.html", example-page(%e, $prev, $next));
    }
    spurt('out/index.html', index-page(@examples));

    say "built {@examples.elems} example page(s) + index -> out/";
}
