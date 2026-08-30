# build.raku — the ecosystem handbook at raku.online/modules.
#
#   rakupp build.raku [--clean]
#   rakupp build.raku --verify [--oracle=raku]   run every example, check its output
#   rakupp build.raku --probe                    re-check what the pages CLAIM
#
# One page per distribution from raku.land that Raku++ can parse, install, test
# and run. A page is a Markdown file under src/modules/ whose frontmatter records
# what was measured — the version, the dependency, the state of the
# distribution's own test suite — and whose body is prose around examples.
#
# The examples are static, not the runnable editors the tour uses: a browser
# sandbox has no module store, so a Run button here would be a promise the page
# cannot keep. They are highlighted by `rakupp --highlight`, the engine's own
# highlighter, and carry a Copy button from theme/copy.js.
#
# Three example fences:
#   ```raku          an example. A following ```output fence is its EXACT output,
#                    and --verify runs the example to prove it.
#   ```raku sample   an example whose output is random. A following ```output is
#                    labelled as one run and never compared; --verify still runs
#                    the program, so a sample that has stopped working is caught.
#   ```raku fragment an EXCERPT: highlighted, written to no file, never run.
#                    For code that cannot stand alone — the two lines showing
#                    what a module gets wrong, a quote from its source.
#   ```sh            a shell transcript. `$ ` marks a command; copy.js hands the
#                    clipboard the commands without the echoed output.

constant RAKUPP-DEFAULT = 'rakupp';

my %SITE;
my $BASE   = '';
my $RAKUPP = RAKUPP-DEFAULT;

# ---- small text helpers ---------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}
sub esc-attr(Str $s --> Str) { esc($s).subst('"', '&quot;', :g) }

sub anchor(Str $text is copy --> Str) {
    $text = $text.subst(/ '<' <-[>]>* '>' /, '', :g).lc;
    $text = $text.subst(/ <-[a..z0..9\s\-]> /, '', :g).subst(/ \s+ /, '-', :g);
    $text.subst(/ ^ '-'+ /, '').subst(/ '-'+ $ /, '')
}

# Inline formatting: code spans are lifted out first, so `**` or a bracket
# inside one is never read as markup, and put back escaped at the end.
sub inline(Str $text --> Str) {
    my @spans;
    my $s = $text.subst(/ '`' (<-[`]>+) '`' /, {
        @spans.push(~$0);
        "\x[0]{ @spans.end }\x[0]"
    }, :g);

    $s = esc($s);
    $s = $s.subst(/ '[' (<-[\]]>+) ']' '(' (<-[)]>+) ')' /, {
        '<a href="' ~ esc-attr(~$1) ~ '">' ~ ~$0 ~ '</a>'
    }, :g);
    $s = $s.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ ~$0 ~ '</strong>' }, :g);
    $s = $s.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ ~$0 ~ '</em>' }, :g);

    for @spans.kv -> $i, $code {
        $s = $s.subst("\x[0]$i\x[0]", '<code>' ~ esc($code) ~ '</code>');
    }
    $s
}

# ---- the engine's own highlighter -----------------------------------------

# `rakupp --highlight --html` emits Pygments class names inside a
# <div class="highlight"><pre>…</pre></div> wrapper; base.css colours those
# names, so the handbook's static examples wear the playground's palette. A
# highlighter that fails for any reason falls back to escaped plain text: a
# page with grey code is a small loss, a page with no code is not a page.
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

# A shell transcript is not Raku and is not coloured as if it were: only the
# prompt is stepped back, which is also the marker copy.js reads to copy the
# commands alone.
sub shell-html(Str $code --> Str) {
    $code.lines.map(-> $l {
        $l.starts-with('$ ')
            ?? '<span class="sh-p">$ </span>' ~ esc($l.substr(2))
            !! esc($l)
    }).join("\n")
}

# The Copy button is injected by theme/copy.js; a link to the example's FILE
# sits beside it, because copying is not the only thing a reader wants to do
# with a working program — the repository is there to be cloned.
sub code-block(Str $inner, Str :$src, Str :$name --> Str) {
    my $link = $src
        ?? '<a class="ex-src" href="' ~ esc-attr($src) ~ '" title="'
             ~ esc-attr("This example as a file: $name") ~ '">File</a>'
        !! '';
    '<div class="native-ex">' ~ $link
      ~ '<pre class="native-code"><code>' ~ $inner ~ '</code></pre></div>'
}

sub output-block(Str $text, Str $label --> Str) {
    '<div class="expected"><span class="expected-label">' ~ esc($label) ~ '</span>'
      ~ '<pre class="output"><code>' ~ esc($text) ~ '</code></pre></div>'
}

# Where an example's file lives on GitHub, and where it lives on disk.
sub example-url(Str $slug, Str $file --> Str) { %SITE<examples-url> ~ "/$slug/$file" }
sub example-dir(Str $slug --> Str)            { %SITE<examples-dir> ~ "/$slug" }

# ---- the document model ---------------------------------------------------

class Example {
    has Str  $.code;
    has      $.expected;      # Str, or Str type object when none was declared
    has Bool $.sample;        # output varies run to run: run it, never compare it
    has Int  $.line;
    has Str  $.file;          # examples/<module>/NN-name.raku — what a reader clones
    has Str  $.section;       # the heading it sits under, for the file's own header
    has Str  $.anchor;        # …and the link back to that heading
}

class Module {
    has Str $.slug;
    has %.meta;
    has Str $.body;
    has Str $.path;
    has     @.examples is rw;
}

sub parse-frontmatter(Str $text, Str $path) {
    die "$path: missing '---' frontmatter block" unless $text.starts-with('---');
    my $end = $text.index("\n---", 3);
    die "$path: unterminated frontmatter block" unless $end.defined;
    my $head = $text.substr(3, $end - 3).trim("\n");
    my $body = $text.substr($end + 4).subst(/ ^ \n+ /, '');
    my %meta;
    my $last = '';
    for $head.lines -> $raw {
        my $line = $raw.trim;
        next unless $line && !$line.starts-with('#');
        # An indented line continues the value above it, so a summary can be
        # written as a sentence over two lines instead of one long one.
        if $raw.starts-with(' ') && $last {
            %meta{$last} ~= ' ' ~ $line;
            next;
        }
        die "$path: bad frontmatter line: $line" unless $line.contains(':');
        my ($k, $v) = $line.split(':', 2);
        $last = $k.trim;
        %meta{$last} = $v.trim;
    }
    $(%meta), $body
}

sub load-module(Str $path --> Module) {
    my ($meta, $body) = parse-frontmatter(slurp($path), $path);
    for <name version summary status> -> $k {
        die "$path: frontmatter needs a '$k'" unless $meta{$k};
    }
    Module.new(
        slug => $path.IO.basename.subst(/ '.md' $ /, ''),
        meta => %$meta,
        body => $body,
        path => $path,
        examples => [],
    )
}

# ---- the renderer ---------------------------------------------------------

class Renderer {
    has @.lines;
    has $.mod;
    has @!out;
    has Int $!i = 0;
    has Str $!section = '';      # the heading the examples below it belong to
    has Str $!anchor  = '';

    method render(--> Str) {
        while $!i < @.lines.elems {
            my $line = @.lines[$!i];
            if    $line !~~ / \S /                        { $!i++ }
            elsif $line.starts-with('```')                { self!fence }
            elsif $line ~~ / ^ '#'+ \s /                  { self!heading($line) }
            elsif $line ~~ / ^ \s* <[\-*]> ' ' /          { self!ulist }
            elsif $line ~~ / ^ \s* \d+ '.' ' ' /          { self!olist }
            elsif $line.starts-with('> ')                 { self!quote }
            elsif $line.starts-with('|') && self!table-ahead { self!table }
            elsif $line.trim eq '---'                     { @!out.push('<hr>'); $!i++ }
            else                                          { self!paragraph }
        }
        @!out.join("\n")
    }

    method !starter(Str $line --> Bool) {
        so  $line !~~ / \S /
        ||  $line.starts-with('```')
        ||  $line ~~ / ^ '#'+ \s /
        ||  $line.starts-with('> ')
        ||  $line.starts-with('|')
        ||  $line.trim eq '---'
        ||  $line ~~ / ^ \s* <[\-*]> ' ' /
        ||  $line ~~ / ^ \s* \d+ '.' ' ' /
    }

    method !heading(Str $line) {
        my $hashes = ($line ~~ / ^ ('#'+) /)[0].chars;
        my $text   = $line.substr($hashes).trim;
        my $id     = anchor($text);
        if $hashes == 2 { $!section = $text; $!anchor = $id }
        @!out.push("<h$hashes id=\"$id\">" ~ inline($text)
                   ~ " <a class=\"anchor\" href=\"#$id\" aria-label=\"link\">#</a></h$hashes>");
        $!i++;
    }

    method !paragraph {
        my @buf;
        while $!i < @.lines.elems && !self!starter(@.lines[$!i]) {
            @buf.push(@.lines[$!i].trim);
            $!i++;
        }
        @!out.push('<p>' ~ inline(@buf.join(' ')) ~ '</p>') if @buf;
    }

    method !item-body(Str $first) {
        my $item = $first;
        while $!i < @.lines.elems && !self!starter(@.lines[$!i]) {
            $item ~= ' ' ~ @.lines[$!i].trim;
            $!i++;
        }
        inline($item)
    }

    method !ulist {
        my @items;
        while $!i < @.lines.elems && @.lines[$!i] ~~ / ^ \s* <[\-*]> ' ' / {
            my $first = @.lines[$!i].trim.substr(2).trim;
            $!i++;
            @items.push(self!item-body($first));
        }
        # Concatenation, not interpolation: "$_</li>" parses the `<li>` that
        # follows the variable as a HASH SUBSCRIPT, and every item came out empty.
        @!out.push('<ul>' ~ @items.map({ '<li>' ~ $_ ~ '</li>' }).join ~ '</ul>');
    }

    method !olist {
        my @items;
        while $!i < @.lines.elems && @.lines[$!i] ~~ / ^ \s* \d+ '.' ' ' / {
            my $first = @.lines[$!i].subst(/ ^ \s* \d+ '.' \s /, '').trim;
            $!i++;
            @items.push(self!item-body($first));
        }
        @!out.push('<ol>' ~ @items.map({ '<li>' ~ $_ ~ '</li>' }).join ~ '</ol>');
    }

    method !quote {
        my @buf;
        while $!i < @.lines.elems && @.lines[$!i].starts-with('> ') {
            @buf.push(@.lines[$!i].substr(2));
            $!i++;
        }
        @!out.push('<blockquote class="note"><p>' ~ inline(@buf.join(' ')) ~ '</p></blockquote>');
    }

    method !table-ahead(--> Bool) {
        so $!i + 1 < @.lines.elems && @.lines[$!i + 1] ~~ / ^ '|' <[\-\|\s:]>+ $ /
    }

    method !cells(Str $row is copy) {
        $row = $row.trim;
        $row = $row.substr(1) if $row.starts-with('|');
        $row = $row.substr(0, $row.chars - 1) if $row.ends-with('|');
        $row.split('|').map(*.trim)
    }

    method !table {
        my @header = self!cells(@.lines[$!i]);
        $!i += 2;
        my @rows;
        while $!i < @.lines.elems && @.lines[$!i].starts-with('|') {
            @rows.push([self!cells(@.lines[$!i])]);
            $!i++;
        }
        my $h = @header.map({ '<th>' ~ inline($_) ~ '</th>' }).join;
        my $b = @rows.map(-> @r { '<tr>' ~ @r.map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>' }).join;
        @!out.push('<div class="tablewrap"><table><thead><tr>' ~ $h ~ '</tr></thead><tbody>'
                   ~ $b ~ '</tbody></table></div>');
    }

    method !fence {
        my $info  = @.lines[$!i].substr(3).trim;
        my $start = $!i + 1;
        $!i++;
        my @buf;
        while $!i < @.lines.elems && !@.lines[$!i].starts-with('```') {
            @buf.push(@.lines[$!i]);
            $!i++;
        }
        $!i++;   # the closing fence
        my $code = @buf.join("\n");
        my @info = $info.words;
        my $lang = @info ?? @info[0] !! '';
        my $sample = so @info.first('sample');
        # `raku fragment` — highlighted like an example, never RUN. Some things
        # are only sayable as a fragment: the two lines that show what a module
        # does WRONG, an excerpt of somebody else's source. Without this they
        # had to be written as an unhighlighted plain fence, which made the
        # page look like the code did not matter.
        my $fragment = so @info.first('fragment');
        # `name="quantiles"` names the file this example is written to; without
        # one it takes the name of the section it sits under, which is right
        # often enough and never leaves a file unnamed.
        my $named = '';
        if $info ~~ / 'name="' (<-["]>+) '"' / { $named = ~$0 }

        if $lang eq 'raku' && $fragment {
            @!out.push(code-block(highlight($code)));
        }
        elsif $lang eq 'raku' {
            my $expected = self!peek-output;
            my $n    = $.mod.examples.elems + 1;
            my $slug = $named || anchor($!section) || 'example';
            my $file = sprintf('%02d-%s.raku', $n, $slug);
            $.mod.examples.push(Example.new(
                code => $code, expected => $expected, sample => $sample, line => $start,
                file => $file, section => $!section, anchor => $!anchor));
            @!out.push(code-block(highlight($code),
                                  src  => example-url($.mod.slug, $file),
                                  name => $file));
            @!out.push(output-block($expected, $sample ?? 'One run' !! 'Output'))
                if $expected.defined;
        }
        elsif $lang eq 'sh' {
            @!out.push(code-block(shell-html($code)));
        }
        elsif $lang eq 'output' | 'text' {
            @!out.push('<pre class="output"><code>' ~ esc($code) ~ '</code></pre>');
        }
        else {
            @!out.push(code-block(esc($code)));
        }
    }

    # An ```output fence right after an example is that example's output.
    method !peek-output {
        my $j = $!i;
        $j++ while $j < @.lines.elems && @.lines[$j] !~~ / \S /;
        return Str unless $j < @.lines.elems && @.lines[$j].starts-with('```');
        my $lang = @.lines[$j].substr(3).trim.words[0] // '';
        return Str unless $lang eq 'output' | 'text';
        my $k = $j + 1;
        my @buf;
        while $k < @.lines.elems && !@.lines[$k].starts-with('```') {
            @buf.push(@.lines[$k]);
            $k++;
        }
        $!i = $k + 1;
        @buf.join("\n")
    }
}

# ---- the page shell -------------------------------------------------------

# A string inside a JSON-LD block; the summaries are prose, so quotes and
# backslashes are all that needs escaping. `</script` cannot appear either —
# '<' is folded to <, which JSON permits and browsers cannot misread.
sub json-str(Str $s --> Str) {
    '"' ~ $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst('<', '\\u003c', :g).trans("\n" => ' ') ~ '"'
}

# What a page tells a crawler about itself: one description (the summary the
# reader sees is also the one a search result shows), one canonical URL so
# the page cannot compete with itself, and the social-card duplicates of
# both. $path is the page's path under the site base ('/tap/', '/'); $jsonld
# is an optional ready-made structured-data block from the caller.
sub seo-head(Str $title, Str :$desc = '', Str :$path, Str :$jsonld = '' --> Str) {
    my $d = $desc || %SITE<tagline>;
    my $canonical = %SITE<site-url> ~ $BASE ~ $path;
    my @h =
        '<meta name="description" content="' ~ esc-attr($d) ~ '">',
        '<link rel="canonical" href="' ~ esc-attr($canonical) ~ '">',
        '<meta property="og:site_name" content="raku.online">',
        '<meta property="og:type" content="' ~ ($path eq '/' ?? 'website' !! 'article') ~ '">',
        '<meta property="og:title" content="' ~ esc-attr($title) ~ '">',
        '<meta property="og:description" content="' ~ esc-attr($d) ~ '">',
        '<meta property="og:url" content="' ~ esc-attr($canonical) ~ '">',
        '<meta name="twitter:card" content="summary">';
    @h.push('<script type="application/ld+json">' ~ $jsonld ~ '</script>') if $jsonld;
    @h.join("\n")
}

sub page(Str $title, Str $body, :$index = False, Str :$desc = '', Str :$path = '/',
         Str :$jsonld = '' --> Str) {
    my $repo   = esc-attr(%SITE<repo>);
    my $engine = esc(%SITE<engine>);
    my $oracle = esc(%SITE<oracle>);
    my $seo    = seo-head($title, :$desc, :$path, :$jsonld);
    qq:to/HTML/;
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    $seo
    <script>window.__SITE_BASE='{$BASE}';</script>
    <script src="/theme/boot.js"></script>
    <link rel="stylesheet" href="/theme/base.css">
    <link rel="stylesheet" href="/theme/shell.css">
    <link rel="stylesheet" href="/theme/eco.css">
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
    { $index ?? '' !! '<p class="crumb"><a href="' ~ $BASE ~ '/">← All modules</a></p>' }
    $body
    <footer>
    <span>Every example on this site is run under $engine and $oracle before the page ships; where the two differ, the page says so.</span>
    <span>Written in the <a href="$repo">rakupp</a> repository. <a href="/rakupp/">About Raku++</a>.</span>
    </footer>
    </div>
    </main>
    <script src="/theme/shell.js" defer></script>
    <script src="/theme/copy.js" defer></script>
    </body>
    </html>
    HTML
}

# ---- the facts panel ------------------------------------------------------

# What a status word means on the index and at the top of a page. The badge
# classes are base.css's, shared with the conformance tables.
my %STATUS =
    full      => ['st-full', 'Works',      'installs, its own suite passes, and every example here runs'],
    partial   => ['st-part', 'Partial',    'installs and runs, with the gaps this page names'],
    divergent => ['st-div',  'Divergent',  'runs, but answers differently than under Rakudo'],
    ;

sub status-badge(Str $status --> Str) {
    my @s = %STATUS{$status} // ['st-ni', $status.tc, ''];
    '<span class="status ' ~ @s[0] ~ '">' ~ esc(@s[1]) ~ '</span>'
}

# The measured facts, as a definition list rather than prose: a reader deciding
# whether to use a module reads these five lines and nothing else.
sub facts-html(%m --> Str) {
    my @rows;
    sub row(Str $k, Str $v) { @rows.push('<div class="fact"><dt>' ~ esc($k) ~ '</dt><dd>' ~ $v ~ '</dd></div>') }

    row('Version', '<code>' ~ esc(%m<version>) ~ '</code>'
                 ~ (%m<auth> ?? ' <span class="fact-sub">' ~ esc(%m<auth>) ~ '</span>' !! ''));
    row('Depends', %m<depends>
                     ?? %m<depends>.split(',').map({ '<code>' ~ esc(.trim) ~ '</code>' }).join(', ')
                     !! '<span class="fact-sub">nothing outside the core</span>');
    row('License', esc(%m<license> // 'see the source'));
    row('Its own test suite', esc(%m<suite> // 'not run'));
    row('Checked', esc(%m<tested> // '—') ~ ' <span class="fact-sub">against '
                 ~ esc(%m<engine> // %SITE<engine>) ~ ' and ' ~ esc(%m<oracle> // %SITE<oracle>) ~ '</span>');

    my @links;
    @links.push('<a href="' ~ esc-attr(%m<raku-land>) ~ '">raku.land</a>') if %m<raku-land>;
    @links.push('<a href="' ~ esc-attr(%m<source>) ~ '">source</a>')       if %m<source>;
    row('Where it lives', @links.join(' · ')) if @links;

    '<dl class="facts">' ~ @rows.join ~ '</dl>'
}

sub install-html(%m --> Str) {
    my $name = %m<name>;
    code-block(shell-html("\$ rakupp install $name"))
}

# ---- the examples, as files -----------------------------------------------

# Every example is also a standalone program under examples/<module>/, so a
# reader can clone the repository and run it instead of copying it out of a web
# page. The file carries its own provenance — which page it is from, what to
# install, what it printed when the site was last built — because a file that
# travels away from its page has to explain itself.
sub write-examples($mod) {
    my $dir = example-dir($mod.slug);
    run('rm', '-rf', $dir) if $dir.IO.d;
    mkdir($dir);

    my $name = $mod.meta<name>;
    for @($mod.examples) -> $ex {
        my @head = "#!/usr/bin/env rakupp";
        @head.push("# $name — {$ex.section}");
        @head.push("# {%SITE<site-url>}{%SITE<base>}/{$mod.slug}/#{$ex.anchor}");
        @head.push('#');
        @head.push('# Install what it needs, then run it:');
        @head.push("#     rakupp install $name");
        @head.push("#     rakupp {$ex.file}");
        @head.push('#');
        @head.push("# Run under {%SITE<engine>} and {%SITE<oracle>} every time the site is");
        @head.push('# built; the build fails if the output below stops matching.');

        my @tail;
        if $ex.expected.defined {
            @tail.push('');
            @tail.push($ex.sample ?? '# One run printed:' !! '# Output:');
            @tail.push("#     $_") for $ex.expected.lines;
        }
        spurt("$dir/{$ex.file}", (|@head, '', $ex.code.trim, |@tail).join("\n") ~ "\n");
        "$dir/{$ex.file}".IO.chmod(0o755);
    }

    spurt("$dir/README.md", examples-readme($mod));
    say "  {@($mod.examples).elems} example file(s) -> $dir/";
}

# The top level of examples/ — the README a visitor to the repository lands
# on. Generated with the pages so its table cannot fall behind the directory
# listing beside it (it sat at one row of twelve directories for a while,
# still pointing at the handbook's pre-rename URLs).
sub write-examples-index(@mods) {
    my $rows = @mods.map(-> $mod {
        my %m = $mod.meta;
        my $page = %SITE<site-url> ~ %SITE<base> ~ '/' ~ $mod.slug ~ '/';
        "| [`{$mod.slug}/`]({$mod.slug}/) | [{%m<name>}]($page) | `rakupp install {%m<name>}` |"
    }).join("\n");
    my $first = @mods ?? @mods[0] !! Nil;
    my $clone-dir  = $first ?? $first.slug !! 'some-module';
    my $clone-mod  = $first ?? $first.meta<name> !! 'Some::Module';
    my $clone-file = $first && @($first.examples) ?? @($first.examples)[0].file !! '01-example.raku';
    spurt(%SITE<examples-dir> ~ '/README.md', qq:to/MD/);
    # Examples

    Working programs from [raku.online]({%SITE<site-url>}), one file each — clone
    this repository and run them, rather than copying them out of a web page.

    ```sh
    git clone https://github.com/ash/raku.online
    cd raku.online/examples/$clone-dir
    rakupp install $clone-mod
    rakupp $clone-file
    ```

    Everything here runs under **Raku++** and under **Rakudo** — these are Raku
    programs, not Raku++ programs. Swap `rakupp` for `raku` and they behave the
    same; where the two engines genuinely differ, the page the example comes from
    says so, and so does the file.

    ## What is here

    | Directory | From the page | What it needs |
    |---|---|---|
    $rows

    One directory per module of [the module handbook]({%SITE<site-url>}{%SITE<base>}/).
    Each has its own README listing its files.

    ## Where they come from, and why they can be trusted

    These files are **generated from the pages they appear on**, so a file and its
    page cannot drift apart. Each one is then *run* — under both engines, twice on
    each — every time the site is built, and its output compared against the
    `# Output:` comment at the bottom of the file. A file whose output has moved
    fails that build.

    So the output in a file is what it printed, not what it was once expected to
    print. The exception is the files whose comment says *One run printed* — those
    draw random numbers or show a run whose formatting the engines are still
    converging on, and are run to prove they still work rather than to compare
    what they say.

    To re-run that check yourself:

    ```sh
    cd sites/modules
    rakupp build.raku --verify --oracle=raku
    ```

    ## Editing them

    Edit the page, not the file: the module pages live in
    `sites/modules/src/modules/`, and `./build.sh modules` regenerates both the
    page and the files here.
    MD
    say "examples index -> {%SITE<examples-dir>}/README.md";
}

sub examples-readme($mod --> Str) {
    my %m = $mod.meta;
    my $page = %SITE<site-url> ~ %SITE<base> ~ '/' ~ $mod.slug ~ '/';
    my @rows = @($mod.examples).map(-> $ex {
        '| [`' ~ $ex.file ~ '`](' ~ $ex.file ~ ') | ' ~ $ex.section
          ~ ' | ' ~ ($ex.sample ?? 'varies (random)'
                                !! $ex.expected.defined ?? 'checked' !! 'runs') ~ ' |'
    });
    qq:to/MD/;
    # {%m<name>} — the examples

    Every example from [the {%m<name>} page]($page), one file each. They are
    generated from that page, so they cannot drift from it — and each one is a
    complete program: no scaffolding to add, nothing to uncomment.

    ```sh
    rakupp install {%m<name>}   # or: zef install {%m<name>}
    rakupp {@($mod.examples) ?? @($mod.examples)[0].file !! 'example.raku'}
    ```

    Each file is run under {%SITE<engine>} and under {%SITE<oracle>}, twice on each,
    whenever the site is built. A file whose output has moved fails that build, so
    the "Output:" comment at the bottom of a file is what it printed, not what it
    was once expected to print. The ones marked *varies* draw random numbers —
    they are run, but their output is not compared.

    | File | Section | Output |
    |---|---|---|
    { @rows.join("\n") }
    MD
}

# ---- verification ---------------------------------------------------------

# Run the example's FILE, not the markdown it came from: the file is what a
# reader clones, so the file is what has to work. (They cannot differ — the file
# is generated from the page — but checking the generated artifact is what makes
# that a fact rather than an intention.)
sub run-example(Str $exe, $mod, $ex) {
    my $path = example-dir($mod.slug) ~ '/' ~ $ex.file;
    my $proc = run($exe, $path, :out, :err);
    my $out = $proc.out.slurp(:close).subst(/ \n+ $ /, '');
    my $err = $proc.err.slurp(:close);
    $out, $err
}

# Every example is run TWICE per engine. Once proves the output; twice proves it
# is the same output — an example that prints a Hash's iteration order, or a
# random draw the author thought was pinned down, passes the first run and is a
# coin flip on every build after. (Rakudo randomises its hash seed per process,
# so the second run is the one that catches it.)
sub verify-examples(@mods, Str $oracle --> Int) {
    my $checked = 0;
    my $ran     = 0;
    my $fails   = 0;

    sub check(Str $engine, Str $exe, $mod, $ex, Str $path) {
        my ($got, $err) = run-example($exe, $mod, $ex);
        if $err.trim && !$ex.expected.defined {
            $fails++;
            note "  $engine FAILED $path:{$ex.line}";
            note "    stderr: {$err.trim.raku}";
            return;
        }
        return if $ex.sample;      # a sample is expected to move; it only has to run
        my ($again, $) = run-example($exe, $mod, $ex);
        if $got ne $again {
            $fails++;
            note "  $engine UNSTABLE $path:{$ex.line} — two runs, two answers";
            note "    first:  {$got.raku}";
            note "    second: {$again.raku}";
            return;
        }
        return unless $ex.expected.defined;
        my $want = $ex.expected.subst(/ \n+ $ /, '');
        if $got ne $want {
            $fails++;
            note "  $engine MISMATCH $path:{$ex.line}";
            note "    expected: {$want.raku}";
            note "    got:      {$got.raku}";
            note "    stderr:   {$err.trim.raku}" if $err.trim;
        }
    }

    for @mods -> $mod {
        for @($mod.examples) -> $ex {
            $ex.expected.defined && !$ex.sample ?? $checked++ !! $ran++;
            check('RAKU++', $RAKUPP, $mod, $ex, $mod.path);
            check("ORACLE($oracle)", $oracle, $mod, $ex, $mod.path) if $oracle;
        }
    }

    say "verify: $checked example(s) with a declared output, $ran run for exit status"
      ~ ($oracle ?? " · both engines" !! '') ~ " · $fails failure(s)";
    $fails ?? 1 !! 0
}

# ---- probe: is what the pages CLAIM still true? ---------------------------

# The frontmatter records a version and a verdict on the distribution's own test
# suite. Both go stale — a new release lands, or an engine change turns a green
# suite red — and a handbook that is quietly out of date is worse than one that
# admits it. This re-runs the two commands the claims come from.
sub probe-modules(@mods --> Int) {
    my $bad = 0;
    for @mods -> $mod {
        my $name = $mod.meta<name>;
        my $p = run($RAKUPP, 'install', '--dry-run', $name, :out, :err);
        my $plan = $p.out.slurp(:close);
        $p.err.slurp(:close);
        my $m = $plan ~~ / $name ':ver<' (<-[>]>+) '>' /;
        my $latest = $m ?? ~$0 !! '';
        if $latest && $latest ne $mod.meta<version> {
            $bad++;
            note "  $name: page says {$mod.meta<version>}, the ecosystem offers $latest";
        }

        my $t = run($RAKUPP, 'test', $name, :out, :err);
        my $log = $t.out.slurp(:close) ~ $t.err.slurp(:close);
        my $green = so $log.contains('suite green');
        my $claim = so ($mod.meta<suite> // '').contains('green');
        if $green != $claim {
            $bad++;
            note "  $name: page says suite '{$mod.meta<suite> // 'not run'}', the suite is "
               ~ ($green ?? 'green' !! 'NOT green');
        }
        say "probe: $name {$latest || '?'} · suite " ~ ($green ?? 'green' !! 'red');
    }
    say "probe: $bad claim(s) out of date";
    $bad ?? 1 !! 0
}

# ---- build ----------------------------------------------------------------

# The index is alphabetical by module name: a reader scans for a name, and
# adding a module stays one file under src/modules/ — nothing to list anywhere.
sub collect-modules(--> Array) {
    my @slugs = dir('src/modules').grep({ .IO.f && .Str.ends-with('.md') })
                                  .map({ .IO.basename.subst(/ '.md' $ /, '') }).sort;
    my @mods;
    @mods.push(load-module("src/modules/$_.md")) for @slugs;
    @mods.sort({ .meta<name>.lc }).Array
}

sub render-module($mod --> Str) {
    my %m = $mod.meta;
    my $r = Renderer.new(lines => $mod.body.lines, mod => $mod);
    my $body = $r.render;                       # fills $mod.examples on the way
    my $head =
        '<div class="page-head">'
      ~ '<div class="crumb">' ~ esc(%m<kind> // 'Distribution') ~ '</div>'
      ~ '<h1>' ~ esc(%m<name>) ~ '</h1>' ~ status-badge(%m<status>)
      ~ '</div>'
      ~ '<p class="summary">' ~ inline(%m<summary>) ~ '</p>'
      ~ facts-html(%m)
      ~ '<h2 id="install">Install it <a class="anchor" href="#install" aria-label="link">#</a></h2>'
      ~ install-html(%m)
      ~ '<p class="fact-sub">' ~ inline('`zef install ' ~ %m<name> ~ '` writes the same store; '
        ~ 'either installer leaves the module usable by both engines.') ~ '</p>';
    # Structured data: the page is ABOUT a piece of software with a name, a
    # version, a license and a repository — exactly the fields the frontmatter
    # already records, so a crawler gets them as facts rather than prose.
    my @ld = '"@context":"https://schema.org"', '"@type":"SoftwareSourceCode"',
             '"name":' ~ json-str(%m<name>),
             '"description":' ~ json-str(%m<summary>),
             '"programmingLanguage":"Raku"',
             '"version":' ~ json-str(%m<version>),
             '"url":' ~ json-str(%SITE<site-url> ~ $BASE ~ '/' ~ $mod.slug ~ '/');
    @ld.push('"license":' ~ json-str('https://spdx.org/licenses/' ~ %m<license>)) if %m<license>;
    @ld.push('"codeRepository":' ~ json-str(%m<source>)) if %m<source>;
    page("{%m<name>} — {%SITE<title>}", $head ~ $body,
         desc   => %m<summary>,
         path   => '/' ~ $mod.slug ~ '/',
         jsonld => '{' ~ @ld.join(',') ~ '}')
}

sub render-index(@mods --> Str) {
    my $examples = @mods.map({ @($_.examples).elems }).sum;
    my $rows = @mods.map(-> $mod {
        my %m = $mod.meta;
        '<tr><td><a href="' ~ $BASE ~ '/' ~ $mod.slug ~ '/">' ~ esc(%m<name>) ~ '</a>'
          ~ '<br><span class="fact-sub">' ~ esc(%m<summary>) ~ '</span></td>'
          ~ '<td><code>' ~ esc(%m<version>) ~ '</code></td>'
          ~ '<td>' ~ status-badge(%m<status>) ~ '</td>'
          ~ '<td class="num">' ~ @($mod.examples).elems ~ '</td></tr>'
    }).join("\n");

    my $body =
        '<h1>' ~ esc(%SITE<title>) ~ '</h1>'
      ~ '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>'
      ~ '<p>A module is on this site once Raku++ can do four things with it: '
      ~ '<strong>parse</strong> its sources, <strong>install</strong> it with '
      ~ '<code>rakupp install</code>, <strong>run</strong> the distribution\'s own test suite, '
      ~ 'and <strong>run</strong> the examples on its page. Every example below is executed under '
      ~ esc(%SITE<engine>) ~ ' and under ' ~ esc(%SITE<oracle>) ~ ' as the build runs, twice on each, '
      ~ 'and the build fails if an output moves. What you copy is what ran.</p>'
      ~ '<p><strong><a href="' ~ $BASE ~ '/ecosystem/">The whole Raku ecosystem — '
      ~ 'all 2,524 distributions and how each ran &rarr;</a></strong></p>'
      ~ '<div class="tablewrap"><table class="eco-index"><thead><tr>'
      ~ '<th>Module</th><th>Version</th><th>State</th><th class="num">Examples</th>'
      ~ '</tr></thead><tbody>' ~ $rows ~ '</tbody></table></div>'
      ~ '<p class="fact-sub">' ~ @mods.elems ~ (@mods.elems == 1 ?? ' module, ' !! ' modules, ')
      ~ $examples ~ (' example' ~ ($examples == 1 ?? '. ' !! 's. '))
      ~ 'Modules are added as they are checked — see the '
      ~ '<a href="/faq/modules/">module FAQ</a> for how installing works, and '
      ~ '<a href="/spec/">the conformance site</a> for the engine itself.</p>';
    page(%SITE<title>, $body, :index, desc => %SITE<tagline>, path => '/')
}

# ---------------------------------------------------------------------------
# The whole-ecosystem listing: every REA distribution and its sweep verdict.
# Data: src/data/ecosweep.tsv, folded from the rakupp repo's sweep TSVs by
# tools/distill-ecosweep.raku (the re-run's verdict wins over the first
# pass's; authors join from the installer's cached REA index via --index).
# Re-distill at each sweep; the dashboard's Ecosystem chart and this page
# must tell the same story.
# ---------------------------------------------------------------------------

sub comma(Int $n --> Str) { $n.Str.flip.comb(3).join(',').flip }

my %V-LABEL =
    'pass'           => 'passes its own test suite',
    'self-fail'      => 'its own suite fails',
    'dep-fail'       => 'a dependency fails first',
    'build-fail'     => 'its native build step fails',
    'dep-build-fail' => 'a dependency&rsquo;s build fails',
    'other'          => 'exited abnormally',
    'timeout'        => 'ran past its time budget',
    'fetch-fail'     => 'could not be fetched',
    'unresolved'     => 'could not be resolved';

sub render-ecosystem(--> Str) {
    my @rows;
    my %tally;
    my %blame;    # dist name -> how many dists its failure stops
    my %err-of;   # dist name -> its own first error, to show beside the blame
    for 'src/data/ecosweep.tsv'.IO.lines.skip(1) -> $line {
        my ($name, $version, $verdict, $blockers, $deps, $auth, $authors, $err)
            = $line.split("\t");
        next unless $name && $verdict;
        %tally{$verdict}++;
        my @blockers = ($blockers // '').split(';').grep(*.chars);
        # Ranked by how many blocked dists each one appears in, not by how
        # often it happened to be met first: a dist is stuck until EVERY
        # failing dependency in its chain is fixed, so appearing anywhere in
        # a chain is what counts.
        %blame{$_}++ for @blockers;
        %err-of{$name} = $err if $err;
        @rows.push({ name => $name, version => $version // '',
                     verdict => $verdict, blockers => @blockers,
                     deps => ($deps // 0).Int,
                     auth => $auth // '', authors => $authors // '',
                     error => $err // '' });
    }
    # The default order is the ecosystem's own: most-depended-on first
    # (runtime reverse-deps from the battery repo's rank-ecosystem.raku),
    # names breaking ties. The headers re-sort client-side.
    @rows = @rows.sort({ -.<deps>, .<name>.lc });
    my $total = @rows.elems;
    my $green = %tally<pass> // 0;

    my @order = %tally.keys.sort({ $_ eq 'pass' ?? '' !! $_ });  # pass first
    my $chips = @order.map(-> $v {
        '<button class="eco-flt" data-v="' ~ esc-attr($v) ~ '">'
          ~ esc($v) ~ ' <span>' ~ comma(%tally{$v}) ~ '</span></button>'
    }).join(' ');

    my $trs = @rows.map(-> %r {
        # A dependency verdict is only actionable if it names the dependency,
        # and naming ONE is not enough: half these dists are stuck behind
        # several, and the chain has to be walked to the end before the dist
        # itself ever runs. The count is the honest headline; the list under
        # it gives each dependency its own error, and each name filters the
        # table to everything that one failure stops.
        my @b = |%r<blockers>;
        my $err = do if @b {
            '<details class="eco-blocked"><summary>blocked by ' ~ @b.elems
              ~ (@b.elems == 1 ?? ' dependency' !! ' dependencies') ~ '</summary><ul>'
              ~ @b.map(-> $b {
                    '<li><button class="eco-blame" data-c="' ~ esc-attr($b.lc) ~ '"'
                      ~ ' title="Show every distribution blocked by ' ~ esc-attr($b)
                      ~ '">' ~ esc($b) ~ '</button>'
                      ~ (%err-of{$b} ?? ' &mdash; ' ~ esc(%err-of{$b}) !! '')
                      ~ '</li>'
                }).join
              ~ '</ul></details>'
        }
        # Its own error, for the dists that failed on their own code.
        elsif %r<error> { '<div class="eco-err">' ~ esc(%r<error>) ~ '</div>' }
        else { '' };
        # The zef/github identity is the column; the human names sit under it
        # the way a dist's summary sits under its name. Emails shed for
        # DISPLAY only — the TSV keeps what REA records, and the search
        # haystack still matches them. The ecosystem writes them four ways:
        # `Name <email>`, `Name <email` (six dists never close the bracket),
        # `Name (email)`, and entries that are nothing but an address — those
        # drop out entirely, and a name repeated with two emails shows once.
        # An auth that is one clean token links to its raku.land author page;
        # the few dists whose declared auth is free text stay plain.
        my $names = %r<authors>.split(',')
            .map({ .subst(/ '<' <-[>]>* '>' /, '', :g)
                    .subst(/ '<' <-[>]>* $ /, '')
                    .subst(/ '(' <-[)]>* '@' <-[)]>* ')' /, '', :g)
                    .trim })
            .unique.grep({ .chars && !.contains('@') }).join(', ');
        my $who = %r<auth>
            ?? (%r<auth> ~~ / \s /
                ?? '<span>' ~ esc(%r<auth>) ~ '</span>'
                !! '<a href="https://raku.land/' ~ esc-attr(%r<auth>) ~ '">'
                     ~ esc(%r<auth>) ~ '</a>')
               ~ ($names ?? '<div class="eco-who">' ~ esc($names) ~ '</div>' !! '')
            !! '&mdash;';
        my $hay = (%r<name>, %r<auth>, %r<authors>, |%r<blockers>)
                      .grep(*.chars).join(' ').lc;
        '<tr data-v="' ~ esc-attr(%r<verdict>) ~ '" data-n="' ~ esc-attr(%r<name>.lc) ~ '"'
          ~ ' data-a="' ~ esc-attr(%r<auth>.lc) ~ '" data-s="' ~ esc-attr($hay) ~ '"'
          ~ ' data-c="' ~ esc-attr(@b.map(*.lc).join(' ')) ~ '"'
          ~ ' data-d="' ~ %r<deps> ~ '">'
          ~ '<td><a href="https://raku.land/?q=' ~ esc-attr(%r<name>) ~ '">' ~ esc(%r<name>) ~ '</a>' ~ $err ~ '</td>'
          ~ '<td class="eco-auth">' ~ $who ~ '</td>'
          ~ '<td class="num">' ~ (%r<deps> ?? comma(%r<deps>) !! '&mdash;') ~ '</td>'
          ~ '<td><code>' ~ esc(%r<version>) ~ '</code></td>'
          ~ '<td><span class="eco-v v-' ~ esc-attr(%r<verdict>) ~ '">' ~ esc(%r<verdict>) ~ '</span></td>'
          ~ '</tr>'
    }).join("\n");

    my $legend = @order.map(-> $v {
        '<span class="eco-v v-' ~ esc-attr($v) ~ '">' ~ esc($v) ~ '</span> '
          ~ (%V-LABEL{$v} // '')
    }).join(' &middot; ');

    # Naming the worst blockers turns a wall of amber rows into a work list.
    # The number beside each is how many blocked dists have it somewhere in
    # their chain — every one of which stays stuck until it is fixed, though
    # most wait on several, so these are not 104 dists one repair sets free.
    my $blocked = +@rows.grep({ .<blockers>.elems });
    my $multi   = +@rows.grep({ .<blockers>.elems > 1 });
    my @top = %blame.keys.sort({ -%blame{$_}, $_.lc }).head(8);
    my $blockers = %blame
        ?? '<p>' ~ comma($blocked) ~ ' distributions never reach their own test '
             ~ 'suite because something in their dependency chain fails first, and '
             ~ comma($multi) ~ ' of those wait on more than one &mdash; a row opens '
             ~ 'to show every dependency it is stuck behind, with that dependency&rsquo;s '
             ~ 'own error. Between them they wait on ' ~ comma(%blame.elems)
             ~ ' distinct distributions. The ones the most dists wait on: '
             ~ @top.map(-> $b {
                   '<button class="eco-blame" data-c="' ~ esc-attr($b.lc) ~ '">'
                     ~ esc($b) ~ '</button>&nbsp;<span class="eco-bn">'
                     ~ comma(%blame{$b}) ~ '</span>'
               }).join(' &middot; ')
             ~ '.</p>'
        !! '';

    # When, and on what. Without this a reader cannot tell a sweep taken today
    # from one taken three weeks and seventeen versions ago — and the verdicts
    # on this page move release to release, so the engine is part of the
    # measurement, not a footnote. Read from data rather than written into the
    # prose, so it cannot outlive the numbers beside it; a sweep that forgets
    # to record it simply says nothing.
    my $provenance = do if 'src/data/ecosweep-meta.txt'.IO.e {
        my %m = 'src/data/ecosweep-meta.txt'.IO.lines
                    .map({ .split("\t") }).grep(*.elems >= 2)
                    .map({ .[0] => .[1] }).Hash;
        %m<date> && %m<engine>
            ?? '<p class="fact-sub">Measured ' ~ esc(%m<date>) ~ ' on Raku++ '
                 ~ '<code>' ~ esc(%m<engine>) ~ '</code>'
                 ~ (%m<oracle> ?? ', against ' ~ esc(%m<oracle>) ~ ' as the oracle' !! '')
                 ~ '.</p>'
            !! ''
    }
    else { '' };

    my $body = q:to/CSS/
        <style>
        .eco-tools { display:flex; flex-wrap:wrap; gap:.5rem; align-items:center; margin:1rem 0; }
        .eco-tools input { flex:1 1 14rem; padding:.45rem .7rem; font:inherit;
            border:1px solid var(--line, #ccc); border-radius:.4rem;
            background:var(--bg, transparent); color:inherit; }
        .eco-flt { font:inherit; font-size:.85rem; padding:.3rem .6rem; cursor:pointer;
            border:1px solid var(--line, #ccc); border-radius:1rem; background:transparent; color:inherit; }
        .eco-flt span { opacity:.65; }
        .eco-flt.on { border-color: currentColor; font-weight:600; }
        .eco-v { font-size:.78rem; padding:.1rem .5rem; border-radius:1rem; white-space:nowrap; }
        .v-pass { background:#1a7f3722; color:#1a7f37; }
        .v-self-fail { background:#b3261e18; color:#b3261e; }
        .v-dep-fail, .v-dep-build-fail { background:#9a6a0018; color:#9a6a00; }
        .v-build-fail { background:#8250df18; color:#8250df; }
        .v-other, .v-fetch-fail, .v-unresolved { background:#65656518; color:#656565; }
        .v-timeout { background:#0a6e7418; color:#0a6e74; }
        .eco-err { font-size:.78rem; opacity:.72; margin-top:.15rem; max-width:44rem;
            overflow-wrap:anywhere; }
        .eco-blame { font:inherit; font-size:1em; padding:0; border:0; background:none;
            color:inherit; cursor:pointer; font-weight:600;
            text-decoration:underline; text-decoration-style:dotted; }
        .eco-blame:hover { text-decoration-style:solid; }
        .eco-blamed { margin-left:.15rem; font:inherit; font-size:.85rem; padding:.3rem .6rem;
            cursor:pointer; border:1px solid currentColor; border-radius:1rem;
            background:transparent; color:inherit; font-weight:600; }
        .eco-blamed[hidden] { display:none; }
        .eco-bn { opacity:.65; font-size:.85rem; }
        .eco-blocked { font-size:.78rem; margin-top:.15rem; max-width:44rem; }
        .eco-blocked > summary { cursor:pointer; opacity:.72; }
        .eco-blocked[open] > summary { margin-bottom:.3rem; }
        .eco-blocked ul { margin:0; padding-left:1.1rem; }
        .eco-blocked li { opacity:.72; margin:.15rem 0; overflow-wrap:anywhere; }
        .eco-who { font-size:.78rem; opacity:.72; margin-top:.15rem; max-width:16rem; }
        .eco-all td { padding:.45rem .6rem; vertical-align:top; }
        .eco-sort { cursor:pointer; user-select:none; white-space:nowrap; }
        .eco-sort:after { content:'\2195'; opacity:.35; margin-left:.3rem; font-size:.8em; }
        .eco-sort.on.desc:after { content:'\2193'; opacity:.9; }
        .eco-sort.on.asc:after  { content:'\2191'; opacity:.9; }
        .eco-count { margin:.6rem 0; }
        </style>
        CSS
      ~ '<h1>The Raku ecosystem under Raku++</h1>'
      ~ '<p class="tagline">Every distribution in the REA index — latest release of each — '
      ~ 'fetched, built, installed and its own test suite run under Raku++.</p>'
      ~ $provenance
      ~ '<p>' ~ $green ~ ' of ' ~ comma($total) ~ ' distributions pass <em>their own</em> tests. '
      ~ 'A verdict names the first rung that failed, so a fix tends to move a dist one rung: '
      ~ $legend ~ '. The sweep, the fix campaign it drove, and the per-dist raw results live in '
      ~ '<a href="https://github.com/ash/rakupp/blob/main/docs/dev/findings/ECOSWEEP-2026-08.md">the write-up</a>; '
      ~ 'the trend is on <a href="/spec/dashboard/">the dashboard</a>. '
      ~ 'The table opens most-depended-on first; click a header to re-sort, '
      ~ 'and the filter matches distribution names, authors, and the dependencies '
      ~ 'a dist is blocked by alike.</p>'
      ~ $blockers
      ~ '<div class="eco-tools"><input type="search" id="eco-q" placeholder="Filter by name, author or blocking dependency…" '
      ~ 'aria-label="Filter by name, author or blocking dependency"> ' ~ $chips
      ~ '<button class="eco-blamed" id="eco-blamed" hidden></button></div>'
      ~ '<p class="fact-sub eco-count" id="eco-count"></p>'
      ~ '<div class="tablewrap"><table class="eco-index eco-all"><thead><tr>'
      ~ '<th class="eco-sort" data-k="n" data-dir="asc">Distribution</th>'
      ~ '<th class="eco-sort" data-k="a" data-dir="asc" title="The dist&rsquo;s declared auth, with the human names it lists">Author</th>'
      ~ '<th class="eco-sort num on desc" data-k="d" data-dir="desc" title="How many other dists&rsquo; runtime dependencies resolve to this one">Used by</th>'
      ~ '<th>Version</th>'
      ~ '<th class="eco-sort" data-k="v" data-dir="asc">Verdict</th>'
      ~ '</tr></thead><tbody id="eco-body">' ~ $trs ~ '</tbody></table></div>'
      ~ q:to/JS/;
        <script>
        (function () {
          var q = document.getElementById('eco-q');
          var rows = [].slice.call(document.querySelectorAll('tr[data-v]'));
          var count = document.getElementById('eco-count');
          var flts = [].slice.call(document.querySelectorAll('.eco-flt'));
          var verdict = '';
          var blame = '';
          var blamed = document.getElementById('eco-blamed');
          function apply() {
            var needle = q.value.trim().toLowerCase(), shown = 0;
            rows.forEach(function (r) {
              var ok = (!verdict || r.getAttribute('data-v') === verdict)
                    && (!blame || (' ' + r.getAttribute('data-c') + ' ')
                                    .indexOf(' ' + blame + ' ') !== -1)
                    && (!needle || r.getAttribute('data-s').indexOf(needle) !== -1);
              r.style.display = ok ? '' : 'none';
              if (ok) shown++;
            });
            var fmtN = function (n) { return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ','); };
            count.textContent = shown === rows.length
              ? fmtN(rows.length) + ' distributions'
              : fmtN(shown) + ' of ' + fmtN(rows.length) + ' distributions shown';
          }
          q.addEventListener('input', apply);
          // Every blocking-dependency name on the page — in a row and in the
          // list of worst offenders above — narrows the table to the dists
          // that one failure stops. Delegated, so re-sorting keeps it live.
          function setBlame(c, label) {
            if (blame === c) { blame = ''; }
            else { blame = c; blamed.textContent = 'blocked by ' + label + ' \u2715'; }
            blamed.hidden = !blame;
            apply();
          }
          document.addEventListener('click', function (e) {
            var b = e.target.closest && e.target.closest('.eco-blame');
            if (b) setBlame(b.getAttribute('data-c'), b.textContent);
          });
          blamed.addEventListener('click', function () { setBlame(blame, ''); });
          var body = document.getElementById('eco-body');
          var heads = [].slice.call(document.querySelectorAll('.eco-sort'));
          heads.forEach(function (h) {
            h.addEventListener('click', function () {
              var k = h.getAttribute('data-k');
              var dir = h.classList.contains('on')
                ? (h.classList.contains('desc') ? 'asc' : 'desc')
                : h.getAttribute('data-dir');
              heads.forEach(function (x) { x.classList.remove('on', 'asc', 'desc'); });
              h.classList.add('on', dir);
              var mul = dir === 'desc' ? -1 : 1;
              rows.sort(function (a, b) {
                var av, bv;
                if (k === 'd') { av = +a.getAttribute('data-d'); bv = +b.getAttribute('data-d'); }
                else { av = a.getAttribute('data-' + k); bv = b.getAttribute('data-' + k); }
                // rows with no author sit at the bottom whichever way it sorts
                if (k === 'a' && !av !== !bv) return av ? -1 : 1;
                if (av < bv) return -1 * mul;
                if (av > bv) return 1 * mul;
                var an = a.getAttribute('data-n'), bn = b.getAttribute('data-n');
                return an < bn ? -1 : an > bn ? 1 : 0;
              });
              rows.forEach(function (r) { body.appendChild(r); });
            });
          });
          flts.forEach(function (b) {
            b.addEventListener('click', function () {
              var v = b.getAttribute('data-v');
              verdict = (verdict === v) ? '' : v;
              flts.forEach(function (x) { x.classList.toggle('on', x === b && verdict); });
              apply();
            });
          });
          apply();
        })();
        </script>
        JS
    page('The Raku ecosystem under Raku++ — ' ~ %SITE<title>, $body,
         desc => 'Every distribution in the REA index — latest release of each — '
               ~ 'fetched, built, installed and its own test suite run under Raku++, '
               ~ 'with a verdict for each.',
         path => '/ecosystem/')
}

sub MAIN(Bool :$clean = False, Bool :$verify = False, Bool :$probe = False,
         Str :$rakupp = RAKUPP-DEFAULT, Str :$oracle = '') {
    %SITE   = EVAL slurp('src/site.raku');
    $BASE   = %SITE<base> // '';
    $RAKUPP = $rakupp;

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');

    my @mods = @(collect-modules());
    mkdir(%SITE<examples-dir>) unless %SITE<examples-dir>.IO.d;
    for @mods -> $mod {
        mkdir("out/{$mod.slug}");
        spurt("out/{$mod.slug}/index.html", render-module($mod));  # fills .examples
        write-examples($mod);
    }
    spurt('out/index.html', render-index(@mods));
    write-examples-index(@mods);

    if 'src/data/ecosweep.tsv'.IO.e {
        mkdir('out/ecosystem');
        spurt('out/ecosystem/index.html', render-ecosystem());
        say "built the whole-ecosystem listing -> out/ecosystem/";
    }

    say "built {@mods.elems} module page(s) + index -> out/";

    exit probe-modules(@mods) if $probe;
    exit verify-examples(@mods, $oracle) if $verify;
}
