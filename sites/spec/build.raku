#!/usr/bin/env raku
# build.raku — static generator for the Raku++ specification site (spec.raku.online).
#
# Run with rakupp (this whole toolchain is Raku++, dogfooding the interpreter):
#
#   rakupp build.raku                 # build src/ -> out/
#   rakupp build.raku --verify        # build, then run every example through rakupp
#   rakupp build.raku --clean         # remove out/ first
#   rakupp build.raku --rakupp=PATH   # interpreter used for --verify
#
# Each feature is one Markdown-ish file under src/pages/<category>/<slug>.md with a
# small frontmatter block. Fenced ```raku blocks become runnable, syntax-highlighted
# editors via raku.online/raku.js — one shared WebAssembly interpreter, so no copy
# of the engine lives in this repo. A ```raku block may be followed by an ```output
# block giving its expected output; --verify runs each such block through the real
# rakupp binary and fails the build on any mismatch, so the spec cannot drift from
# the interpreter it documents.

# Interpreter used by --verify. Defaults to `rakupp` on PATH; override with
# --rakupp=PATH (deploy.sh pins the exact build via .deploy.env).
constant RAKUPP-DEFAULT = 'rakupp';

# Cache-busting tag stamped onto theme assets (?v=…), set once per build from a
# content hash of all sources — so browsers refetch base.css/spec.js/search.js and
# the search index exactly when their content changes.
my $VERSION = '';
# Where this site is mounted (e.g. '/spec'), and where the shared theme lives.
# Both come from src/site.raku; empty base keeps the site buildable at a root.
my $BASE = '';
my $THEME-DIR = 'src/theme';

# status key => (label, css-class, tooltip)
my %STATUS =
    full      => ('Full',            'st-full', 'Implemented; behaves as documented.'),
    partial   => ('Partial',         'st-part', 'Partly implemented — see notes for gaps.'),
    divergent => ('Divergent',       'st-div',  'Behaves differently from Rakudo — see notes.'),
    ni        => ('Not implemented', 'st-ni',   'Documented for completeness; not yet in Raku++.');

# Theme switcher: 'system' | 'light' | 'dark'. Runs inline in <head> so the resolved
# theme is applied before first paint (no flash). Uses the same 'raku-theme'
# localStorage key name and switcher UI as the raku.online playground for
# consistency (storage is per-origin, so the two subdomains don't share a value).
# Held as a non-interpolating q:to block because the JS is full of { } that a qq
# string would otherwise treat as Raku interpolation.
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
# + escaping — but NOT links. inline() renders links first (whose text may itself
# contain a code span, e.g. `[a `Rat`](url)`), protects each with a plain-ASCII
# sentinel, formats the rest, then splices the links back in. The sentinel is ASCII
# because a NUL or private-use char does not survive rakupp's string handling.
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
        # A link written as /cat/slug/ in the Markdown is site-root-relative;
        # under a mounted base ('/spec') it has to carry the prefix.
        my $href = ~$1;
        $href = $BASE ~ $href if $href.starts-with('/') && !$href.starts-with('//');
        @links.push('<a href="' ~ esc-attr($href) ~ '">' ~ fmt-basic(~$0) ~ '</a>');
        'zXLINKXz' ~ @links.end ~ 'zXENDXz'
    }, :g);
    my $body = fmt-basic($protected);
    $body.subst(/ 'zXLINKXz' (\d+) 'zXENDXz' /, { @links[+$0] }, :g)
}

# Reduce a page's Markdown-ish body to plain searchable text: drop code-fence
# markers (keep their content), heading hashes, list bullets, table pipes, and inline
# markup, and collapse whitespace.
sub index-body(Str $md --> Str) {
    my @out;
    for $md.lines -> $line {
        next if $line.starts-with('```');
        my $t = $line;
        $t = $t.subst(/ ^ \s* '#'+ \s* /, '');
        $t = $t.subst(/ ^ \s* <[\-*]> \s+ /, '');
        $t = $t.subst(/ '[' (<-[ \] ]>+) ']' '(' <-[)]>* ')' /, { ~$0 }, :g);
        $t = $t.subst('`', '', :g).subst('**', '', :g).subst('|', ' ', :g);
        @out.push($t.trim);
    }
    @out.grep(*.chars).join(' ').subst(/ \s+ /, ' ', :g).trim
}

# Escape a string as a JSON string literal (quotes included).
sub json-str(Str $s --> Str) {
    my $e = $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst(/ \t /, ' ', :g).subst(/ \n /, ' ', :g);
    '"' ~ $e ~ '"'
}

# Like json-str but PRESERVES newlines/tabs as \n/\t escapes — for data where the
# line structure is meaningful (example source & expected output), not the search
# index (which deliberately flattens whitespace to one line).
sub json-esc(Str $s --> Str) {
    my $e = $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst("\r", '\\r', :g).subst("\n", '\\n', :g).subst("\t", '\\t', :g);
    '"' ~ $e ~ '"'
}

# Content-derived cache tag stamped onto theme asset URLs (?v=…). Uses cksum:
# POSIX, present on both macOS and Linux, so the build runs anywhere (the CI
# runner included) — unlike md5/md5sum, which differ per OS. rakupp hardcodes
# $*KERNEL.name to "darwin", so we can't branch on the OS anyway. Only needs to
# change when any source changes; the exact digest (CRC vs MD5) is irrelevant.
sub asset-version(--> Str) {
    my @files = dir($THEME-DIR).grep({ .IO.f }).map(*.Str);
    for dir('src/pages').grep({ .IO.d }).sort -> $cat {
        @files.append: dir($cat).grep({ .IO.f && .Str.ends-with('.md') }).map(*.Str);
    }
    @files.push('src/site.raku');
    @files.push('src/data/roast-map.json') if 'src/data/roast-map.json'.IO.e;
    @files.push('src/data/dashboard.json') if 'src/data/dashboard.json'.IO.e;
    my $blob = @files.sort.map({ slurp($_) }).join;
    my $p = run('cksum', :in, :out);
    $p.in.print($blob);
    $p.in.close;
    $p.out.slurp(:close).words[0].substr(0, 8)
}

# Parse a fence info string like `raku run stdin="Ada\nGrace"` into (lang, %opts).
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

class Page {
    has Str $.category;
    has Str $.slug;
    has Str $.title;
    has Str $.status;
    has Str $.summary;
    has Int $.order;
    has Str $.body;
    has Str $.path;
    has Bool $.browser-ok;    # runs in the browser (WASM) engine, not just the interpreter/--exe
    has Str $.browser-why;    # if not: the reason (threads / filesystem / deep recursion)
    has Str $.rakulib;        # 'battery' = examples need the module-battery dists on RAKULIB
    has @.examples is rw;     # list of [code, expected-or-Nil, line-number]
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
    # Itemise the hash so it stays one element when list-assigned by the caller
    # (a bare %meta would greedily slurp the whole returned list).
    $(%meta), $body
}

sub load-page(Str $category, Str $path --> Page) {
    my ($meta, $body) = parse-frontmatter(slurp($path), $path);
    die "$path: frontmatter needs a 'title'" unless $meta<title>;
    my $status = $meta<status> // 'full';
    die "$path: unknown status '$status'" unless %STATUS{$status}:exists;
    Page.new(
        category => $category,
        slug     => $meta<slug> // $path.IO.basename.subst(/ '.md' $ /, ''),
        title    => $meta<title>,
        status   => $status,
        summary  => $meta<summary> // '',
        order       => ($meta<order> // '100').Int,
        body        => $body,
        path        => $path,
        browser-ok  => (($meta<browser> // 'true').lc ne 'false'),
        browser-why => ($meta<browser-why> // ''),
        rakulib     => ($meta<rakulib> // ''),
        examples    => [],
    )
}

# ---------------------------------------------------------------------------
# Markdown-ish renderer (a deliberately small, predictable subset)
# ---------------------------------------------------------------------------

class Renderer {
    has @.lines;
    has @!out;
    has $.page;
    has Int $!i = 0;

    method render(--> Str) {
        while $!i < @.lines.elems {
            my $line = @.lines[$!i];
            if $line !~~ / \S /                          { $!i++ }
            elsif $line.starts-with('```')               { self!fence }
            elsif $line ~~ / ^ '#'+ \s /                 { self!heading($line) }
            elsif $line ~~ / ^ \s* <[\-*]> ' ' /     { self!ulist }
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

    # A list item runs from its bullet/number line until a blank line or the next
    # item; wrapped continuation lines are folded into the same item.
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
            my $expected = self!peek-output;
            $.page.examples.push([$code, $expected, $start]);
            if !$.page.browser-ok {
                # Feature needs threads/IO the browser sandbox lacks: still verified
                # against the interpreter and Rakudo, but shown static (no Run button).
                self!emit-static($code, $expected);
            }
            else {
                my $run = so ($lang eq 'raku-run' || %opts<run>);
                self!emit-runnable($code, %opts, $run, $expected);
            }
        }
        elsif $lang eq 'output' | 'text' {
            @!out.push('<pre class="output"><code>' ~ esc($code) ~ '</code></pre>');
        }
        elsif $lang eq 'syntax' {
            @!out.push('<pre class="syntax"><code>' ~ esc($code) ~ '</code></pre>');
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

    method !emit-runnable(Str $code, %opts, Bool $run, $expected) {
        my @attrs = 'data-raku';
        @attrs.push('data-run') if $run;
        @attrs.push('data-stdin="' ~ esc-attr(%opts<stdin>) ~ '"')
            if %opts<stdin>:exists && %opts<stdin> !=== True;
        @attrs.push('data-rows="' ~ esc-attr(~%opts<rows>) ~ '"')
            if %opts<rows>:exists && %opts<rows> !=== True;
        @!out.push('<pre ' ~ @attrs.join(' ') ~ '>' ~ esc($code) ~ '</pre>');
        if $expected.defined {
            @!out.push(
                '<div class="expected"><span class="expected-label">Output</span>' ~
                '<pre class="output"><code>' ~ esc($expected) ~ '</code></pre></div>');
        }
    }

    # A static, non-runnable example for features the browser engine can't execute
    # (concurrency, IO, deep recursion): the output is real (build-verified against the
    # interpreter + Rakudo), but there is no Run button.
    method !emit-static(Str $code, $expected) {
        @!out.push(
            '<div class="native-ex"><button class="copy-btn" type="button" ' ~
            'title="Copy this code">Copy</button>' ~
            '<pre class="native-code"><code>' ~ esc($code) ~ '</code></pre></div>');
        if $expected.defined {
            @!out.push(
                '<div class="expected"><span class="expected-label">Output</span>' ~
                '<pre class="output"><code>' ~ esc($expected) ~ '</code></pre></div>');
        }
    }
}

# ---------------------------------------------------------------------------
# HTML assembly
# ---------------------------------------------------------------------------

sub nav-html(%site, %by-cat, $current) {
    my @parts = '<nav class="sidebar"><div class="sidebar-head">' ~
        # Both sites, one active — so the way back is always visible, not just a
        # link in the footer.
        '<div class="brandbar"><span class="wordmark">Raku++</span>' ~
        '<span class="siteswitch">' ~
        '<a class="sw active" href="' ~ ($BASE || "/") ~ '">spec</a>' ~
        '<a class="sw" href="' ~ $BASE ~ '/rules/">rules</a>' ~
        '</span></div>' ~
        '<div class="site-search"><input type="search" placeholder="Search the spec…" ' ~
        'aria-label="Search the spec" autocomplete="off" spellcheck="false">' ~
        '<span class="ss-hint" aria-hidden="true">/</span>' ~
        '<div class="ss-results" hidden></div></div></div><div class="sidebar-nav">';
    # The sidebar is an accordion: only one section is expanded at a time. On a
    # page, its own section starts open; on the home page, the first section does.
    my $cur-cat = $current.defined ?? $current.category !! '';
    my $first   = True;
    for @(%site<categories>) -> %cat {
        my @cat-pages = @(%by-cat{ %cat<slug> } // []);
        next unless @cat-pages;   # hide categories with no pages yet
        my $open = ($cur-cat eq %cat<slug>) || ($cur-cat eq '' && $first);
        $first = False;
        my $ocls = $open ?? ' open' !! '';
        my $aria = $open ?? 'true' !! 'false';
        @parts.push(
            "<div class=\"nav-cat$ocls\">" ~
            "<button class=\"nav-cat-title\" type=\"button\" aria-expanded=\"$aria\">" ~
            "<span class=\"nav-cat-chev\" aria-hidden=\"true\"></span>" ~
            "<span class=\"nav-cat-name\">{esc(%cat<title>)}</span></button>" ~
            "<div class=\"nav-cat-body\"><ul>");
        for @cat-pages -> $p {
            my $active = ($current.defined && $p === $current) ?? ' class="active"' !! '';
            @parts.push("<li><a$active href=\"{$BASE}/{$p.category}/{$p.slug}/\">{esc($p.title)}</a></li>");
        }
        @parts.push('</ul></div></div>');
    }
    @parts.push('<div class="nav-extra">' ~
        '<a href="' ~ $BASE ~ '/rules/">Raku Rules — every operator and type →</a>' ~
        ('src/data/6e.raku'.IO.e
            ?? '<a href="' ~ $BASE ~ '/6e/">Raku 6.e support — the next revision →</a>'
            !! '') ~
        '</div>');
    @parts.push('</div></nav>');
    @parts.join
}

sub page-shell(%site, Str $title, Str $body, Str $nav, :$home = False, :$extra-scripts = '' --> Str) {
    # Some page bodies are NON-interpolating heredocs (q:to), because they are
    # mostly literal HTML and a stray `$` or `{` would otherwise need escaping.
    # `{$BASE}` written inside one of those stays literal text, so substitute it
    # here, where every page passes through: the conformance and dashboard pages
    # each shipped a link reading `{$BASE}/…` verbatim, which a browser resolves
    # relative to the current page and 404s. build.sh fails the build if one
    # survives into www/.
    my $body-based = $body.subst('{$BASE}', $BASE, :g);
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
    <script>window.__SITE_BASE={ $BASE ?? "'" ~ $BASE ~ "'" !! "''" };</script>
    <script>{$THEME-SCRIPT}</script>
    <link rel="stylesheet" href="/theme/base.css?v={$VERSION}">
    <link rel="stylesheet" href="/theme/spec.css?v={$VERSION}">
    <link rel="stylesheet" href="/theme/shell.css?v={$VERSION}">
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
    $body-based
    </div>
    <footer>
    <span>Raku++ Specification — behaviour of <a href="$playground">raku.online</a>'s interpreter.</span>
    <span>Examples run live in your browser via WebAssembly, each verified to match native Raku++. <a href="$repo">Source</a>.</span>
    </footer>
    </main>
    <script src="/theme/shell.js?v={$VERSION}" defer></script>
    <script src="/theme/spec.js?v={$VERSION}" defer></script>
    <script src="/theme/search.js?v={$VERSION}" defer></script>
    $extra-scripts
    <script src="$engine"></script>
    </body>
    </html>
    HTML
}

# The Roast conformance map — a special page rendering the committed
# src/data/roast-map.json snapshot into a filterable table (see conformance.js).
sub render-conformance(%site, %by-cat --> Str) {
    my $body = q:to/BODY/;
    <div class="conf-head">
      <h1>Roast conformance</h1>
      <p class="tagline">Where Raku++ stands against <a href="https://github.com/Raku/roast">Roast</a>,
      the official Raku specification test suite — the same tests this spec is verified against.</p>
      <div class="conf-hero" id="conf-hero"></div>
      <div class="conf-denoms" id="conf-denoms"></div>
      <p class="conf-source">Counts and methodology come from Raku++'s own Roast run —
      see <a href="RAKUPP_REPO/blob/main/docs/ROAST.md">ROAST.md</a> (standing &amp;
      per-synopsis breakdown) and <a href="RAKUPP_REPO/blob/main/docs/COUNTING.md">COUNTING.md</a>
      (exact definition of every figure).</p>
    </div>
    <h2 class="conf-areas-title">Execution modes</h2>
    <p class="conf-modes-intro">This is a reference for <strong>Raku++</strong> — the
    interpreter. A program can run three ways, and every example here is verified to give
    the same output in all three; the few features that need capabilities the browser
    sandbox lacks (<a href="{$BASE}/concurrency/promises/">concurrency</a>,
    <a href="{$BASE}/builtins/io/">IO</a>, deep recursion) are marked on their pages.</p>
    <div class="table-wrap"><table class="conf-modes-tbl">
      <thead><tr><th>Mode</th><th>How to run</th><th>Threads</th><th>Files &amp; IO</th><th>Deep recursion</th></tr></thead>
      <tbody>
        <tr><td><strong>Interpreter</strong></td><td><code>rakupp x.raku</code></td><td class="y">✓</td><td class="y">✓</td><td class="y">✓</td></tr>
        <tr><td><strong>Native</strong></td><td><code>rakupp --exe x.raku</code></td><td class="y">✓</td><td class="y">✓</td><td class="y">✓</td></tr>
        <tr><td><strong>Browser</strong></td><td>the playground (raku.js)</td><td class="n">✗</td><td class="n">✗</td><td class="n">~200 levels max</td></tr>
      </tbody>
    </table></div>
    <h2 class="conf-areas-title">By synopsis <span>— tests passing of those declared, per area</span></h2>
    <div class="conf-controls">
      <input type="search" id="conf-search" placeholder="Filter features…" aria-label="Filter features" autocomplete="off" spellcheck="false">
      <div class="conf-filters" id="conf-filters"></div>
    </div>
    <div class="conf-table" id="conf-table" aria-live="polite">Loading the conformance map…</div>
    BODY
    $body = $body.subst('RAKUPP_REPO', esc-attr(%site<rakupp>), :g);
    my $extra = "<script src=\"/theme/conformance.js?v={$VERSION}\" defer></script>";
    page-shell(%site, 'Roast conformance — Raku++ Specification', $body,
               nav-html(%site, %by-cat, Nil), :extra-scripts($extra))
}

# The dashboard — Raku++ by the numbers over releases, rendered client-side by
# dashboard.js from the committed src/data/dashboard.json snapshot (mined from
# the repos' own docs by tools/gen-dashboard.raku; re-run it at each release).
# Its five section headings carry an id and the `#` link base.css shows on hover,
# the same markup the tour, the FAQ, the cookbook and the spec's own pages emit —
# a chart is a thing people link someone else to. `optbench` keeps the id it has
# always had, so links already written to it still resolve.
sub render-dashboard(%site, %by-cat --> Str) {
    my $body = q:to/BODY/;
    <div class="conf-head">
      <h1>Dashboard</h1>
      <p class="tagline">Raku++ by the numbers, release over release — the
      <a href="{$BASE}/conformance/">Roast</a> standing, the ecosystem module battery,
      and the benchmark kernels. Every point is mined from numbers committed in
      the repos' own docs; nothing is measured at build time.</p>
      <div class="conf-stats" id="dash-tiles"></div>
    </div>
    <h2 class="conf-areas-title" id="roast">Roast <span>— tests passing and fully-passing files, per release</span> <a class="anchor" href="#roast" aria-label="link">#</a></h2>
    <p class="dash-note">A file counts as <em>fully passing</em> only when every
    single test in it passes — one failure anywhere and the whole file drops out
    of the count. That strict bar is why the right-hand number is small next to
    the 90% of individual tests passing on the left. Both series start before
    the first tag, mined from ROAST.md's own git history — one point per day;
    the %-series begins on Jul 10, when the current "declared" denominator was
    defined (earlier percentages used a different counting method and would not
    be comparable).</p>
    <div class="dash-bench" id="dash-roast" aria-live="polite">Loading…</div>
    <h2 class="conf-areas-title" id="documentation-conformance">Documentation conformance <span>— every documented example, run three ways</span> <a class="anchor" href="#documentation-conformance" aria-label="link">#</a></h2>
    <p class="dash-note">The same coloured verdicts the
    <a href="{$BASE}/conformance/">conformance page</a> shows as dots, counted over
    time. <em>ok</em> is the one to watch: documentation, Rakudo and Raku++ all
    agreeing. <em>Raku++ differs</em> is the work list. The other three are not
    ours to fix — <em>docs stale</em> is where both engines agree against the
    documentation, <em>Rakudo differs</em> where Rakudo is the odd one out, and
    <em>needs a human</em> where all three disagree. Each point is one run of
    the comparison, not one release, so the line is only as dense as the
    snapshot has been taken.</p>
    <div class="dash-chart" id="dash-conformance"></div>
    <h2 class="conf-areas-title" id="ecosystem">Ecosystem <span>— how many modules run under Raku++</span> <a class="anchor" href="#ecosystem" aria-label="link">#</a></h2>
    <p class="dash-note">The whole Raku ecosystem — every distribution in the
    REA index, latest release of each — swept end to end: a dist counts when
    <em>its own</em> test suite passes under Raku++.
    <a href="https://raku.online/modules/ecosystem/">Every distribution and its
    result, listed →</a></p>
    <div class="dash-chart" id="dash-modules"></div>
    <h2 class="conf-areas-title" id="benchmarks">Benchmarks <span>— kernel wall time in ms, lower is better</span> <a class="anchor" href="#benchmarks" aria-label="link">#</a></h2>
    <p class="dash-note">Three ways to run the same program: the Raku++
    interpreter, the same source compiled to a native binary with
    <code>--exe</code>, and Rakudo as the reference — plus, on
    <code>hashfill</code> alone, the same program in Perl 5 as a second
    dashed reference. All ten kernels of the BENCHMARKS.md tables, ordered as
    that file orders them — string building first, where the gap is widest,
    down to the closest-run kernels — plus <code>startup</code>, the eleventh
    program in <code>tools/bench/</code>, last. (<code>startup</code> was a row
    in the tables early on, left them for a long stretch, and returned as its
    own section on 2026-08-22, so its series has a real gap in the middle.)
    Use the <em>log</em> scale when you want to read the distance between the
    interpreter and <code>--exe</code>: on a linear axis every chart is bounded
    by its Rakudo line, which squeezes both Raku++ series onto the baseline —
    worst on exactly the kernels where the lead is largest. Absolute times as
    committed at each release; the measuring machine changed at v3.6.0 (the
    file's own note records it), so read ratios across that boundary, not
    milliseconds. A point labelled by <em>date</em> rather than a version is a
    re-measure of <code>main</code> between releases: every sitting is kept as
    its own point, so a fresh measurement adds to the series instead of
    overwriting the last reading. A kernel is missing from a point only when that release's
    table did not carry it — except <code>hashfill</code>, whose tagged points
    are <em>retrospective</em>: every tagged release binary from GitHub,
    re-run on one machine in one sitting (2026-08-21), with that day's Rakudo
    and perl as fixed references — the one series here that is comparable in
    milliseconds end to end. (Its <code>main</code> point comes from the
    committed tables like every other kernel's, so the last step carries
    ordinary sitting-to-sitting noise.)</p>
    <div class="dash-bench" id="dash-bench"></div>

    <h2 id="optbench">The <code>-O</code> optimizer <a class="anchor" href="#optbench" aria-label="link">#</a></h2>
    <p class="dash-note">A different comparison from the kernels above: the
    same five programs of <a
    href="https://github.com/ash/rakupp/tree/main/tools/optbench">tools/optbench/</a>
    compiled twice — plain <code>--exe</code> against <code>--exe -O</code>,
    with Rakudo alongside as the reference. The interpreter does not appear
    because <code>-O</code> is a codegen flag. Each program is written to
    exercise one of the speculative passes, and is verified to produce
    identical output all four ways before anything is timed. <strong>This
    series has a point only where the table was actually re-measured</strong>
    — the <code>-O</code> table is not re-run every release, and it was carried
    forward unchanged from v1.0.0 to v3.6.0, so drawing a point per release
    would show a dozen sittings agreeing where there was one sitting repeated.
    Gaps here mean "not measured", not "unchanged".</p>
    <div class="dash-bench" id="dash-optbench"></div>
    BODY
    my $extra = "<script src=\"/theme/chart.js?v={$VERSION}\" defer></script>" ~
                "<script src=\"/theme/dashboard.js?v={$VERSION}\" defer></script>";
    page-shell(%site, 'Dashboard — Raku++ Specification', $body,
               nav-html(%site, %by-cat, Nil), :extra-scripts($extra))
}

# Where a feature runs: the three execution targets. Interpreter and --exe run
# everything; the browser (WASM) engine is the only constrained one, and a page marks
# itself `browser: false` (+ optional `browser-why`) when a feature needs threads, the
# filesystem, or deep recursion.
sub modes-html($page --> Str) {
    my $ok  = $page.browser-ok;
    my $why = $page.browser-why || 'needs threads, the filesystem, or deep recursion';
    my $tip = $ok ?? 'Runs in the browser playground (raku.js / WebAssembly)'
                  !! "Not in the browser playground — $why";
    my $head = '<div class="modes" title="Where this feature runs">' ~
    '<span class="mode ok" title="rakupp — the Raku++ tree-walking interpreter">' ~
      '<span class="mk">✓</span> Interpreter</span>' ~
    '<span class="mode ok" title="rakupp --exe — compiled to a standalone native binary">' ~
      '<span class="mk">✓</span> Native (--exe)</span>';
    # Module pages (rakulib: battery): the playground simply has no module
    # installation — an environment limitation, not a feature gap — so no
    # ✗ Browser chip; the page prose explains why examples are static.
    if $page.rakulib {
        return $head ~ '</div>';
    }
    $head ~
    "<span class=\"mode {$ok ?? 'ok' !! 'no'}\" title=\"{esc-attr($tip)}\">" ~
      "<span class=\"mk\">{$ok ?? '✓' !! '✗'}</span> Browser</span>" ~
    '</div>'
}

sub render-page(%site, $page, %by-cat --> Str) {
    my ($label, $cls, $tip) = @(%STATUS{ $page.status });
    my $r = Renderer.new(lines => $page.body.lines, page => $page);
    my $body = $r.render;
    my $cat-title = @(%site<categories>).first({ .<slug> eq $page.category })<title> // $page.category;
    my $head =
        '<div class="page-head">' ~
        "<div class=\"crumb\">{esc($cat-title)}</div>" ~
        "<h1>{esc($page.title)}</h1>" ~
        "<span class=\"status $cls\" title=\"{esc-attr($tip)}\">{$label}</span>" ~
        '</div>';
    $head ~= "<p class=\"summary\">{inline($page.summary)}</p>" if $page.summary;
    # This is a Raku++ reference: features run everywhere by default, so the
    # three-mode indicator only appears where the browser engine is the exception.
    $head ~= modes-html($page) unless $page.browser-ok;
    page-shell(%site, "{$page.title} — {%site<title>}", $head ~ $body, nav-html(%site, %by-cat, $page))
}

# Count the demonstrated features on a page: each `## ` section (bar Notes and the
# "excels" divergence note) is one named feature with its own example. Fence-aware
# so `##` inside code never counts.
sub count-features(Str $body --> Int) {
    my $n = 0;
    my $in-fence = False;
    for $body.lines -> $line {
        if $line.starts-with('```') { $in-fence = !$in-fence; next }
        next if $in-fence;
        $n++ if $line.starts-with('## ')
             && !$line.starts-with('## Notes')
             && $line.trim ne EXCELS-HEADING;
    }
    $n
}

# Heading that marks a page's "Raku++ goes beyond Rakudo" section. The build
# collects every one of these into the /excels/ index (render-excels), so the list
# stays current automatically — add the section to a page and it shows up there.
constant EXCELS-HEADING = '## Where Raku++ excels';

# Pull the excels section out of a page body: the lines after EXCELS-HEADING, up to
# the next `## ` heading or end of file. Fence-aware so a `##` inside a code block
# never ends it. Returns '' when the page has no such section.
sub extract-excels(Str $body --> Str) {
    my @lines = $body.lines;
    my $in-fence = False;
    my $start = -1;
    my $i = 0;
    while $i < @lines.elems {
        my $line = @lines[$i];
        if $line.starts-with('```') {
            $in-fence = !$in-fence;
        }
        elsif !$in-fence && $line.starts-with('## ') {
            last if $start >= 0;                              # next section ends it
            $start = $i + 1 if $line.trim eq EXCELS-HEADING;
        }
        $i++;
    }
    $start < 0 ?? '' !! @lines[$start ..^ $i].join("\n").trim
}

sub render-home(%site, %by-cat --> Str) {
    my @cats-with-pages = @(%site<categories>).grep({ @(%by-cat{ .<slug> } // []).elems });
    my $pages    = @cats-with-pages.map({ @(%by-cat{ .<slug> }).elems }).sum;
    my $features = @cats-with-pages
        .map({ |@(%by-cat{ .<slug> }) })
        .map({ count-features($_.body) }).sum;

    my $excels-link = excels-entries(%site, %by-cat)
        ?? ' <a href="' ~ $BASE ~ '/excels/">Where Raku++ excels →</a>' !! '';
    my @parts =
        "<div class=\"hero\"><h1>{esc(%site<title>)}</h1>" ~
        "<p class=\"tagline\">{esc(%site<tagline>)}</p>" ~
        "<p class=\"hero-stats\">$features features across $pages pages · " ~
        "every example verified against Raku++, Rakudo, and the in-browser engine</p>" ~
        "<p class=\"hero-links\"><a href=\"{$BASE}/rules/\">Raku Rules — the exhaustive reference →</a>" ~
        " <a href=\"{$BASE}/conformance/\">See the full Roast conformance map →</a>" ~
        ('src/data/dashboard.json'.IO.e ?? ' <a href="' ~ $BASE ~ '/dashboard/">Dashboard →</a>' !! '') ~
        ('src/data/6e.raku'.IO.e ?? ' <a href="' ~ $BASE ~ '/6e/">Raku 6.e support →</a>' !! '') ~
        "{$excels-link}</p>" ~
        '</div>';

    # Status legend.
    @parts.push('<div class="legend">');
    for <full partial divergent ni> -> $s {
        my ($label, $cls, $) = @(%STATUS{$s});
        @parts.push("<span class=\"leg\"><span class=\"dot $cls\"></span>{$label}</span>");
    }
    @parts.push('</div>');

    # Compact overview: one panel per category, flowing in columns.
    @parts.push('<div class="overview">');
    for @cats-with-pages -> %cat {
        my @pages = @(%by-cat{ %cat<slug> });
        @parts.push(
            "<section class=\"ov-cat\"><h2>{esc(%cat<title>)}" ~
            "<span class=\"ov-count\">{@pages.elems}</span></h2><ul class=\"ov-list\">");
        for @pages -> $p {
            my ($label, $cls, $) = @(%STATUS{ $p.status });
            @parts.push(
                "<li><a href=\"{$BASE}/{$p.category}/{$p.slug}/\" title=\"{esc-attr($p.summary)}\">" ~
                "<span class=\"dot $cls\" title=\"{$label}\"></span>{esc($p.title)}</a></li>");
        }
        @parts.push('</ul></section>');
    }
    @parts.push('</div>');
    page-shell(%site, %site<title>, @parts.join, nav-html(%site, %by-cat, Nil), :home)
}

# The /excels/ index: one entry per page that carries a "Where Raku++ excels"
# section, in category order. Each entry re-renders that section's own Markdown (so
# its runnable example works here too) under a heading linking back to the feature
# page. Auto-collected — no hand-maintained list.
sub excels-entries(%site, %by-cat) {
    my @out;
    for @(%site<categories>) -> %cat {
        for @(%by-cat{ %cat<slug> } // []) -> $p {
            my $md = extract-excels($p.body);
            next unless $md;
            @out.push({ cat => %cat<title>, page => $p, md => $md });
        }
    }
    @out
}

sub render-excels(%site, %by-cat --> Str) {
    my @entries = excels-entries(%site, %by-cat);
    my $intro = q:to/BODY/;
    <div class="conf-head">
      <h1>Where Raku++ excels</h1>
      <p class="tagline">Places where Raku++ accepts and runs code the reference
      implementation does not — constructs Rakudo rejects at compile time or leaves
      unimplemented. Every example below runs live in your browser.</p>
    </div>
    BODY
    my @cards;
    for @entries -> %e {
        my $p = %e<page>;
        my $rendered = Renderer.new(lines => %e<md>.lines, page => $p).render;
        @cards.push(
            '<section class="excel-item">' ~
            "<div class=\"crumb\">{esc(%e<cat>)}</div>" ~
            "<h2><a href=\"{$BASE}/{$p.category}/{$p.slug}/\">{esc($p.title)}</a></h2>" ~
            $rendered ~
            '</section>');
    }
    my $body = $intro ~ '<div class="excels">' ~ @cards.join ~ '</div>';
    page-shell(%site, 'Where Raku++ excels — Raku++ Specification', $body,
               nav-html(%site, %by-cat, Nil))
}

# ---------------------------------------------------------------------------
# Verification against the real interpreter
# ---------------------------------------------------------------------------

sub run-snippet(Str $exe, Str $code, :@libs, Str :$sep = ':') {
    # module examples: the vendored battery dists go on RAKULIB (rakupp splits
    # on ':', Rakudo on ',' — the caller passes the right separator)
    my %env = %*ENV;
    %env<RAKULIB> = @libs.join($sep) if @libs;
    my $proc = run($exe, '/dev/stdin', :in, :out, :err, :env(%env));
    $proc.in.print($code);
    $proc.in.close;
    my $out = $proc.out.slurp(:close).subst(/ \n+ $ /, '');
    my $err = $proc.err.slurp(:close);
    $out, $err
}

# Verify each example's declared output against Raku++, and — when --oracle is set
# (e.g. --oracle=raku) — against Rakudo too. The declared output should equal
# Rakudo's (the authority); an oracle mismatch means the author didn't consult it,
# a rakupp-only mismatch means a genuine divergence (mark the page `divergent`).
sub verify-examples(@pages, Str $rakupp, Str $oracle, Str $wasm = '', Str $battery = '' --> Int) {
    if $rakupp.contains('/') && !$rakupp.IO.e {
        note "verify: rakupp not found at $rakupp";
        return 1;
    }
    # The vendored dists of the module battery (github raku-module-battery):
    # pages marked `rakulib: battery` run their examples with these on RAKULIB,
    # so `use JSON::Fast` etc. resolve to the same pinned copies the battery
    # itself verifies. Without a battery checkout those examples are SKIPPED
    # (with a note), never silently passed.
    my @battery-libs;
    if $battery && $battery.IO.d {
        my $tsv = $battery.IO.add('harness/tier3-modules.tsv');
        if $tsv.e {
            @battery-libs = $tsv.lines.map({ .split("\t")[3] }).grep(*.defined).grep(*.chars)
                                .map({ $battery.IO.add($_).add('lib').Str });
        }
    }
    my $has-oracle = $oracle.chars > 0;
    my $checked = 0;
    my $skipped = 0;
    my $rakupp-fail = 0;
    my $oracle-fail = 0;
    my @wasm-ex;                       # examples to also run through raku.js (WASM)
    for @pages -> $page {
        my @libs;
        if $page.rakulib eq 'battery' {
            if !@battery-libs {
                $skipped += @($page.examples).grep({ .[1].defined }).elems;
                note "verify: no battery checkout at '$battery' — skipping {$page.path}";
                next;
            }
            @libs = @battery-libs;
        }
        for @($page.examples) -> @ex {
            my ($code, $expected, $line) = @ex;
            next unless $expected.defined;
            $checked++;
            my $want = $expected.subst(/ \n+ $ /, '');
            # Pages the browser engine can't run (concurrency/IO/deep recursion) are
            # verified against rakupp + Rakudo but excluded from the WASM gate.
            @wasm-ex.push({ p => "{$page.path}:$line", s => $code, e => $want })
                if $wasm && $page.browser-ok;

            my ($got, $err) = run-snippet($rakupp, $code, :@libs, :sep(':'));
            if $got ne $want {
                $rakupp-fail++;
                note "  RAKU++ MISMATCH {$page.path}:$line";
                note "    expected: {$want.raku}";
                note "    rakupp:   {$got.raku}";
                note "    stderr:   {$err.trim.raku}" if $err.trim;
            }

            if $has-oracle {
                my ($ogot, $oerr) = run-snippet($oracle, $code, :@libs, :sep(','));
                if $ogot ne $want {
                    $oracle-fail++;
                    note "  ORACLE MISMATCH ($oracle) {$page.path}:$line";
                    note "    expected: {$want.raku}";
                    note "    oracle:   {$ogot.raku}";
                    note "    stderr:   {$oerr.trim.raku}" if $oerr.trim;
                }
            }
        }
    }
    if $has-oracle {
        say "verify: $checked checked · $rakupp-fail rakupp mismatch(es) · $oracle-fail oracle mismatch(es) vs $oracle"
            ~ ($skipped ?? " · $skipped SKIPPED (no battery)" !! '');
    }
    else {
        say "verify: $checked example(s) checked, $rakupp-fail mismatch(es)";
    }

    # Third gate: run every example through the Node build of raku.js — the same
    # engine the browser editors use — so an example that passes native Raku++ but
    # breaks in the browser (e.g. the recursion cap) is caught here, not by users.
    my $wasm-fail = 0;
    if $wasm {
        if !$wasm.IO.e {
            note "verify: raku.js engine not found at $wasm — skipping the WASM gate";
        }
        else {
            my $json = '[' ~ @wasm-ex.map({
                '{"p":' ~ json-esc(.<p>) ~ ',"s":' ~ json-esc(.<s>) ~ ',"e":' ~ json-esc(.<e>) ~ '}'
            }).join(',') ~ ']';
            spurt('out/.wasm-examples.json', $json);
            my $proc = run('bun', 'tools/wasm-verify.cjs', $wasm, 'out/.wasm-examples.json',
                           :out, :err);
            print $proc.out.slurp(:close);
            my $werr = $proc.err.slurp(:close);
            note $werr.trim if $werr.trim;
            $wasm-fail = $proc.exitcode == 0 ?? 0 !! 1;
        }
    }

    ($rakupp-fail + $oracle-fail + $wasm-fail) ?? 1 !! 0
}

# ---------------------------------------------------------------------------
# Build driver
# ---------------------------------------------------------------------------

sub collect-pages(%site) {
    my %known = @(%site<categories>).map({ .<slug> => True });
    my @pages;
    for dir('src/pages').grep({ .IO.d }).sort -> $cat-dir {
        my $cat = $cat-dir.IO.basename;
        note "warning: category dir '$cat' not listed in site.raku" unless %known{$cat};
        for dir($cat-dir).grep({ .IO.f && .Str.ends-with('.md') }).sort -> $md {
            @pages.push(load-page($cat, $md.Str));
        }
    }
    my %by-cat;
    %by-cat{ .category }.push($_) for @pages;
    for %by-cat.keys -> $k {
        %by-cat{$k} = %by-cat{$k}.sort({ (.order, .title) }).Array;
    }
    # Itemise both so neither is slurped by a greedy container on the receiving end.
    $(@pages), $(%by-cat)
}

# The 6.e support matrix. One section per change the 6.e language revision makes
# to 6.d, each carrying the same snippet run three times — Rakudo under 6.d,
# Rakudo under 6.e, Raku++ under 6.e — and a verdict derived from those three
# outputs rather than asserted. The data is src/data/6e.raku, written by
# tools/gen-6e.raku; re-run that after an engine change and the page re-scores
# itself. The prose companion is the FAQ article at raku.online/faq/6e.
sub render-sixe(%site, %by-cat --> Str) {
    my %d     = EVAL slurp('src/data/6e.raku');
    my $total = %d<counts>.values.sum;
    my @parts;

    @parts.push('<div class="conf-head"><h1>Raku 6.e support</h1>');
    @parts.push('<p class="tagline">What the <strong>6.e</strong> language revision changes about ' ~
        '<strong>6.d</strong>, and whether Raku++ changes it too. Turn it on with ' ~
        '<code>use v6.e.PREVIEW;</code> as the first statement — in Rakudo and in Raku++ alike.</p>');

    @parts.push('<div class="sixe-summary">');
    for <full partial divergent ni> -> $s {
        my ($label, $cls, $) = @(%STATUS{$s});
        @parts.push("<span class=\"sixe-tile\"><span class=\"dot $cls\"></span>" ~
                    "<b>{%d<counts>{$s} // 0}</b><span>{$label}</span></span>");
    }
    @parts.push("<span class=\"sixe-tile sixe-total\"><b>{$total}</b><span>changes tracked</span></span>");
    @parts.push('</div>');

    # Support is one question; whether the pragma is what turns it on is another.
    if %d<gating> {
        @parts.push('<div class="sixe-summary sixe-gating">');
        @parts.push("<span class=\"sixe-tile\"><b>{%d<gating><gated> // 0}</b>" ~
                    '<span>gated on <code>use v6.e.PREVIEW</code></span></span>');
        @parts.push("<span class=\"sixe-tile\"><b>{%d<gating><default-on> // 0}</b>" ~
                    '<span>on by default in Raku++, pragma or not</span></span>');
        @parts.push('</div>');
    }

    @parts.push('<p class="sixe-prov">Each entry is one snippet run <strong>four</strong> ' ~
        'times — both engines under both revisions — because "does Raku++ do this?" and ' ~
        '"does the pragma turn it on?" are different questions. Raku++ describes itself as ' ~
        'implementing 6.d <em>with 6.e features</em>, and the fourth row is where that shows: ' ~
        'a good deal of 6.e is simply on, pragma or not. The verdict scores the 6.e column ' ~
        'against Rakudo\'s; the 6.d column is there so nobody ports code on a wrong assumption.</p>');
    @parts.push('<p class="sixe-prov">Every output is a real run, not a prediction: ' ~
        "<strong>Rakudo {esc(%d<rakudo>)}</strong> and <strong>{esc(%d<rakupp>)}</strong>, " ~
        "measured {esc(%d<generated>)}. The verdict follows one rule — <em>Full</em> when Raku++ " ~
        'gives what Rakudo gives under 6.e, or refuses what 6.e refuses; <em>Not implemented</em> ' ~
        'when Raku++ says the thing does not exist; <em>Divergent</em> when it runs and answers ' ~
        'something else. <em>Partial</em> is the one verdict set by hand, because "there, but not ' ~
        'all the way there" is a judgement no comparison of outputs can make. ' ~
        'The prose version of all this, with the reasoning and the sources, is ' ~
        '<a href="/faq/6e/">What Raku 6.e adds to 6.d</a>.</p>');
    @parts.push('</div>');

    # Jump list: the groups, with how many of each are fully supported.
    @parts.push('<div class="sixe-jump">');
    for @(%d<groups>) -> %g {
        my $full = @(%g<items>).grep({ .<status> eq 'full' }).elems;
        @parts.push("<a href=\"#{%g<slug>}\">{esc(%g<title>)} " ~
                    "<span>{$full}/{@(%g<items>).elems}</span></a>");
    }
    @parts.push('</div>');

    for @(%d<groups>) -> %g {
        @parts.push("<h2 class=\"conf-areas-title\" id=\"{%g<slug>}\">{esc(%g<title>)}</h2>");
        @parts.push("<p class=\"sixe-intro\">{esc(%g<intro>)}</p>");
        for @(%g<items>) -> %i {
            my ($label, $cls, $tip) = @(%STATUS{ %i<status> });
            @parts.push("<section class=\"sixe-item\" id=\"{%i<id>}\">");
            @parts.push("<h3><span class=\"dot $cls\" title=\"{esc-attr($tip)}\"></span>" ~
                        "<a href=\"#{%i<id>}\">{esc(%i<title>)}</a>" ~
                        "<span class=\"status $cls\">{$label}</span></h3>");
            @parts.push("<p class=\"sixe-note\">{esc(%i<note>)}</p>");
            @parts.push('<pre class="native-code"><code class="lang-raku">' ~
                        esc(%i<code>) ~ '</code></pre>');
            @parts.push('<div class="table-wrap"><table class="sixe-out"><tbody>');
            for ('Rakudo 6.d', %i<d>),  ('Rakudo 6.e', %i<e>),
                ('Raku++ 6.d', %i<ppd>), ('Raku++ 6.e', %i<pp>) -> ($who, $out) {
                my $shown = $out eq '' ?? '<span class="sixe-silent">(no output)</span>'
                                       !! '<code>' ~ esc($out) ~ '</code>';
                @parts.push("<tr><th>{$who}</th><td>{$shown}</td></tr>");
            }
            @parts.push('</tbody></table></div>');
            given %i<gating> {
                when 'gated' {
                    @parts.push('<p class="sixe-why">Raku++ gates this on the pragma: ' ~
                        'without <code>use v6.e.PREVIEW</code> it does the 6.d thing.</p>');
                }
                when 'default-on' {
                    @parts.push('<p class="sixe-why sixe-default-on">Raku++ does this ' ~
                        '<strong>without the pragma too</strong> — under 6.d, where Rakudo ' ~
                        'still does the old thing.</p>');
                }
            }
            @parts.push("<p class=\"sixe-why\">{esc(%i<why>)}</p>") if %i<why>;
            @parts.push('<p class="sixe-why">Rakudo needs its RakuAST frontend for this one ' ~
                        '(<code>RAKUDO_RAKUAST=1</code>); Raku++ does not.</p>') if %i<rakuast>;
            @parts.push('<p class="sixe-why">6.d and 6.e agree here — the row is kept for ' ~
                        'completeness.</p>') unless %i<changed>;
            @parts.push('</section>');
        }
    }

    page-shell(%site, 'Raku 6.e support — Raku++ Specification', @parts.join,
               nav-html(%site, %by-cat, Nil))
}


sub MAIN(Bool :$verify = False, Bool :$clean = False, Str :$rakupp = RAKUPP-DEFAULT, Str :$oracle = '', Str :$wasm = '',
         Str :$battery = (%*ENV<HOME> // '') ~ '/raku-module-battery') {
    my %site = EVAL slurp('src/site.raku');
    $BASE      = %site<base>      // '';
    $THEME-DIR = %site<theme-dir> // 'src/theme';

    if $clean && 'out'.IO.d {
        run('rm', '-rf', 'out');
    }
    mkdir('out');

    $VERSION = asset-version();
    my ($pages, $by-cat) = collect-pages(%site);

    # Clean URLs: each page is <cat>/<slug>/index.html, served at /<cat>/<slug>/
    # (no .html extension). mkdir creates parent dirs too.
    for @($pages) -> $p {
        mkdir("out/{$p.category}/{$p.slug}");
        spurt("out/{$p.category}/{$p.slug}/index.html", render-page(%site, $p, $by-cat));
    }
    spurt('out/index.html', render-home(%site, $by-cat));

    # Roast conformance map (special page + its committed data snapshot).
    if 'src/data/roast-map.json'.IO.e {
        mkdir('out/conformance');
        spurt('out/conformance/index.html', render-conformance(%site, $by-cat));
        spurt('out/roast-map.json', slurp('src/data/roast-map.json'));
    }

    # Release dashboard (special page + its committed data snapshot).
    if 'src/data/dashboard.json'.IO.e {
        mkdir('out/dashboard');
        spurt('out/dashboard/index.html', render-dashboard(%site, $by-cat));
        spurt('out/dashboard.json', slurp('src/data/dashboard.json'));
    }

    # The 6.e support matrix (special page + its committed measurement snapshot).
    if "src/data/6e.raku".IO.e {
        mkdir("out/6e");
        spurt("out/6e/index.html", render-sixe(%site, $by-cat));
    }

    # "Where Raku++ excels" index — emitted only when some page carries the section.
    my @excels = excels-entries(%site, $by-cat);
    if @excels {
        mkdir('out/excels');
        spurt('out/excels/index.html', render-excels(%site, $by-cat));
        say "  excels: {@excels.elems} entr{ @excels.elems == 1 ?? 'y' !! 'ies' } -> out/excels/";
    }

    # Client-side search index: one {u,t,b} record per page, loaded by search.js.
    my @entries;
    for @($pages) -> $p {
        my $u = "{$BASE}/{$p.category}/{$p.slug}/";
        my $b = ($p.summary ~ ' ' ~ index-body($p.body)).trim;
        # Cap generously so every term on a page stays searchable (the old 1800
        # limit truncated longer pages, hiding tail content like `samewith` from
        # search); 8000 covers every current page in full.
        $b = $b.substr(0, 8000) if $b.chars > 8000;
        @entries.push('{"u":' ~ json-str($u) ~ ',"t":' ~ json-str($p.title)
                        ~ ',"b":' ~ json-str($b) ~ '}');
    }
    spurt('out/search-index.json', '[' ~ @entries.join(',') ~ ']');

    # The theme is shared across the whole of raku.online and is placed at the
    # site root by the top-level build, so a sub-site must not ship its own copy.
    # Standalone builds (no theme-out => False in the config) still copy it.
    if %site<theme-out> // True {
        mkdir('out/theme');
        for dir($THEME-DIR).grep({ .IO.f }) -> $asset {
            spurt("out/theme/{$asset.IO.basename}", slurp($asset.Str));
        }
    }

    say "built {@($pages).elems} page(s) + home -> out/";

    exit verify-examples(@($pages), $rakupp, $oracle, $wasm, $battery) if $verify;
}
