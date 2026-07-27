#!/usr/bin/env raku
# build.raku — static generator for the Raku tour (tour.raku.online).
#
# Run with rakupp (the whole toolchain is Raku++, dogfooding the interpreter):
#
#   rakupp build.raku                 # build src/ -> out/
#   rakupp build.raku --verify        # build, then run every example through rakupp
#   rakupp build.raku --clean         # remove out/ first
#   rakupp build.raku --rakupp=PATH   # interpreter used for --verify
#   rakupp build.raku --oracle=raku   # also check every example against Rakudo
#
# The tour is a linear sequence of lessons: one Markdown-ish file per lesson under
# src/lessons/NN-slug.md, ordered by filename, grouped into chapters by the
# `chapter:` frontmatter line (consecutive lessons with the same chapter form a
# group in the sidebar). Fenced ```raku blocks become runnable editors via
# raku.online/raku.js; a following ```output block gives the expected output, and
# --verify runs each such pair through the real rakupp binary, failing the build
# on any mismatch — the tour cannot drift from the interpreter it teaches.
#
# Two extra fence kinds beyond the spec generator's:
#   ```raku exercise     an editor with starter code for the reader to finish —
#                        rendered as an exercise card, never verified
#   ```solution          a collapsed "Show a solution" block; runnable and
#                        verified like a normal example

constant RAKUPP-DEFAULT = 'rakupp';

# Cache-busting tag stamped onto theme assets (?v=…), set once per build from a
# content hash of all sources.
my $VERSION = '';

# Theme switcher: same code and 'raku-theme' localStorage key as the playground
# and the spec site, so the three sites feel like one. Runs inline in <head> so
# the resolved theme applies before first paint.
my $THEME-SCRIPT = q:to/JS/;
(function () {
  var KEY = 'raku-theme';
  var mql = window.matchMedia('(prefers-color-scheme: dark)');
  var ICON = { system: '◐', light: '☀', dark: '☾' };
  function stored() { try { return localStorage.getItem(KEY) || 'system'; } catch (e) { return 'system'; } }
  function effective(s) { return (s === 'dark' || (s === 'system' && mql.matches)) ? 'dark' : 'light'; }
  function apply(s) {
    var d = document.documentElement;
    d.setAttribute('data-theme', s);
    d.setAttribute('data-theme-active', effective(s));
    var btn = document.querySelector('.theme-btn');
    if (btn) btn.textContent = ICON[s] || ICON.system;
    document.querySelectorAll('.theme-menu [data-theme-set]').forEach(function (el) {
      el.setAttribute('aria-checked', el.getAttribute('data-theme-set') === s ? 'true' : 'false');
    });
  }
  apply(stored());
  mql.addEventListener('change', function () { if (stored() === 'system') apply('system'); });
  window.__setTheme = function (s) { try { localStorage.setItem(KEY, s); } catch (e) {} apply(s); };
  document.addEventListener('DOMContentLoaded', function () {
    apply(stored());
    var sw = document.querySelector('.theme-switch');
    if (!sw) return;
    var btn = sw.querySelector('.theme-btn'), menu = sw.querySelector('.theme-menu');
    function open(o) { menu.hidden = !o; btn.setAttribute('aria-expanded', o ? 'true' : 'false'); }
    btn.addEventListener('click', function (e) { e.stopPropagation(); open(menu.hidden); });
    menu.addEventListener('click', function (e) {
      var b = e.target.closest('[data-theme-set]');
      if (b) { window.__setTheme(b.getAttribute('data-theme-set')); open(false); btn.focus(); }
    });
    document.addEventListener('click', function (e) { if (!sw.contains(e.target)) open(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !menu.hidden) { e.stopPropagation(); open(false); btn.focus(); } });
  });
})();
JS

# ---------------------------------------------------------------------------
# Small text helpers
# ---------------------------------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}
sub esc-attr(Str $s --> Str) { esc($s).subst('"', '&quot;', :g) }

sub slugify(Str $s is copy --> Str) {
    $s = $s.subst(/ '<' <-[>]>* '>' /, '', :g);      # strip any tags
    $s = $s.lc;
    $s = $s.subst(/ <-[ a..z 0..9 \s \- ]> /, '', :g);
    $s = $s.subst(/ \s+ /, '-', :g);
    $s
}

# Inline formatting. fmt-basic handles code spans (split on backticks) + bold/italic
# + escaping — but NOT links. inline() renders links first, protects each with a
# plain-ASCII sentinel, formats the rest, then splices the links back in.
sub fmt-basic(Str $seg --> Str) {
    my @out;
    for $seg.split('`').kv -> $idx, $s {
        if $idx %% 2 {
            my $t = esc($s);
            $t = $t.subst(/ '**' (<-[*]>+) '**' /, { '<strong>' ~ (~$0) ~ '</strong>' }, :g);
            $t = $t.subst(/ '*' (<-[*]>+) '*' /,   { '<em>' ~ (~$0) ~ '</em>' }, :g);
            @out.push($t);
        }
        else {
            @out.push('<code>' ~ esc($s) ~ '</code>');
        }
    }
    @out.join
}

sub inline(Str $text --> Str) {
    my @links;
    my $protected = $text.subst(/ '[' (<-[ \] ]>+) ']' '(' (<-[ ) ]>+) ')' /, {
        @links.push('<a href="' ~ esc-attr(~$1) ~ '">' ~ fmt-basic(~$0) ~ '</a>');
        'zXLINKXz' ~ @links.end ~ 'zXENDXz'
    }, :g);
    my $body = fmt-basic($protected);
    $body.subst(/ 'zXLINKXz' (\d+) 'zXENDXz' /, { @links[+$0] }, :g)
}

# Escape a string as a JSON string literal, PRESERVING newlines/tabs as \n/\t.
sub json-esc(Str $s --> Str) {
    my $e = $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst("\r", '\\r', :g).subst("\n", '\\n', :g).subst("\t", '\\t', :g);
    '"' ~ $e ~ '"'
}

# 8-char content hash over every source — the cache tag.
sub asset-version(--> Str) {
    my @files = dir('src/theme').grep({ .IO.f }).map(*.Str);
    @files.append: dir('src/lessons').grep({ .IO.f && .Str.ends-with('.md') }).map(*.Str);
    @files.push('src/site.raku');
    my $blob = @files.sort.map({ slurp($_) }).join;
    my $p = run('md5', '-q', :in, :out);
    $p.in.print($blob);
    $p.in.close;
    $p.out.slurp(:close).trim.substr(0, 8)
}

# Parse a fence info string like `raku exercise stdin="Ada\nGrace"` into (lang, %opts).
sub parse-info(Str $info) {
    my $lang = $info.words ?? $info.words[0] !! '';
    my %opts;
    my $rest = $info.subst(/ ^ \s* \S+ /, '');
    # NB: a literal " inside a <-[...]> class breaks rakupp's regex parser, so the
    # quote is written as \x22 here.
    for $rest ~~ m:g/ (\w+) [ '="' (<-[\x22]>*) '"' ]? / -> $m {
        %opts{ ~$m[0] } = $m[1].defined ?? (~$m[1]).subst('\n', "\n", :g) !! True;
    }
    $lang, %opts
}

# ---------------------------------------------------------------------------
# Document model
# ---------------------------------------------------------------------------

class Lesson {
    has Str $.slug;
    has Str $.title;
    has Str $.chapter;
    has Str $.summary;
    has Str $.body;
    has Str $.path;
    has Int $.num is rw = 0;      # 1-based position in the tour
    has @.examples is rw;          # list of [code, expected-or-Nil, line-number]
}

sub parse-frontmatter(Str $text, Str $path) {
    die "$path: missing '---' frontmatter block" unless $text.starts-with('---');
    my $end = $text.index("\n---", 3);
    die "$path: unterminated frontmatter block" unless $end.defined;
    my $head = $text.substr(3, $end - 3).trim("\n");
    my $body = $text.substr($end + 4).subst(/ ^ \n+ /, '');
    my %meta;
    for $head.lines -> $raw {
        my $line = $raw.trim;
        next unless $line;
        next if $line.starts-with('#');
        die "$path: bad frontmatter line: $line" unless $line.contains(':');
        my ($k, $v) = $line.split(':', 2);
        %meta{ $k.trim } = $v.trim;
    }
    # Itemise the hash so it stays one element when list-assigned by the caller.
    $(%meta), $body
}

sub load-lesson(Str $path --> Lesson) {
    my ($meta, $body) = parse-frontmatter(slurp($path), $path);
    die "$path: frontmatter needs a 'title'"   unless $meta<title>;
    die "$path: frontmatter needs a 'chapter'" unless $meta<chapter>;
    # Default slug: the filename minus its NN- ordering prefix and .md suffix.
    my $base = $path.IO.basename.subst(/ '.md' $ /, '').subst(/ ^ \d+ '-' /, '');
    Lesson.new(
        slug     => $meta<slug> // $base,
        title    => $meta<title>,
        chapter  => $meta<chapter>,
        summary  => $meta<summary> // '',
        body     => $body,
        path     => $path,
        examples => [],
    )
}

sub collect-lessons(--> Array) {
    my @lessons;
    for dir('src/lessons').grep({ .IO.f && .Str.ends-with('.md') }).sort -> $md {
        @lessons.push(load-lesson($md.Str));
    }
    for @lessons.kv -> $i, $l {
        $l.num = $i + 1;
    }
    @lessons
}

# Group consecutive lessons that share a chapter title: list of {title, lessons}.
sub chapters(@lessons) {
    my @groups;
    for @lessons -> $l {
        if @groups && @groups[*-1]<title> eq $l.chapter {
            @groups[*-1]<lessons>.push($l);
        }
        else {
            @groups.push({ title => $l.chapter, lessons => [$l] });
        }
    }
    @groups
}

# ---------------------------------------------------------------------------
# Markdown-ish renderer (same small subset as the spec generator)
# ---------------------------------------------------------------------------

class Renderer {
    has @.lines;
    has @!out;
    has $.lesson;
    has Int $!i = 0;

    method render(--> Str) {
        while $!i < @.lines.elems {
            my $line = @.lines[$!i];
            if $line !~~ / \S /                          { $!i++ }
            elsif $line.starts-with('```')               { self!fence }
            elsif $line ~~ / ^ '#'+ \s /                 { self!heading($line) }
            elsif $line ~~ / ^ \s* <[\-*]> ' ' /         { self!ulist }
            elsif $line ~~ / ^ \s* \d+ '.' ' ' /         { self!olist }
            elsif $line.starts-with('>')                 { self!quote }
            elsif $line ~~ / ^ \s* '|' / && self!table-ahead { self!table }
            else                                         { self!paragraph }
        }
        @!out.join("\n")
    }

    method !starter(Str $line --> Bool) {
        so  $line !~~ / \S /
        ||  $line.starts-with('```')
        ||  $line ~~ / ^ '#'+ \s /
        ||  $line.starts-with('>')
        ||  $line ~~ / ^ \s* <[\-*]> ' ' /
        ||  $line ~~ / ^ \s* \d+ '.' ' ' /
    }

    method !heading(Str $line) {
        my $hashes = ($line ~~ / ^ ('#'+) /)[0].chars;
        my $text = $line.substr($hashes).trim;
        my $anchor = slugify($text);
        @!out.push:
            "<h$hashes id=\"$anchor\">" ~ inline($text) ~
            " <a class=\"anchor\" href=\"#$anchor\" aria-label=\"link\">#</a></h$hashes>";
        $!i++;
    }

    method !paragraph {
        my @buf;
        while $!i < @.lines.elems && !self!starter(@.lines[$!i]) {
            @buf.push(@.lines[$!i].trim);
            $!i++;
        }
        @!out.push('<p>' ~ inline(@buf.join(' ')) ~ '</p>');
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
        @!out.push('<ul>' ~ @items.map({ "<li>{$_}</li>" }).join ~ '</ul>');
    }

    method !olist {
        my @items;
        while $!i < @.lines.elems && @.lines[$!i] ~~ / ^ \s* \d+ '.' ' ' / {
            my $first = @.lines[$!i].subst(/ ^ \s* \d+ '.' \s /, '').trim;
            $!i++;
            @items.push(self!item-body($first));
        }
        @!out.push('<ol>' ~ @items.map({ "<li>{$_}</li>" }).join ~ '</ol>');
    }

    method !quote {
        my @buf;
        while $!i < @.lines.elems && @.lines[$!i].starts-with('>') {
            @buf.push(@.lines[$!i].subst(/ ^ '>' \s? /, ''));
            $!i++;
        }
        @!out.push('<blockquote class="note">' ~ inline(@buf.join(' ')) ~ '</blockquote>');
    }

    method !table-ahead(--> Bool) {
        so $!i + 1 < @.lines.elems
            && @.lines[$!i + 1] ~~ / ^ \s* '|'? <[ \s : | \- ]>+ '|' /
    }

    method !cells(Str $row is copy) {
        $row = $row.trim;
        $row = $row.substr(1) if $row.starts-with('|');
        $row = $row.substr(0, $row.chars - 1) if $row.ends-with('|');
        $row.split('|').map(*.trim)
    }

    method !table {
        my @header = self!cells(@.lines[$!i]);
        $!i += 2;   # header row + delimiter row
        my @rows;
        while $!i < @.lines.elems && @.lines[$!i].trim.starts-with('|') {
            @rows.push([self!cells(@.lines[$!i])]);
            $!i++;
        }
        my $h = @header.map({ '<th>' ~ inline($_) ~ '</th>' }).join;
        my $b = @rows.map(-> @r { '<tr>' ~ @r.map({ '<td>' ~ inline($_) ~ '</td>' }).join ~ '</tr>' }).join;
        @!out.push("<div class=\"table-wrap\"><table><thead><tr>{$h}</tr></thead><tbody>{$b}</tbody></table></div>");
    }

    method !fence {
        my $info  = @.lines[$!i].substr(3);
        my $start = $!i + 1;
        $!i++;
        my @buf;
        while $!i < @.lines.elems && !@.lines[$!i].starts-with('```') {
            @buf.push(@.lines[$!i]);
            $!i++;
        }
        $!i++;   # closing fence
        my $code = @buf.join("\n");
        my ($lang, %opts) = parse-info($info);

        if $lang eq 'raku' | 'raku-run' {
            if %opts<exercise> {
                # Starter code for the reader to finish — runnable, never verified.
                self!emit-exercise($code, %opts);
            }
            else {
                my $expected = self!peek-output;
                $.lesson.examples.push([$code, $expected, $start]);
                my $run = so ($lang eq 'raku-run' || %opts<run>);
                self!emit-runnable($code, %opts, $run, $expected);
            }
        }
        elsif $lang eq 'solution' {
            my $expected = self!peek-output;
            $.lesson.examples.push([$code, $expected, $start]);
            @!out.push('<details class="solution"><summary>Show a solution</summary>');
            self!emit-runnable($code, %opts, False, $expected);
            @!out.push('</details>');
        }
        elsif $lang eq 'output' | 'text' {
            @!out.push('<pre class="output"><code>' ~ esc($code) ~ '</code></pre>');
        }
        else {
            my $cls = $lang ?? " class=\"lang-{esc-attr($lang)}\"" !! '';
            @!out.push("<pre$cls><code>" ~ esc($code) ~ '</code></pre>');
        }
    }

    # If the next non-blank block is an ```output fence, consume it and return its
    # text (used both to render the expected output and to verify examples).
    method !peek-output {
        my $j = $!i;
        $j++ while $j < @.lines.elems && @.lines[$j] !~~ / \S /;
        return Str unless $j < @.lines.elems && @.lines[$j].starts-with('```');
        my ($lang, $) = parse-info(@.lines[$j].substr(3));
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

    method !editor-attrs(%opts, Bool $run) {
        my @attrs = 'data-raku';
        @attrs.push('data-run') if $run;
        @attrs.push('data-stdin="' ~ esc-attr(%opts<stdin>) ~ '"')
            if %opts<stdin>:exists && %opts<stdin> !=== True;
        @attrs.push('data-rows="' ~ esc-attr(~%opts<rows>) ~ '"')
            if %opts<rows>:exists && %opts<rows> !=== True;
        @attrs.join(' ')
    }

    method !emit-runnable(Str $code, %opts, Bool $run, $expected) {
        @!out.push('<pre ' ~ self!editor-attrs(%opts, $run) ~ '>' ~ esc($code) ~ '</pre>');
        # Auto-run blocks show their live output panel, so a static copy of the
        # same text underneath is noise (still recorded above for --verify).
        if $expected.defined && !$run {
            @!out.push(
                '<div class="expected"><span class="expected-label">Output</span>' ~
                '<pre class="output"><code>' ~ esc($expected) ~ '</code></pre></div>');
        }
    }

    method !emit-exercise(Str $code, %opts) {
        @!out.push(
            '<div class="exercise"><span class="exercise-label">Exercise</span>' ~
            '<pre ' ~ self!editor-attrs(%opts, False) ~ '>' ~ esc($code) ~ '</pre></div>');
    }
}

# ---------------------------------------------------------------------------
# HTML assembly
# ---------------------------------------------------------------------------

sub nav-html(@lessons, $current) {
    my @parts = '<nav class="sidebar"><div class="sidebar-head">' ~
        '<a class="brand" href="/">Raku<span>tour</span></a></div><div class="sidebar-nav">';
    for chapters(@lessons) -> %ch {
        @parts.push(
            '<div class="nav-cat open"><div class="nav-cat-name">' ~
            esc(%ch<title>) ~ '</div><div class="nav-cat-body"><ul>');
        for @(%ch<lessons>) -> $l {
            my $active = ($current.defined && $l === $current) ?? ' class="active"' !! '';
            @parts.push(
                "<li><a$active data-slug=\"{esc-attr($l.slug)}\" href=\"/{$l.slug}/\">" ~
                "<span class=\"tick\" aria-hidden=\"true\"></span>" ~
                "<span class=\"lnum\">{$l.num}.</span> {esc($l.title)}</a></li>");
        }
        @parts.push('</ul></div></div>');
    }
    @parts.push('</div></nav>');
    @parts.join
}

# The lesson order + current slug, exposed to tour.js for progress and keyboard nav.
sub tour-script(@lessons, $current --> Str) {
    my $order = '[' ~ @lessons.map(-> $l { json-esc($l.slug) }).join(',') ~ ']';
    my $slug  = $current.defined ?? json-esc($current.slug) !! 'null';
    '<script>window.TOUR={order:' ~ $order ~ ',slug:' ~ $slug ~ '};</script>'
}

sub page-shell(%site, Str $title, Str $body, Str $nav, Str $tour-js, :$home = False --> Str) {
    my $engine     = esc-attr(%site<engine>);
    my $playground = esc-attr(%site<playground>);
    my $repo       = esc-attr(%site<repo>);
    my $body-class = $home ?? 'home' !! '';
    qq:to/HTML/
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <script>{$THEME-SCRIPT}</script>
    <link rel="stylesheet" href="/theme/base.css?v={$VERSION}">
    </head>
    <body class="$body-class">
    <button class="nav-toggle" aria-label="Menu">☰</button>
    <span class="theme-switch">
    <button class="theme-btn" aria-label="Theme" aria-haspopup="true" aria-expanded="false">◐</button>
    <ul class="theme-menu" hidden>
    <li><button data-theme-set="system"><span class="ti">◐</span> System</button></li>
    <li><button data-theme-set="light"><span class="ti">☀</span> Light</button></li>
    <li><button data-theme-set="dark"><span class="ti">☾</span> Dark</button></li>
    </ul>
    </span>
    $nav
    <main>
    <div class="content">
    $body
    </div>
    <footer>
    <span>A Tour of Raku — every example runs live in your browser via <a href="$playground">raku.online</a>.</span>
    <span>Powered by Raku++ compiled to WebAssembly; nothing leaves your machine. <a href="$repo">Source</a>.</span>
    </footer>
    </main>
    $tour-js
    <script src="/theme/tour.js?v={$VERSION}" defer></script>
    <script src="$engine"></script>
    </body>
    </html>
    HTML
}

sub lesson-footer(@lessons, $l --> Str) {
    my $prev = $l.num > 1               ?? @lessons[$l.num - 2] !! Nil;
    my $next = $l.num < @lessons.elems  ?? @lessons[$l.num]     !! Nil;
    my $left = $prev.defined
        ?? "<a class=\"lnav prev\" href=\"/{$prev.slug}/\"><span class=\"lnav-dir\">← Previous</span>" ~
           "<span class=\"lnav-title\">{esc($prev.title)}</span></a>"
        !! '<span class="lnav"></span>';
    my $right = $next.defined
        ?? "<a class=\"lnav next\" href=\"/{$next.slug}/\"><span class=\"lnav-dir\">Next →</span>" ~
           "<span class=\"lnav-title\">{esc($next.title)}</span></a>"
        !! "<a class=\"lnav next\" href=\"/\"><span class=\"lnav-dir\">Finish ✓</span>" ~
           "<span class=\"lnav-title\">Back to the overview</span></a>";
    # NB: concatenation, not interpolation — "$left<span" would parse as a
    # hash subscript on $left.
    '<div class="lesson-nav">' ~ $left ~
    '<span class="lnav-pos">' ~ $l.num ~ ' / ' ~ @lessons.elems ~ '</span>' ~
    $right ~ '</div>'
}

sub render-lesson(%site, @lessons, $l --> Str) {
    my $r = Renderer.new(lines => $l.body.lines, lesson => $l);
    my $body = $r.render;
    my $head =
        '<div class="page-head">' ~
        "<div class=\"crumb\">{esc($l.chapter)} · lesson {$l.num} of {@lessons.elems}</div>" ~
        "<h1>{esc($l.title)}</h1>" ~
        '</div>';
    $head ~= "<p class=\"summary\">{inline($l.summary)}</p>" if $l.summary;
    page-shell(%site, "{$l.title} — {%site<title>}",
               $head ~ $body ~ lesson-footer(@lessons, $l),
               nav-html(@lessons, $l), tour-script(@lessons, $l))
}

sub render-home(%site, @lessons --> Str) {
    my $examples = @lessons.map({ @($_.examples).elems }).sum;
    my $first    = @lessons[0];
    my @parts =
        "<div class=\"hero\"><h1>{esc(%site<title>)}</h1>" ~
        "<p class=\"tagline\">{esc(%site<tagline>)}</p>" ~
        "<p class=\"hero-stats\">{@lessons.elems} lessons · every example editable, runnable, " ~
        "and verified against the interpreter</p>" ~
        "<p class=\"hero-links\"><a class=\"btn-start\" href=\"/{$first.slug}/\">Start the tour →</a>" ~
        "<a class=\"btn-continue\" id=\"btn-continue\" href=\"\" hidden></a>" ~
        "<button class=\"btn-reset\" id=\"btn-reset\" type=\"button\" hidden>Reset progress</button></p>" ~
        '</div>';

    @parts.push('<div class="overview">');
    for chapters(@lessons) -> %ch {
        @parts.push(
            "<section class=\"ov-cat\"><h2>{esc(%ch<title>)}" ~
            "<span class=\"ov-count\">{@(%ch<lessons>).elems}</span></h2><ul class=\"ov-list\">");
        for @(%ch<lessons>) -> $l {
            @parts.push(
                "<li><a data-slug=\"{esc-attr($l.slug)}\" href=\"/{$l.slug}/\" title=\"{esc-attr($l.summary)}\">" ~
                "<span class=\"tick\" aria-hidden=\"true\"></span>" ~
                "<span class=\"lnum\">{$l.num}.</span> {esc($l.title)}</a></li>");
        }
        @parts.push('</ul></section>');
    }
    @parts.push('</div>');
    page-shell(%site, %site<title>, @parts.join, nav-html(@lessons, Nil),
               tour-script(@lessons, Nil), :home)
}

# ---------------------------------------------------------------------------
# Verification against the real interpreter
# ---------------------------------------------------------------------------

sub run-snippet(Str $exe, Str $code) {
    my $proc = run($exe, '/dev/stdin', :in, :out, :err);
    $proc.in.print($code);
    $proc.in.close;
    my $out = $proc.out.slurp(:close).subst(/ \n+ $ /, '');
    my $err = $proc.err.slurp(:close);
    $out, $err
}

# Verify each example's declared output against Raku++, and — when --oracle is set
# (e.g. --oracle=raku) — against Rakudo too.
sub verify-examples(@lessons, Str $rakupp, Str $oracle --> Int) {
    if $rakupp.contains('/') && !$rakupp.IO.e {
        note "verify: rakupp not found at $rakupp";
        return 1;
    }
    my $has-oracle = $oracle.chars > 0;
    my $checked = 0;
    my $rakupp-fail = 0;
    my $oracle-fail = 0;
    for @lessons -> $l {
        for @($l.examples) -> @ex {
            my ($code, $expected, $line) = @ex;
            next unless $expected.defined;
            $checked++;
            my $want = $expected.subst(/ \n+ $ /, '');

            my ($got, $err) = run-snippet($rakupp, $code);
            if $got ne $want {
                $rakupp-fail++;
                note "  RAKU++ MISMATCH {$l.path}:$line";
                note "    expected: {$want.raku}";
                note "    rakupp:   {$got.raku}";
                note "    stderr:   {$err.trim.raku}" if $err.trim;
            }

            if $has-oracle {
                my ($ogot, $oerr) = run-snippet($oracle, $code);
                if $ogot ne $want {
                    $oracle-fail++;
                    note "  ORACLE MISMATCH ($oracle) {$l.path}:$line";
                    note "    expected: {$want.raku}";
                    note "    oracle:   {$ogot.raku}";
                    note "    stderr:   {$oerr.trim.raku}" if $oerr.trim;
                }
            }
        }
    }
    if $has-oracle {
        say "verify: $checked checked · $rakupp-fail rakupp mismatch(es) · $oracle-fail oracle mismatch(es) vs $oracle";
    }
    else {
        say "verify: $checked example(s) checked, $rakupp-fail mismatch(es)";
    }
    ($rakupp-fail + $oracle-fail) ?? 1 !! 0
}

# ---------------------------------------------------------------------------
# Build driver
# ---------------------------------------------------------------------------

sub MAIN(Bool :$verify = False, Bool :$clean = False,
         Str :$rakupp = RAKUPP-DEFAULT, Str :$oracle = '') {
    my %site = EVAL slurp('src/site.raku');

    if $clean && 'out'.IO.d {
        run('rm', '-rf', 'out');
    }
    mkdir('out');

    $VERSION = asset-version();
    my @lessons = @(collect-lessons());

    # Clean URLs: each lesson is <slug>/index.html, served at /<slug>/.
    for @lessons -> $l {
        mkdir("out/{$l.slug}");
        spurt("out/{$l.slug}/index.html", render-lesson(%site, @lessons, $l));
    }
    spurt('out/index.html', render-home(%site, @lessons));

    mkdir('out/theme');
    for dir('src/theme').grep({ .IO.f }) -> $asset {
        spurt("out/theme/{$asset.IO.basename}", slurp($asset.Str));
    }

    say "built {@lessons.elems} lesson(s) + home -> out/";

    exit verify-examples(@lessons, $rakupp, $oracle) if $verify;
}
