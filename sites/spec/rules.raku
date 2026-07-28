#!/usr/bin/env raku
# rules.raku — static generator for the Raku Rules site (spec 2.0),
# published as a sub-site at /rules/ alongside the spec.
#
#   rakupp rules.raku                      # build src/rules -> out/rules
#   rakupp rules.raku --verify             # run every example through rakupp
#   rakupp rules.raku --oracle=raku        # …and diff it against Rakudo too
#
# What makes this different from build.raku (spec 1.0):
#
#   * The menu is exhaustive by construction. tools/inventory.raku extracts every
#     operator the official documentation describes — with the precedence level
#     it is documented under — and probes rakupp to see which spellings it
#     parses. Anything with no hand-written page still gets one, pre-filled with
#     those machine facts and marked as a skeleton. Nothing can be silently
#     missing: the coverage page counts what is written against what exists.
#
#   * A page is a numbered set of RULES, not prose. Each `###` heading under
#     `## Rules` becomes a citable, anchored rule (`infix-plus.R3`); the same
#     applies to `## Traps` (T) and `## Errors` (E). A rule should carry a
#     runnable example, and --verify holds every declared output to the real
#     interpreter.
#
#   * Rules are sourced by triangulation: the documentation says what exists,
#     running both engines says what actually happens, and the Raku++ sources say
#     why. Rakudo's grammar is deliberately NOT read — see tools/inventory.raku.

constant RAKUPP-DEFAULT = 'rakupp';

my $VERSION = '';
my %INV;              # the extracted inventory
my %MATRIX;           # the differential behaviour matrix (tools/matrix.raku)
my %TYPEDOC;          # the type & routine reference (tools/typedoc.raku)
my %TYPERUN;          # three-way example results (tools/typerun.raku)
my %TYPE-OF;          # page slug -> its typedoc record
my %ADJUDGED;         # hand-written rulings on disagreements (see src/rules/adjudications.raku)
my @HISTORY;          # one snapshot per run (src/data/history.jsonl), oldest first
my %SOLO;             # topic -> its only entry's slug, where a topic has just one
my %SITE;

# status key => (label, css-class, tooltip)
my %STATUS =
    written  => ('Written',   'st-full', 'Hand-written and verified.'),
    partial  => ('Partial',   'st-part', 'Some rules written; more to come.'),
    skeleton => ('Skeleton',  'st-skel', 'Machine-extracted facts only — rules not written yet.'),
    gap      => ('Gap',       'st-div',  'Raku++ does not parse this spelling.'),
    reference => ('Reference', 'st-ref',
        'Signatures and hierarchy taken from the official documentation; examples run on both engines.');

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
# Text helpers
# ---------------------------------------------------------------------------

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
}
sub esc-attr(Str $s --> Str) { esc($s).subst('"', '&quot;', :g) }

sub slugify(Str $s is copy --> Str) {
    $s = $s.subst(/ '<' <-[>]>* '>' /, '', :g);
    $s = $s.lc;
    $s = $s.subst(/ <-[ a..z 0..9 \s \- ]> /, '', :g);
    $s = $s.subst(/ \s+ /, '-', :g);
    $s
}

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
    # The URL may itself contain a parenthesised group — the set-operator anchors
    # on docs.raku.org look like `#infix_(.),_infix_⊍`. Allow one level of nesting
    # so the link does not end at the first `)`.
    my $protected = $text.subst(/ '[' (<-[ \] ]>+) ']' '(' ( [ <-[()]> || '(' <-[()]>* ')' ]+ ) ')' /, {
        # Markdown links are written against the old site root (spec.raku.online),
        # which is now mounted at /spec — so a leading / needs that prefix.
        my $href = ~$1;
        $href = (%SITE<spec-base> // '') ~ $href
            if $href.starts-with('/') && !$href.starts-with('//');
        @links.push('<a href="' ~ esc-attr($href) ~ '">' ~ fmt-basic(~$0) ~ '</a>');
        'zXLINKXz' ~ @links.end ~ 'zXENDXz'
    }, :g);
    my $body = fmt-basic($protected);
    $body.subst(/ 'zXLINKXz' (\d+) 'zXENDXz' /, { @links[+$0] }, :g)
}

sub json-str(Str $s --> Str) {
    my $e = $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst(/ \t /, ' ', :g).subst(/ \n /, ' ', :g);
    '"' ~ $e ~ '"'
}

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

sub parse-info(Str $info) {
    my $lang = $info.words ?? $info.words[0] !! '';
    my %opts;
    my $rest = $info.subst(/ ^ \s* \S+ /, '');
    # NB: a literal " inside a <-[...]> class breaks rakupp's regex parser, so
    # the quote is written as \x22 here.
    for $rest ~~ m:g/ (\w+) [ '="' (<-[\x22]>*) '"' ]? / -> $m {
        %opts{ ~$m[0] } = $m[1].defined ?? (~$m[1]).subst('\n', "\n", :g) !! True;
    }
    $lang, %opts
}

sub asset-version(--> Str) {
    my @files = dir('src/theme').grep({ .IO.f }).map(*.Str);
    for dir('src/rules/pages').grep({ .IO.d }).sort -> $t {
        @files.append: dir($t).grep({ .IO.f && .Str.ends-with('.md') }).map(*.Str);
    }
    @files.push('src/rules/site.raku');
    @files.push('src/data/inventory.raku');
    @files.push('src/data/matrix.raku') if 'src/data/matrix.raku'.IO.e;
    my $blob = @files.sort.map({ slurp($_) }).join;
    my $p = run('cksum', :in, :out);
    $p.in.print($blob);
    $p.in.close;
    $p.out.slurp(:close).words[0].substr(0, 8)
}

# ---------------------------------------------------------------------------
# Naming: a stable, readable URL slug for an arbitrary operator spelling
# ---------------------------------------------------------------------------

# Curated names for spellings that deserve better than a character-by-character
# transliteration. Everything not listed falls through to %CHARNAME below, so
# adding an operator never requires touching this table.
my %OPNAME =
    '+'  => 'plus',        '-'  => 'minus',       '*'  => 'times',
    '/'  => 'divide',      '**' => 'power',       '%'  => 'modulo',
    '%%' => 'divisible',   '!%%' => 'not-divisible',
    '~'  => 'concat',      '=='  => 'numeric-eq', '!=' => 'numeric-ne',
    '<'  => 'numeric-lt',  '>'   => 'numeric-gt',
    '<=' => 'numeric-le',  '>='  => 'numeric-ge',
    '<=>' => 'numeric-cmp', '='  => 'assign',     ':=' => 'bind',
    '::=' => 'readonly-bind',
    '=~=' => 'approx-eq',  '===' => 'value-identity', '=:=' => 'container-identity',
    '~~' => 'smartmatch',  '!~~' => 'not-smartmatch',
    '&&' => 'tight-and',   '||'  => 'tight-or',   '^^' => 'tight-xor',
    '//' => 'defined-or',  '!'   => 'not',        '?'  => 'boolify',
    '..' => 'range',       '..^' => 'range-excl-end', '^..' => 'range-excl-start',
    '^..^' => 'range-excl-both',
    '...' => 'sequence',   '...^' => 'sequence-excl',
    '++' => 'increment',   '--'  => 'decrement',
    '=>' => 'fatarrow',    ','   => 'comma',      ';' => 'semicolon',
    '==>' => 'feed-forward', '<==' => 'feed-backward',
    '+&' => 'numeric-and', '+|'  => 'numeric-or', '+^' => 'numeric-xor',
    '~&' => 'string-and',  '~|'  => 'string-or',  '~^' => 'string-xor',
    '?&' => 'boolean-and', '?|'  => 'boolean-or', '?^' => 'boolean-xor',
    '+<' => 'shift-left',  '+>'  => 'shift-right',
    '~<' => 'string-shift-left', '~>' => 'string-shift-right',
    '&'  => 'all-junction', '|'  => 'any-junction', '^' => 'one-junction',
    '[ ]' => 'brackets',   '( )' => 'parens',     '{ }' => 'braces',
    '« »' => 'french-quotes', '<< >>' => 'double-angles',
    '×' => 'times-sign',   '÷' => 'division-sign', '−' => 'minus-sign',
    '∘' => 'compose',      '≠' => 'ne-sign',      '≤' => 'le-sign', '≥' => 'ge-sign',
    '≅' => 'approx-sign',  '≡' => 'identical',    '≢' => 'not-identical',
    '∩' => 'intersection', '∪' => 'union',        '∖' => 'set-difference',
    '⊖' => 'symmetric-difference', '⊎' => 'baggy-add', '⊍' => 'baggy-multiply',
    '∈' => 'elem-sign',    '∉' => 'not-elem-sign',
    '∋' => 'contains-sign', '∌' => 'not-contains-sign',
    '⊂' => 'proper-subset', '⊃' => 'proper-superset',
    '⊆' => 'subset-or-eq', '⊇' => 'superset-or-eq',
    '⊄' => 'not-proper-subset', '⊅' => 'not-proper-superset',
    '⊈' => 'not-subset',   '⊉' => 'not-superset',
    '≼' => 'baggy-subset', '≽' => 'baggy-superset',
    '∅' => 'empty-set',    'ⁿ' => 'superscript-power',
    '(|)' => 'set-union',  '(&)' => 'set-intersection', '(-)' => 'set-minus',
    '(^)' => 'set-symdiff', '(+)' => 'bag-add', '(.)' => 'bag-multiply',
    '(elem)' => 'set-elem', '(cont)' => 'set-cont',
    '(<)' => 'set-subset', '(>)' => 'set-superset',
    '(<=)' => 'set-subset-eq', '(>=)' => 'set-superset-eq',
    '(<+)' => 'baggy-subset-ascii', '(>+)' => 'baggy-superset-ascii',
    '(==)' => 'set-equal', '(!=)' => 'set-not-equal', '(<>)' => 'set-disjoint',
    '.'  => 'dot',         '.='  => 'dot-assign',  '.^' => 'meta-dot',
    '.?' => 'safe-dot',    '.*'  => 'all-dot',     '.+' => 'some-dot',
    '?? !!' => 'ternary',  '->' => 'pointy',       '<->' => 'rw-pointy',
    '»' => 'hyper-right',  '«' => 'hyper-left',
    '@' => 'at-sigil',     '$'  => 'dollar-sigil', '%' => 'percent-sigil',
    ;

my %CHARNAME =
    '+' => 'plus',  '-' => 'minus', '*' => 'star',   '/' => 'slash',
    '%' => 'pct',   '=' => 'eq',    '<' => 'lt',     '>' => 'gt',
    '!' => 'bang',  '?' => 'q',     '~' => 'tilde',  '&' => 'amp',
    '|' => 'pipe',  '^' => 'caret', '.' => 'dot',    ',' => 'comma',
    ':' => 'colon', ';' => 'semi',  '@' => 'at',     '$' => 'dollar',
    '#' => 'hash',  '(' => 'lparen', ')' => 'rparen',
    '[' => 'lbrack', ']' => 'rbrack', '{' => 'lbrace', '}' => 'rbrace',
    '\\' => 'bslash', '\'' => 'squote', '"' => 'dquote', ' ' => '-',
    '…' => 'ellipsis', '‘' => 'lsquote', '’' => 'rsquote',
    ;

sub op-name(Str $sym --> Str) {
    return %OPNAME{$sym} if %OPNAME{$sym}:exists;
    return $sym if $sym ~~ / ^ <[a..z A..Z 0..9 _ \-]>+ $ /;
    my @parts;
    for $sym.comb -> $c {
        @parts.push(%CHARNAME{$c}:exists ?? %CHARNAME{$c} !! 'u' ~ $c.ord.base(16).lc);
    }
    @parts.join('-').subst(/ '-'+ /, '-', :g)
}

# The URL slug for an inventory entry: category prefix + readable name, so
# `infix:<+>` and `prefix:<+>` never collide.
sub op-slug(%op --> Str) {
    my $cat = %op<cat>
        .subst('_prefix_meta_operator', '-meta')
        .subst('_postfix_meta_operator', '-meta')
        .subst('_circumfix_meta_operator', '-meta')
        .subst('statement_prefix', 'stmt')
        .subst('statement_control', 'stmt')
        .subst('trait_mod', 'trait')
        .subst('_', '-');
    $cat ~ '-' ~ op-name(%op<sym>)
}

# Which topic an extracted construct belongs to.
sub op-topic(%op --> Str) {
    given %op<cat> {
        when 'statement_control' { 'control' }
        when 'statement_prefix'  { 'control' }
        when 'trait_mod'         { 'routines' }
        when 'term'              { 'terms' }
        when 'quote'             { 'terms' }
        default                  { 'operators' }
    }
}

# Which section within that topic. For the operator categories this is the
# precedence level under its own Rakudo name — so the menu IS the ladder.
sub op-section(%op --> Str) {
    given %op<cat> {
        when 'statement_control' { 'statement controls' }
        when 'statement_prefix'  { 'statement prefixes' }
        when 'trait_mod'         { 'traits' }
        when 'term'              { 'named terms' }
        when 'quote'             { 'quoting forms' }
        when 'circumfix'         { 'circumfixes' }
        when 'postcircumfix'     { 'postcircumfixes' }
        when 'dotty'             { 'postfix dotty forms' }
        default {
            %op<cat>.contains('meta') ?? 'metaoperators' !! (%op<level> // 'unclassified')
        }
    }
}

# Pod inline markup, as it appears in the documentation source, reduced to the
# Markdown subset this generator understands. C<> is code, B<> bold, I<> italic,
# and L<text|/type/Int> is a link into docs.raku.org. Both the angle and the
# doubled-angle spellings occur.
sub pod-inline(Str $s is copy --> Str) {
    for <C B I K T R> -> $f {
        $s = $s.subst(/ $f '«' (<-[«»]>*) '»' /, { pod-wrap($f, ~$0) }, :g);
        $s = $s.subst(/ $f '<' (<-[<>]>*) '>' /, { pod-wrap($f, ~$0) }, :g);
    }
    # L<display text|/target> — keep the text, point the link at the docs site
    $s = $s.subst(/ 'L«' (<-[«»]>*) '»' /, { pod-link(~$0) }, :g);
    $s = $s.subst(/ 'L<' (<-[<>]>*) '>' /, { pod-link(~$0) }, :g);
    # X<indexed term|category> — only the display half is wanted
    $s = $s.subst(/ 'X«' (<-[«»|]>*) '|' <-[«»]>* '»' /, { ~$0 }, :g);
    $s = $s.subst(/ 'X<' (<-[<>|]>*) '|' <-[<>]>* '>' /, { ~$0 }, :g);
    $s
}

sub pod-wrap(Str $f, Str $t --> Str) {
    given $f {
        when 'B' { '**' ~ $t ~ '**' }
        when 'I' { '*' ~ $t ~ '*' }
        default  { '`' ~ $t ~ '`' }
    }
}

sub pod-link(Str $body --> Str) {
    my ($text, $target) = $body.contains('|') ?? $body.split('|', 2) !! ($body, $body);
    $text = $text.subst(/ ^ 'C<' /, '').subst(/ '>' $ /, '')
                 .subst(/ ^ 'C«' /, '').subst(/ '»' $ /, '');
    return '`' ~ $text ~ '`' unless $target.starts-with('/');
    '[' ~ $text ~ '](https://docs.raku.org' ~ $target ~ ')'
}

# ---------------------------------------------------------------------------
# Document model
# ---------------------------------------------------------------------------

class Entry {
    has Str  $.topic;
    has Str  $.section is rw;
    has Str  $.slug;
    has Str  $.title;
    has Str  $.summary;
    has Str  $.status;
    has Int  $.order;
    has Str  $.body;
    has Str  $.path;         # source .md, or '' for an auto-stub
    has      %.op is rw;     # inventory facts, if this entry has a symbol
    has Bool $.browser-ok;
    has @.examples is rw;    # [code, expected-or-Nil, line]
    has @.rules    is rw;    # [id, title, anchor]
    has @.divergences is rw; # [code, line] — claims that the engines differ here
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
        my $val = $v.trim;
        # A symbol like `[ ]` or `:` has to be quotable in frontmatter.
        if $val.chars >= 2 && ($val.starts-with('"') && $val.ends-with('"')
                            || $val.starts-with("'") && $val.ends-with("'")) {
            $val = $val.substr(1, $val.chars - 2);
        }
        %meta{ $k.trim } = $val;
    }
    $(%meta), $body
}

# ---------------------------------------------------------------------------
# Markdown-ish renderer with rule numbering
# ---------------------------------------------------------------------------

class Renderer {
    has @.lines;
    has @!out;
    has $.entry;
    has Int $!i = 0;
    has Str $!kind = '';     # 'R' | 'T' | 'E' — set by the enclosing h2
    has Int $!n = 0;

    method render(--> Str) {
        while $!i < @.lines.elems {
            my $line = @.lines[$!i];
            if $line !~~ / \S /                              { $!i++ }
            elsif $line.starts-with('```')                    { self!fence }
            elsif $line ~~ / ^ '#'+ \s /                      { self!heading($line) }
            elsif $line ~~ / ^ \s* <[\-*]> ' ' /              { self!ulist }
            elsif $line ~~ / ^ \s* \d+ '.' ' ' /              { self!olist }
            elsif $line.starts-with('>')                      { self!quote }
            elsif $line ~~ / ^ \s* '|' / && self!table-ahead  { self!table }
            else                                              { self!paragraph }
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

    # An h2 opens (or closes) a numbered region; an h3 inside one is a rule.
    method !heading(Str $line) {
        my $hashes = ($line ~~ / ^ ('#'+) /)[0].chars;
        my $text = $line.substr($hashes).trim;

        if $hashes == 2 {
            my $s = slugify($text);
            my $was = $!kind;
            $!kind = do given $s {
                when 'rules'                          { 'R' }
                when 'traps' || 'traps--gotchas'      { 'T' }
                when 'errors' || 'error-messages'     { 'E' }
                default                               { '' }
            };
            $!n = 0 if $!kind ne $was;   # each region numbers from 1
            my $anchor = $s;
            @!out.push(
                "<h2 id=\"$anchor\" class=\"sec\">" ~ inline($text) ~
                " <a class=\"anchor\" href=\"#$anchor\" aria-label=\"link\">#</a></h2>");
            $!i++;
            return;
        }

        if $hashes == 3 && $!kind {
            $!n++;
            my $id = $!kind ~ $!n;
            $.entry.rules.push([$id, $text, $id]);
            @!out.push(
                "<h3 id=\"$id\" class=\"rule\">" ~
                "<a class=\"rule-id\" href=\"#$id\" title=\"Rule {$.entry.slug}.$id\">{$id}</a> " ~
                inline($text) ~ "</h3>");
            $!i++;
            return;
        }

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
        $!i += 2;
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
        $!i++;
        my $code = @buf.join("\n");
        my ($lang, %opts) = parse-info($info);

        if $lang eq 'raku' || $lang eq 'raku-run' {
            my $expected = self!peek-output;
            $.entry.examples.push([$code, $expected, $start]);
            if !$.entry.browser-ok {
                self!emit-static($code, $expected);
            }
            else {
                my $run = so ($lang eq 'raku-run' || %opts<run>);
                self!emit-runnable($code, %opts, $run, $expected);
            }
        }
        elsif $lang eq 'output' || $lang eq 'text' {
            @!out.push('<pre class="output"><code>' ~ esc($code) ~ '</code></pre>');
        }
        elsif $lang eq 'syntax' {
            @!out.push('<pre class="syntax"><code>' ~ esc($code) ~ '</code></pre>');
        }
        # An example that is EXPECTED to fail: shown, never run, never verified
        # as output — the point is the diagnostic, not a value.
        elsif $lang eq 'bad' {
            @!out.push('<pre class="bad"><code>' ~ esc($code) ~ '</code></pre>');
        }
        # A CLAIMED divergence: the prose around it says the two engines differ
        # here. --verify runs it on both and fails if they now agree, so a page
        # cannot go on describing a divergence after it has been fixed.
        elsif $lang eq 'diverge' {
            $.entry.divergences.push([$code, $start]);
            @!out.push('<div class="diverge"><span class="diverge-tag" ' ~
                'title="The two engines are asserted to differ here; the build ' ~
                'fails if they stop differing.">engines differ</span>' ~
                '<pre><code>' ~ esc($code) ~ '</code></pre></div>');
        }
        else {
            my $cls = $lang ?? " class=\"lang-{esc-attr($lang)}\"" !! '';
            @!out.push("<pre$cls><code>" ~ esc($code) ~ '</code></pre>');
        }
    }

    method !peek-output {
        my $j = $!i;
        $j++ while $j < @.lines.elems && @.lines[$j] !~~ / \S /;
        return Str unless $j < @.lines.elems && @.lines[$j].starts-with('```');
        my ($lang, $) = parse-info(@.lines[$j].substr(3));
        return Str unless $lang eq 'output' || $lang eq 'text';
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

    method !emit-static(Str $code, $expected) {
        @!out.push(
            '<div class="native-ex"><span class="native-tag" title="Runs in the Raku++ ' ~
            'interpreter and --exe binary, but not the browser playground.">not in browser</span>' ~
            '<pre class="native-code"><code>' ~ esc($code) ~ '</code></pre></div>');
        if $expected.defined {
            @!out.push(
                '<div class="expected"><span class="expected-label">Output</span>' ~
                '<pre class="output"><code>' ~ esc($expected) ~ '</code></pre></div>');
        }
    }
}

# ---------------------------------------------------------------------------
# Collecting entries: hand-written pages first, then auto-stubs for every
# construct the inventory knows about that nobody has written up yet.
# ---------------------------------------------------------------------------

sub load-written(--> Array) {
    my @out;
    my $root = 'src/rules/pages';
    return @out unless $root.IO.d;
    for dir($root).grep({ .IO.d }).sort -> $tdir {
        my $topic = $tdir.IO.basename;
        for dir($tdir).grep({ .IO.f && .Str.ends-with('.md') }).sort -> $f {
            my ($meta, $body) = parse-frontmatter(slurp($f.Str), $f.Str);
            die "$f: frontmatter needs a 'title'" unless $meta<title>;
            my $status = $meta<status> // 'written';
            die "$f: unknown status '$status'" unless %STATUS{$status}:exists;
            @out.push: Entry.new(
                topic      => $topic,
                section    => ($meta<section> // 'overview'),
                slug       => ($meta<slug> // $f.IO.basename.subst(/ '.md' $ /, '')),
                title      => $meta<title>,
                summary    => ($meta<summary> // ''),
                status     => $status,
                order      => (($meta<order> // '100').Int),
                body       => $body,
                path       => $f.Str,
                op         => %(),
                browser-ok => (($meta<browser> // 'true').lc ne 'false'),
                examples   => [],
                rules      => [],
                divergences => [],
            );
        }
    }
    @out
}

# The prose an unwritten construct gets. No invented rules — but everything the
# extraction genuinely established, so a skeleton is still worth landing on:
# where the construct sits in the ladder, what shares that level, what the
# interpreter said when asked, and where the official docs cover it.
sub stub-body(%op, %siblings --> Str) {
    my $sym  = %op<sym>;
    my $cat  = %op<cat>.subst('_', ' ', :g);
    my @b;

    @b.push("The rules for `$sym` have not been written yet. Everything below is");
    @b.push("extracted rather than authored: the official documentation supplies the");
    @b.push("classification, and the interpreters were asked directly about the rest.");
    @b.push('');

    @b.push('## What is established');
    @b.push('');

    if (%op<level> // '').chars {
        my $level = %op<level>;
        my $assoc = %op<assoc> // '';
        @b.push("### Classification");
        @b.push('');
        my $art = $cat ~~ / ^ <[aeiou]> / ?? 'an' !! 'a';
        @b.push("`$sym` is parsed as $art **$cat**" ~
                ($level ?? " at the **$level** precedence level" !! '') ~
                ($assoc ?? ", **$assoc**-associative" !! '') ~ '.');
        @b.push('');
        if %op<rank>:exists {
            my $n = %op<rank> + 1;
            my $of = @(%INV<ladder>).elems;
            @b.push("That is level $n of $of on the ladder, counting from the tightest.");
            @b.push("Operators sharing a level bind equally; grouping among them is decided");
            @b.push("by associativity alone.");
            @b.push('');
        }
    }

    # Everything else declared at the same precedence level — the single most
    # useful thing to know about an operator you have not met before.
    my @sibs = @(%siblings{ %op<level> // '' } // []).grep({ $_[0] ne $sym });
    if @sibs {
        @b.push("### Shares its precedence level with");
        @b.push('');
        @b.push(@sibs.map({ '[`' ~ $_[0] ~ '`](' ~ $_[1] ~ ')' }).join(', ') ~ '.');
        @b.push('');
        @b.push("These all bind equally tightly, so an expression mixing them groups by");
        @b.push("associativity alone.");
        @b.push('');
    }

    if %op<probe>:exists {
        @b.push("### What the interpreter said");
        @b.push('');
        @b.push(%op<rakupp>
            ?? "Raku++ **parses** this spelling. Asked to compile:"
            !! "Raku++ **does not parse** this spelling. Asked to compile:");
        @b.push('');
        @b.push('```syntax');
        @b.push(%op<probe>);
        @b.push('```');
        @b.push('');
        @b.push(%op<rakupp>
            ?? "…it got through the parser. On its own that establishes very little: " ~
               "it says nothing about whether the construct *executes*, let alone " ~
               "whether the result is right. Where the behaviour table below exists, " ~
               "that is the stronger evidence — those expressions were actually run."
            !! "…it produced a parse error. Any rule written here would describe Raku the language rather than this implementation.");
        @b.push('');
    }

    if %op<doc>:exists {
        @b.push("### Covered upstream");
        @b.push('');
        @b.push("The official documentation has a section for this construct: " ~
                "[docs.raku.org]({%op<doc>}). Until the rules here are written, that is " ~
                "the better reference.");
        @b.push('');
    }
    else {
        @b.push("### Not covered upstream");
        @b.push('');
        @b.push("No section on docs.raku.org matches this category and spelling, so there " ~
                "is no fuller reference to fall back on — which makes this page worth " ~
                "writing sooner rather than later.");
        @b.push('');
    }

    if %op<obs>:exists {
        @b.push('## Errors');
        @b.push('');
        @b.push("### Rejected spelling");
        @b.push('');
        @b.push("Raku deliberately rejects this form and says so: *{%op<obs>}*. It is");
        @b.push("recognised only so the error can be a useful one rather than a parse failure.");
        @b.push('');
    }

    @b.join("\n")
}

sub stub-entry(%op, %siblings --> Entry) {
    my $sym = %op<sym>;
    my $cat = %op<cat>.subst('_', ' ', :g);
    my $status = (%op<rakupp>:exists && !%op<rakupp>) ?? 'gap' !! 'skeleton';
    Entry.new(
        topic      => op-topic(%op),
        section    => op-section(%op),
        slug       => op-slug(%op),
        title      => $sym,
        summary    => "$cat $sym",
        status     => $status,
        order      => 500,
        body       => stub-body(%op, %siblings),
        path       => '',
        op         => %op,
        browser-ok => True,
        examples   => [],
        rules      => [],
        divergences => [],
    )
}

# A type page: what the type IS (hierarchy), then what it can DO (routines with
# their real signatures and return types). Both come from the documentation
# source, so the page cannot drift from it by being retyped.
sub type-body(%t --> Str) {
    my @b;
    my $name = %t<name>;

    # (the subtitle is already the page summary — not repeated here)
    @b.push('## What it is');
    @b.push('');
    if (%t<decl> // '').chars {
        @b.push('```syntax');
        @b.push(%t<decl>);
        @b.push('```');
        @b.push('');
    }

    my @isa   = @(%t<isa>   // []);
    my @does  = @(%t<does>  // []);
    my @kids  = @(%t<children>  // []);
    my @cons  = @(%t<consumers> // []);
    if @isa || @does || @kids || @cons {
        @b.push('### Position in the hierarchy');
        @b.push('');
        @b.push('| | |');
        @b.push('|---|---|');
        @b.push('| Inherits from | ' ~ (@isa  ?? @isa.map({ type-link($_) }).join(', ')  !! '—') ~ ' |') ;
        @b.push('| Does | '          ~ (@does ?? @does.map({ type-link($_) }).join(', ') !! '—') ~ ' |');
        @b.push('| Inherited by | '  ~ (@kids ?? @kids.map({ type-link($_) }).join(', ') !! '—') ~ ' |') if @kids;
        @b.push('| Consumed by | '   ~ (@cons ?? @cons.map({ type-link($_) }).join(', ') !! '—') ~ ' |') if @cons;
        @b.push('');
    }

    my @routines = @(%t<routines> // []).grep({ .<name>.chars });
    if @routines {
        @b.push('## Routines');
        @b.push('');
        @b.push('Signatures are reproduced from the documentation, including their');
        @b.push('declared return types. A routine listed here is part of the type\'s');
        @b.push('published interface; whether Raku++ implements it is a separate question,');
        @b.push('answered by the examples below.');
        @b.push('');
        for @routines -> %r {
            @b.push('### ' ~ %r<kind> ~ ' ' ~ '`' ~ %r<name> ~ '`');
            @b.push('');
            if @(%r<sigs>) {
                @b.push('```syntax');
                @b.append(@(%r<sigs>));
                @b.push('```');
                @b.push('');
            }
            my @ret = @(%r<returns>).unique;
            @b.push('**Returns** ' ~ @ret.map({ '`' ~ $_ ~ '`' }).join(' or ') ~ '.') if @ret;
            @b.push('') if @ret;
            @b.push(pod-inline(%r<summary>)) if %r<summary>.chars;
            @b.push('');
        }
    }
    @b.join("\n")
}

sub type-link(Str $n --> Str) {
    '[`' ~ $n ~ '`](' ~ base() ~ '/types/' ~ type-slug($n) ~ '/)'
}

sub type-slug(Str $n --> Str) {
    $n.subst('::', '-', :g).lc
}

sub collect-entries(--> Array) {
    my @entries = load-written();
    my %taken;
    for @entries -> $e { %taken{ $e.topic ~ '/' ~ $e.slug } = $e }

    # Attach inventory facts to hand-written pages that name a symbol, so an
    # author never has to restate precedence or associativity.
    my %by-sym;
    for @(%INV<ops>) -> %op {
        %by-sym{ %op<cat> ~ '|' ~ %op<sym> } = %op;
    }
    for @entries -> $e {
        my $p = $e.path;
        next unless $p;
        my ($meta, $) = parse-frontmatter(slurp($p), $p);
        next unless $meta<sym>:exists && $meta<cat>:exists;
        my $key = $meta<cat> ~ '|' ~ $meta<sym>;
        die "$p: no such construct in the inventory: {$meta<cat>}:<{$meta<sym>}>"
            unless %by-sym{$key}:exists;
        $e.op = %by-sym{$key};
        # The section is a machine fact (the precedence level), so a page that
        # names its symbol never has to state it.
        $e.section = op-section(%by-sym{$key});
        %taken{ 'sym:' ~ $key } = $e;
    }

    # Precedence level -> the constructs on it, for the "shares its level with"
    # cross-links on every skeleton.
    my %siblings;
    for @(%INV<ops>) -> %op {
        next unless (%op<level> // '').chars;
        %siblings{ %op<level> } //= [];
        %siblings{ %op<level> }.push([ %op<sym>, base() ~ '/' ~ op-topic(%op) ~ '/' ~ op-slug(%op) ~ '/' ]);
    }

    # One page per documented type, filed under the documentation's own category.
    for @(%TYPEDOC<types> // []) -> %t {
        next unless (%t<name> // '').chars;
        my $slug = type-slug(%t<name>);
        next if %taken{ 'types/' ~ $slug }:exists;
        my $e = Entry.new(
            topic      => 'types',
            section    => (%t<category> // 'uncategorised'),
            slug       => $slug,
            title      => %t<name>,
            summary    => (%t<subtitle> // ''),
            status     => 'reference',
            order      => 500,
            body       => type-body(%t),
            path       => '',
            op         => %(),
            browser-ok => True,
            examples   => [],
            rules      => [],
            divergences => [],
        );
        %taken{ 'types/' ~ $slug } = $e;
        %TYPE-OF{ $slug } = %t;
        @entries.push($e);
    }

    for @(%INV<ops>) -> %op {
        my $key = 'sym:' ~ %op<cat> ~ '|' ~ %op<sym>;
        next if %taken{$key}:exists;
        my $e = stub-entry(%op, %siblings);
        next if %taken{ $e.topic ~ '/' ~ $e.slug }:exists;
        %taken{ $e.topic ~ '/' ~ $e.slug } = $e;
        @entries.push($e);
    }
    @entries
}

# ---------------------------------------------------------------------------
# Grouping & ordering
# ---------------------------------------------------------------------------

# Sections inside the operators topic follow the real precedence ladder
# (tightest first); everything without a precedence trails it in a fixed order.
my @TAIL-SECTIONS = 'metaoperators', 'circumfixes', 'postcircumfixes',
                    'postfix dotty forms', 'named terms', 'quoting forms',
                    'statement controls', 'statement prefixes', 'traits',
                    'unclassified', 'overview';

sub section-rank(Str $section --> Int) {
    my @ladder = @(%SITE<ladder>);
    my $i = @ladder.first({ $_ eq $section }, :k);
    return $i if $i.defined;
    my $j = @TAIL-SECTIONS.first({ $_ eq $section }, :k);
    return 100 + $j if $j.defined;
    200
}

sub group-entries(@entries) {
    my %by-topic;
    for @entries -> $e {
        %by-topic{ $e.topic } //= %();
        %by-topic{ $e.topic }{ $e.section } //= [];
        %by-topic{ $e.topic }{ $e.section }.push($e);
    }
    for %by-topic.values -> %secs {
        for %secs.values -> @list {
            @list = @list.sort({ .order ~ '|' ~ .title });
        }
    }
    %by-topic
}

sub topic-title(Str $slug --> Str) {
    for @(%SITE<topics>) -> %t { return %t<title> if %t<slug> eq $slug }
    $slug
}

# ---------------------------------------------------------------------------
# HTML assembly
# ---------------------------------------------------------------------------

sub base(--> Str) { %SITE<base> }

# A topic with a single entry has no index worth showing — a grid of one card is
# pure indirection — so the entry is rendered at the topic's own URL and gets no
# separate page. Everything that links to it (nav, cards, search, symbol index)
# goes through here, so collapsing it in one place is enough.
sub url-of($e --> Str) {
    return base() ~ '/' ~ $e.topic ~ '/' if (%SOLO{ $e.topic } // '') eq $e.slug;
    base() ~ '/' ~ $e.topic ~ '/' ~ $e.slug ~ '/'
}

sub status-badge(Str $status --> Str) {
    my ($label, $cls, $tip) = @(%STATUS{$status});
    "<span class=\"status $cls\" title=\"{esc-attr($tip)}\">{esc($label)}</span>"
}

# Sidebar label: the spelling first (that is what people scan for), then the
# name once a page has one.
sub nav-label($e --> Str) {
    return esc($e.title) unless $e.op;
    my $code = '<code>' ~ esc($e.op<sym>) ~ '</code>';
    return $code if $e.title eq $e.op<sym>;
    $code ~ '<span class="nav-name">' ~ esc($e.title) ~ '</span>'
}

sub nav-html(%by-topic, $current --> Str) {
    my @parts = '<nav class="sidebar"><div class="sidebar-head">' ~
        # Both sites, one active — so the way back to the spec is always visible,
        # not just a link in the footer.
        '<div class="brandbar"><span class="wordmark">Raku++</span>' ~
        '<span class="siteswitch">' ~
        '<a class="sw" href="' ~ (%SITE<spec-base> // '/') ~ '">spec</a>' ~
        '<a class="sw active" href="' ~ base() ~ '/">rules</a>' ~
        '</span></div>' ~
        '<div class="site-search"><input type="search" placeholder="Search the rules…" ' ~
        'aria-label="Search the rules" autocomplete="off" spellcheck="false">' ~
        '<span class="ss-hint" aria-hidden="true">/</span>' ~
        '<div class="ss-results" hidden></div></div></div><div class="sidebar-nav">';

    my $cur-topic   = $current.defined ?? $current.topic   !! '';
    my $cur-section = $current.defined ?? $current.section !! '';

    for @(%SITE<topics>) -> %t {
        my %secs = %(%by-topic{ %t<slug> } // %());
        next unless %secs;
        my $open = ($cur-topic eq %t<slug>);
        my $ocls = $open ?? ' open' !! '';
        my $aria = $open ?? 'true' !! 'false';
        my $count = %secs.values.map(*.elems).sum;
        @parts.push(
            "<div class=\"nav-cat$ocls\">" ~
            "<button class=\"nav-cat-title\" type=\"button\" aria-expanded=\"$aria\">" ~
            "<span class=\"nav-cat-chev\" aria-hidden=\"true\"></span>" ~
            "<span class=\"nav-cat-name\">{esc(%t<title>)}</span>" ~
            "<span class=\"nav-count\">{$count}</span></button>" ~
            '<div class="nav-cat-body">');

        for %secs.keys.sort({ section-rank($_).fmt('%03d') }) -> $sec {
            my @list = @(%secs{$sec});
            my $sopen = ($open && $cur-section eq $sec);
            my $scls  = $sopen ?? ' open' !! '';
            @parts.push(
                "<div class=\"nav-sec$scls\">" ~
                "<button class=\"nav-sec-title\" type=\"button\">{esc($sec)}" ~
                "<span class=\"nav-count\">{@list.elems}</span></button>" ~
                '<div class="nav-sec-body"><ul>');
            for @list -> $e {
                my $active = ($current.defined && $e === $current) ?? ' class="active"' !! '';
                my $label = nav-label($e);
                # NB: {$label} must be braced — "$label</a>" would parse the </a> as a
                # postcircumfix subscript on $label and swallow it.
                @parts.push("<li><a$active href=\"{url-of($e)}\">{$label}</a></li>");
            }
            @parts.push('</ul></div></div>');
        }
        @parts.push('</div></div>');
    }
    @parts.push('<div class="nav-extra">' ~
        '<a href="' ~ base() ~ '/symbols/">Symbol index</a>' ~
        '<a href="' ~ base() ~ '/coverage/">Coverage</a>' ~
        '<a href="' ~ base() ~ '/divergences/">Where things diverge</a>' ~
        '<a href="' ~ %SITE<spec> ~ '">Spec 1.0 →</a>' ~
        '</div>');
    @parts.push('</div></nav>');
    @parts.join
}

sub page-shell(Str $title, Str $body, Str $nav, :$home = False --> Str) {
    my $engine     = esc-attr(%SITE<engine>);
    my $playground = esc-attr(%SITE<playground>);
    my $repo       = esc-attr(%SITE<repo>);
    my $body-class = $home ?? 'home rules' !! 'rules';
    my $b = base();
    qq:to/HTML/
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{esc($title)}</title>
    <script>{$THEME-SCRIPT}</script>
    <link rel="stylesheet" href="/theme/base.css?v={$VERSION}">
    <!-- The Rules site is part of the spec, so it needs the spec's own layer
         too: the wordmark and spec|rules switcher above the search box, and
         the chart series variables the divergence graphs read. -->
    <link rel="stylesheet" href="/theme/spec.css?v={$VERSION}">
    <link rel="stylesheet" href="/theme/rules.css?v={$VERSION}">
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
    $body
    </div>
    <footer>
    <span>Raku Rules — the exhaustive rulebook, companion to the <a href="{%SITE<spec>}">Raku++ Specification</a>.</span>
    <span>Every example runs in your browser and is build-verified against the interpreter. <a href="$repo">Source</a>.</span>
    </footer>
    </main>
    <script src="/theme/shell.js?v={$VERSION}" defer></script>
    <script src="/theme/spec.js?v={$VERSION}" defer></script>
    <script>window.__SEARCH_INDEX = '{$b}/search-index.json';</script>
    <script src="/theme/chart.js?v={$VERSION}" defer></script>
    <script src="/theme/rules.js?v={$VERSION}" defer></script>
    <script src="/theme/search.js?v={$VERSION}" defer></script>
    <script src="$engine"></script>
    </body>
    </html>
    HTML
}

# The fact panel at the top of a construct page: everything the machine knows,
# so the prose never has to repeat it.
sub facts-html($e --> Str) {
    return '' unless $e.op;
    my %op = $e.op;
    my @chips;
    @chips.push('<span class="chip chip-cat">' ~ esc(%op<cat>.subst('_', ' ', :g)) ~ '</span>');
    if (%op<level> // '').chars {
        # denominator from the ladder the docs actually declare, not from the
        # section-order list in site.raku, which also carries non-levels
        my $rank = %op<rank>:exists
            ?? ' <b>' ~ (%op<rank> + 1) ~ '/' ~ @(%INV<ladder>).elems ~ '</b>' !! '';
        @chips.push('<span class="chip chip-prec" title="Precedence level, and its position ' ~
            'on the ladder counting from the tightest">' ~ esc(%op<level>) ~ $rank ~ '</span>');
    }
    @chips.push('<span class="chip">' ~ esc(%op<assoc>) ~ '-assoc</span>')
        if (%op<assoc> // '').chars;

    my $docs = %op<doc>:exists
        ?? '<a class="chip chip-doc" href="' ~ esc-attr(%op<doc>) ~
           '" title="The corresponding section of the official documentation"' ~
           ' target="_blank" rel="noopener">docs.raku.org ↗</a>'
        !! '';

    # What we can honestly claim about Raku++ support, strongest first. Parsing
    # is a weak fact — a probe that merely gets past the parser proves nothing
    # about execution — so where the behaviour matrix has actually RUN the
    # operator, say that instead.
    my $key = %op<cat> ~ '|' ~ %op<sym>;
    my @mx = @(%MATRIX{$key} // []);
    my $ran = @mx.grep({ $_[3] ne 'both-reject' }).elems;
    my $differ = @mx.grep({ $_[3] eq 'differ' }).elems;

    my $rk = do if (%op<rakupp>:exists) && !%op<rakupp> {
        '<span class="chip chip-no" title="A minimal use of this spelling is a ' ~
        'parse error in Raku++">Raku++ does not parse this</span>'
    }
    elsif @mx && !$differ {
        '<span class="chip chip-ok" title="Executed on both engines with ' ~
        @mx.elems ~ ' operand combinations; every result matched Rakudo">' ~
        'Raku++ runs this — matches Rakudo on all ' ~ @mx.elems ~ '</span>'
    }
    elsif @mx {
        '<span class="chip chip-warn" title="Executed on both engines; some ' ~
        'results differ from Rakudo — see the table below">Raku++ runs this — ' ~
        $differ ~ ' of ' ~ @mx.elems ~ ' results differ</span>'
    }
    elsif %op<rakupp>:exists && %op<rakupp> {
        '<span class="chip chip-weak" title="The spelling gets past the parser. ' ~
        'Whether it executes correctly has NOT been checked for this construct.">' ~
        'Raku++ parses this — execution unchecked</span>'
    }
    else { '' }

    my $sym = esc(%op<sym>);
    '<div class="facts">' ~
        '<div class="facts-sym"><code>' ~ $sym ~ '</code></div>' ~
        '<div class="facts-chips">' ~ @chips.join ~ $rk ~ $docs ~ '</div>' ~
    '</div>'
}

# The behaviour table: what each engine actually did with the same expression.
# Every row was executed; none of it is authored. Rows where the two engines
# agree carry one result; rows where they part company show both and are marked.
sub matrix-html($e --> Str) {
    return '' unless $e.op;
    my $key = $e.op<cat> ~ '|' ~ $e.op<sym>;
    return '' unless %MATRIX{$key}:exists;
    my @rows = @(%MATRIX{$key});
    return '' unless @rows;

    my $differ = @rows.grep({ $_[3] eq 'differ' }).elems;
    my @out;
    for @rows -> @r {
        my ($expr, $a, $b, $verdict) = @r[0], @r[1], @r[2], @r[3];
        my $cells = do given $verdict {
            when 'agree' {
                '<td colspan="2" class="mx-same">' ~ inline('`' ~ $a ~ '`') ~ '</td>'
            }
            when 'both-reject' {
                '<td colspan="2" class="mx-rej">rejected by both — <span>' ~
                esc($a.subst(/ ^ 'ERR ' /, '')) ~ '</span></td>'
            }
            default {
                '<td class="mx-a">' ~ inline('`' ~ $a ~ '`') ~ '</td>' ~
                '<td class="mx-b">' ~ inline('`' ~ $b ~ '`') ~ '</td>'
            }
        };
        my $cls = $verdict eq 'differ' ?? ' class="mx-differ"' !! '';
        @out.push("<tr$cls><td><code>" ~ esc($expr) ~ '</code></td>' ~ $cells ~ '</tr>');
    }

    my $note = $differ
        ?? '<p class="mx-note"><b>' ~ $differ ~ ' of ' ~ @rows.elems ~
           '</b> of these disagree between Raku++ and Rakudo — shown side by side below. ' ~
           'A disagreement here is a defect report waiting to be written, not a documented rule.</p>'
        !! '<p class="mx-note">Raku++ and Rakudo agree on every row below.</p>';

    '<h2 id="behaviour" class="sec">Observed behaviour ' ~
    '<a class="anchor" href="#behaviour" aria-label="link">#</a></h2>' ~
    '<p>Each expression below was executed by both interpreters when this page was ' ~
    'built; the results are recorded, not written. The operands are chosen to cross ' ~
    'the boundaries that catch people out: string against number, a list where a ' ~
    'scalar was meant, a boolean, an undefined value, and an exact rational.</p>' ~
    $note ~
    '<div class="table-wrap"><table class="mx"><thead><tr>' ~
    '<th>Expression</th><th>Raku++</th><th>Rakudo</th>' ~
    '</tr></thead><tbody>' ~ @out.join ~ '</tbody></table></div>'
}

# The three-way example block, shown on type pages.
#
# Each example carries the output the documentation ASSERTS; running it gives
# what Rakudo and Raku++ actually produce. The value is in the relationship
# between the three, so the block never shows one number where it can show the
# disagreement:
#
#   ok              all three agree — rendered as a normal verified example
#   rakupp-differs  doc and Rakudo agree, Raku++ does not — a defect, shown as such
#   doc-drift       both engines agree against the documentation — the doc is stale
#   all-differ      three answers — flagged for a human
sub examples-html($e --> Str) {
    return '' unless $e.topic eq 'types';
    my %t = %(%TYPE-OF{ $e.slug } // %());
    return '' unless %t;
    my @ex = @(%t<examples> // []);
    return '' unless @ex;

    # index the run results for this type
    my %run;
    for @(%TYPERUN<runs> // []) -> @r {
        %run{ @r[1] } = @r if @r[0] eq %t<name>;
    }

    my @out;
    my %tally;
    for @ex.kv -> $idx, %x {
        next unless %x<code>.chars;
        my @r = @(%run{$idx} // []);
        my $verdict = @r ?? @r[2] !! (%x<expect>.chars ?? 'unrun' !! 'no-output');
        %tally{$verdict}++;

        my @blk;
        @blk.push('<pre data-raku>' ~ esc(%x<code>) ~ '</pre>');

        if $verdict eq 'ok' {
            @blk.push('<div class="expected"><span class="expected-label">Output</span>' ~
                '<pre class="output"><code>' ~ esc(@r[4]) ~ '</code></pre></div>');
            @blk.push('<p class="ex-verdict v-ok">Documentation, Rakudo and Raku++ all agree.</p>');
        }
        elsif $verdict eq 'rakupp-differs' {
            @blk.push(three-way(%x<expect>, @r[4], @r[3],
                'Raku++ disagrees with both the documentation and Rakudo — a defect.'));
        }
        elsif $verdict eq 'doc-drift' {
            @blk.push(three-way(%x<expect>, @r[4], @r[3],
                'Both engines agree; the documentation states something else. Trust the engines.'));
        }
        elsif $verdict eq 'rakudo-differs' {
            @blk.push(three-way(%x<expect>, @r[4], @r[3],
                'Raku++ matches the documentation; Rakudo does not. This is the one ' ~
                'class where neither engine can be assumed right: it may be a stale ' ~
                'doc that Raku++ was built from, or it may be a Rakudo bug that the ' ~
                'documentation predates. Each case is examined individually.'));
            @blk.push(ruling-html(adjudication(%t<name>, %x<code>)));
        }
        elsif $verdict eq 'all-differ' {
            @blk.push(three-way(%x<expect>, @r[4], @r[3],
                'All three differ. Needs a human.'));
            @blk.push(ruling-html(adjudication(%t<name>, %x<code>)));
        }
        elsif $verdict eq 'not-runnable' {
            @blk.push('<p class="ex-verdict v-skip">Neither engine can run this in ' ~
                'isolation — the example depends on context from the surrounding text.</p>');
        }
        else {
            @blk.push('<p class="ex-verdict v-skip">Not executed: the documentation ' ~
                'states no expected output for this example.</p>') if $verdict eq 'no-output';
        }
        @out.push('<div class="ex-block">' ~ @blk.join ~ '</div>');
    }
    return '' unless @out;

    my $summary = %tally.sort({ .key }).map({ .value ~ ' ' ~ .key }).join(' · ');
    '<h2 id="examples" class="sec">Examples, run three ways ' ~
    '<a class="anchor" href="#examples" aria-label="link">#</a></h2>' ~
    '<p>Every example below comes from the official documentation, together with the ' ~
    'output that documentation asserts. Each was then executed by Rakudo and by ' ~
    'Raku++ when this page was built. Where the three agree, one result is shown; ' ~
    'where they do not, all three are — because which of them is wrong is exactly ' ~
    'the information worth having.</p>' ~
    '<p class="mx-note">' ~ esc($summary) ~ '</p>' ~
    @out.join
}

# A ruling is keyed by type and the example's first line, so it survives the
# example list being re-extracted (indices do not).
sub adjudication(Str $type, Str $code) {
    my $key = $type ~ '|' ~ ($code.lines[0] // '').trim;
    %ADJUDGED{$key}:exists ?? %(%ADJUDGED{$key}) !! Nil
}

sub ruling-html($adj --> Str) {
    return '<p class="ex-verdict v-pending">Not yet examined. Which of these is ' ~
           'correct has not been established — do not treat either engine as ' ~
           'settled here.</p>' unless $adj;
    my %a = %($adj);
    my ($cls, $label) = do given %a<ruling> {
        when 'raku++'    { 'v-ok',   'Examined: Raku++ is correct, Rakudo has the bug' }
        when 'rakudo'    { 'v-diff', 'Examined: Rakudo is correct' }
        when 'flaky'     { 'v-skip', 'Examined: the example is not deterministic' }
        default          { 'v-skip', 'Examined: still undecided' }
    };
    '<div class="ruling"><p class="ex-verdict ' ~ $cls ~ '"><b>' ~ esc($label) ~
    '</b></p><p class="ruling-note">' ~ esc(%a<note> // '') ~ '</p></div>'
}

sub three-way(Str $doc, Str $rakudo, Str $rakupp, Str $note --> Str) {
    '<div class="three-way">' ~
      '<div class="tw-row"><span class="tw-l">Documentation</span><pre><code>' ~
        esc($doc) ~ '</code></pre></div>' ~
      '<div class="tw-row"><span class="tw-l">Rakudo</span><pre><code>' ~
        esc($rakudo) ~ '</code></pre></div>' ~
      '<div class="tw-row tw-kp"><span class="tw-l">Raku++</span><pre><code>' ~
        esc($rakupp) ~ '</code></pre></div>' ~
      '<p class="ex-verdict v-diff">' ~ esc($note) ~ '</p>' ~
    '</div>'
}

sub toc-html($e --> Str) {
    return '' unless $e.rules.elems >= 2;
    my @li = $e.rules.map(-> @r {
        '<li><a href="#' ~ @r[2] ~ '"><span class="toc-id">' ~ @r[0] ~ '</span>' ~
        inline(@r[1]) ~ '</a></li>'
    });
    '<div class="toc"><div class="toc-head">Rules on this page</div><ol>' ~ @li.join ~ '</ol></div>'
}

sub render-entry($e, %by-topic --> Str) {
    my $r = Renderer.new(lines => $e.body.lines, entry => $e);
    my $html = $r.render;           # fills $e.rules and $e.examples
    my @head;
    @head.push('<div class="crumbs"><a href="' ~ base() ~ '/">Rules</a> / ' ~
        esc(topic-title($e.topic)) ~ ' / ' ~ esc($e.section) ~ '</div>');
    my $is-sym = $e.op && $e.title eq $e.op<sym>;
    @head.push('<h1>' ~ ($is-sym ?? '<code>' ~ esc($e.title) ~ '</code>' !! esc($e.title)) ~
        ' ' ~ status-badge($e.status) ~ '</h1>');
    @head.push('<p class="summary">' ~ inline($e.summary) ~ '</p>') if $e.summary;
    @head.push(facts-html($e));
    @head.push(toc-html($e));
    @head.join ~ "\n" ~ $html ~ "\n" ~ matrix-html($e) ~ "\n" ~ examples-html($e)
}

sub render-topic(Str $slug, %by-topic --> Str) {
    my %secs = %(%by-topic{$slug} // %());
    my $blurb = '';
    for @(%SITE<topics>) -> %t { $blurb = %t<blurb> // '' if %t<slug> eq $slug }
    my @out = '<h1>' ~ esc(topic-title($slug)) ~ '</h1>';
    @out.push('<p class="summary">' ~ inline($blurb) ~ '</p>') if $blurb;
    for %secs.keys.sort({ section-rank($_).fmt('%03d') }) -> $sec {
        my @list = @(%secs{$sec});
        @out.push('<h2 id="' ~ slugify($sec) ~ '" class="sec">' ~ esc($sec) ~ '</h2>');
        @out.push('<div class="sym-grid">');
        for @list -> $e {
            my $label = $e.op ?? '<code>' ~ esc($e.op<sym>) ~ '</code>' !! esc($e.title);
            my $sub   = ($e.op && $e.title ne $e.op<sym>) ?? $e.title !! $e.summary;
            @out.push('<a class="sym-card s-' ~ $e.status ~ '" href="' ~ url-of($e) ~ '">' ~
                $label ~ '<span class="sym-sub">' ~ esc($sub) ~ '</span></a>');
        }
        @out.push('</div>');
    }
    @out.join("\n")
}

sub render-symbols(@entries --> Str) {
    my @ops = @entries.grep({ .op }).sort({ .title });
    my @rows;
    for @ops -> $e {
        my %op = $e.op;
        @rows.push('<tr><td><a href="' ~ url-of($e) ~ '"><code>' ~ esc(%op<sym>) ~ '</code></a></td>' ~
            '<td>' ~ esc(%op<cat>.subst('_', ' ', :g)) ~ '</td>' ~
            '<td>' ~ esc(%op<dba> // '—') ~ '</td>' ~
            '<td>' ~ esc(%op<assoc> // '—') ~ '</td>' ~
            '<td>' ~ status-badge($e.status) ~ '</td></tr>');
    }
    '<h1>Symbol index</h1>' ~
    '<p class="summary">Every spelling the grammar declares, in one table — ' ~
    @ops.elems ~ ' constructs. Sorted by symbol.</p>' ~
    '<div class="table-wrap"><table class="symtable"><thead><tr>' ~
    '<th>Symbol</th><th>Category</th><th>Precedence level</th><th>Assoc</th><th>Status</th>' ~
    '</tr></thead><tbody>' ~ @rows.join ~ '</tbody></table></div>'
}

# The divergence overview: one row per type or operator, with a strip of dots —
# one dot per executed example or matrix row, coloured by verdict. The point is
# to make clustering visible at a glance: a row that is mostly red is a type
# worth a morning's work, and a page of mostly green is not.
# The history is JSON Lines, and the generator has no JSON parser — but the
# fields the chart needs are flat numbers with fixed names, so they are pulled
# out directly. Anything malformed is skipped rather than failing the build.
sub load-history(Str $path) {
    my @out;
    return @out unless $path.IO.e;
    for slurp($path).lines -> $line {
        next unless $line.trim.chars;
        my %h;
        if $line ~~ / '"date":"' (<-[\x22]>*) '"' / { %h<date> = ~$0 }
        for <ok rakupp-differs rakudo-differs doc-drift all-differ not-runnable> -> $k {
            %h{$k} = ($line ~~ / '"' $k '":' (\d+) /) ?? (~$0).Int !! 0;
        }
        next unless %h<date>:exists;
        @out.push(%h);
    }
    @out
}

# The verdict mix per run over time. TWO renderings of one dataset:
#
#   * inline SVG, drawn here at build time — it needs no script, it prints, and
#     it is what a reader without JavaScript sees;
#   * the site's shared interactive chart (theme/chart.js, the same renderer the
#     dashboard uses), which rules.js swaps in over the top when it can. That is
#     where the crosshair, the hover tooltip and the data table come from.
#
# The data rides along as a JSON attribute on the host element so the enhanced
# chart needs no second fetch — and so the two renderings can never disagree.
sub history-chart(--> Str) {
    return '' unless @HISTORY.elems >= 2;
    # (verdict, CSS class). The colour lives in rules.css, once, and is worn by
    # the static polyline, the legend swatch AND the interactive chart — so the
    # chart cannot disagree with the dot legend at the top of this page, which is
    # exactly what happened when it borrowed the dashboard's palette (that one
    # paints `all-differ` grey, the colour this page reserves for "not run").
    my @series =
        ( 'ok',             'vh-ok'     ),
        ( 'rakupp-differs', 'vh-bad'    ),
        ( 'doc-drift',      'vh-drift'  ),
        ( 'rakudo-differs', 'vh-rakudo' ),
        ( 'all-differ',     'vh-all'    );

    my $max = 1;
    for @HISTORY -> %h {
        for @series -> @s { $max = %h{ @s[0] } if %h{ @s[0] } > $max }
    }
    my ($w, $hgt, $pad) = 640, 200, 28;
    my $span = @HISTORY.elems - 1;

    my @paths;
    for @series -> @s {
        my @pts;
        for @HISTORY.kv -> $i, %h {
            my $x = $pad + ($span ?? ($w - 2 * $pad) * $i / $span !! 0);
            my $y = $hgt - $pad - ($hgt - 2 * $pad) * %h{ @s[0] } / $max;
            @pts.push($x.round(0.1) ~ ',' ~ $y.round(0.1));
        }
        @paths.push('<polyline class="' ~ @s[1] ~ '" fill="none" ' ~
                    'stroke-width="2" points="' ~ @pts.join(' ') ~ '"/>');
    }

    my @labels;
    for @HISTORY.kv -> $i, %h {
        next unless $i == 0 || $i == $span;
        my $x = $pad + ($span ?? ($w - 2 * $pad) * $i / $span !! 0);
        my $anchor = $i == 0 ?? 'start' !! 'end';
        @labels.push('<text x="' ~ $x.round(0.1) ~ '" y="' ~ ($hgt - 6) ~
                     '" text-anchor="' ~ $anchor ~ '" class="hc-lab">' ~
                     esc(%h<date>) ~ '</text>');
    }

    # Destructured rather than subscripted: this generator runs in CI against the
    # latest RELEASED rakupp, which can lag the interpreter it was written on.
    my $legend = @series.map(-> ($name, $cls) {
        '<span class="leg"><span class="dot ' ~ $cls ~ '"></span>' ~
        esc($name) ~ '</span>'
    }).join;

    # the same numbers again, as JSON, for the interactive rendering
    my $json = '{"labels":[' ~
        @HISTORY.map({ '"' ~ .<date> ~ '"' }).join(',') ~
        '],"series":[' ~
        @series.map(-> ($name, $cls) {
            '{"key":"' ~ $name ~ '","cls":"' ~ $cls ~ '","values":[' ~
            @HISTORY.map({ .{$name} }).join(',') ~ ']}'
        }).join(',') ~ ']}';

    '<h2 class="sec" id="over-time">Over time ' ~
    '<a class="anchor" href="#over-time" aria-label="link">#</a></h2>' ~
    '<p>One point per regeneration of the data, oldest first. The history is kept ' ~
    'append-only in <code>src/data/history.jsonl</code>, so this chart can be ' ~
    'replaced by something richer without losing the record.</p>' ~
    '<div class="dash-chart" id="rules-history" data-history="' ~ esc-attr($json) ~ '">' ~
    '<div class="legend">' ~ $legend ~ '</div>' ~
    '<svg class="hc" viewBox="0 0 ' ~ $w ~ ' ' ~ $hgt ~ '" role="img" ' ~
    'aria-label="verdict counts per run over time">' ~
    '<line x1="' ~ $pad ~ '" y1="' ~ ($hgt - $pad) ~ '" x2="' ~ ($w - $pad) ~
    '" y2="' ~ ($hgt - $pad) ~ '" class="hc-ax"/>' ~
    '<text x="' ~ $pad ~ '" y="16" class="hc-lab">peak ' ~ $max ~ '</text>' ~
    @paths.join ~ @labels.join ~ '</svg>' ~
    '</div>'
}

sub verdict-dot(Str $v --> Str) {
    my $cls = do given $v {
        when 'ok'             { 'st-full' }
        when 'doc-drift'      { 'st-part' }
        when 'rakupp-differs' { 'st-div'  }
        when 'rakudo-differs' { 'st-rakudo' }
        when 'all-differ'     { 'st-all'  }
        default               { 'st-ni'   }
    };
    '<span class="dot ' ~ $cls ~ '" title="' ~ $v ~ '"></span>'
}

sub render-divergences(@entries --> Str) {
    # ---- types, from the three-way example run --------------------------
    my %byt;
    for @(%TYPERUN<runs> // []) -> @r {
        %byt{ @r[0] } //= [];
        %byt{ @r[0] }.push(@r[2]);
    }
    my %slug-of;
    for @entries -> $e { %slug-of{ $e.title } = url-of($e) if $e.topic eq 'types' }

    my @trows;
    for %byt.keys.sort({ -@(%byt{$_}).grep({ $_ ne 'ok' }).elems }) -> $type {
        my @v = @(%byt{$type});
        my $bad = @v.grep({ $_ eq 'rakupp-differs' }).elems;
        my $drift = @v.grep({ $_ eq 'doc-drift' }).elems;
        my $all = @v.grep({ $_ eq 'all-differ' }).elems;
        my $rd = @v.grep({ $_ eq 'rakudo-differs' }).elems;
        my $ok = @v.grep({ $_ eq 'ok' }).elems;
        my $link = %slug-of{$type} // '';
        my $name = $link ?? '<a href="' ~ $link ~ '">' ~ esc($type) ~ '</a>' !! esc($type);
        @trows.push(
            '<tr><td class="dv-name">' ~ $name ~ '</td>' ~
            '<td class="num">' ~ @v.elems ~ '</td>' ~
            '<td class="num n-ok">'    ~ ($ok    || '') ~ '</td>' ~
            '<td class="num n-bad">'   ~ ($bad   || '') ~ '</td>' ~
            '<td class="num n-drift">' ~ ($drift || '') ~ '</td>' ~
            '<td class="num n-rakudo">' ~ ($rd   || '') ~ '</td>' ~
            '<td class="num n-all">'   ~ ($all   || '') ~ '</td>' ~
            '<td class="dv-dots">' ~ @v.map({ verdict-dot($_) }).join ~ '</td></tr>');
    }

    # ---- operators, from the behaviour matrix ---------------------------
    my %slug-op;
    for @entries -> $e {
        %slug-op{ $e.op<cat> ~ '|' ~ $e.op<sym> } = url-of($e) if $e.op;
    }
    my @orows;
    for %MATRIX.keys.sort({ -@(%MATRIX{$_}).grep({ $_[3] eq 'differ' }).elems }) -> $key {
        my @rows = @(%MATRIX{$key});
        my $differ = @rows.grep({ $_[3] eq 'differ' }).elems;
        next unless $differ;
        my ($cat, $sym) = $key.split('|', 2);
        my $link = %slug-op{$key} // '';
        my $name = $link ?? '<a href="' ~ $link ~ '"><code>' ~ esc($sym) ~ '</code></a>'
                         !! '<code>' ~ esc($sym) ~ '</code>';
        @orows.push(
            '<tr><td class="dv-name">' ~ $name ~ ' <span class="dv-cat">' ~ esc($cat) ~ '</span></td>' ~
            '<td class="num">' ~ @rows.elems ~ '</td>' ~
            '<td class="num n-ok">' ~ (@rows.grep({ $_[3] eq 'agree' }).elems || '') ~ '</td>' ~
            '<td class="num n-bad">' ~ $differ ~ '</td>' ~
            '<td class="num">' ~ (@rows.grep({ $_[3] eq 'both-reject' }).elems || '') ~ '</td>' ~
            '<td class="dv-dots">' ~ @rows.map({
                verdict-dot($_[3] eq 'agree' ?? 'ok'
                         !! ($_[3] eq 'differ' ?? 'rakupp-differs' !! 'not-runnable'))
            }).join ~ '</td></tr>');
    }

    my $legend = '<div class="legend">' ~
        '<span class="leg"><span class="dot st-full"></span>all agree</span>' ~
        '<span class="leg"><span class="dot st-div"></span>Raku++ differs</span>' ~
        '<span class="leg"><span class="dot st-part"></span>documentation stale</span>' ~
        '<span class="leg"><span class="dot st-rakudo"></span>Raku++ matches the docs, Rakudo does not</span>' ~
        '<span class="leg"><span class="dot st-all"></span>all three differ</span>' ~
        '<span class="leg"><span class="dot st-ni"></span>not run</span>' ~
        '</div>';

    '<h1>Where things diverge</h1>' ~
    '<p class="summary">One row per type or operator, one dot per executed check, ' ~
    'coloured by outcome. Sorted worst first, so the clusters are the top of each ' ~
    'table.</p>' ~
    $legend ~
    history-chart() ~
    '<h2 class="sec">Types</h2>' ~
    '<p>Each dot is one example from the official documentation, run on both engines ' ~
    'and compared against the output the documentation asserts.</p>' ~
    '<div class="table-wrap"><table class="dv"><thead><tr>' ~
    '<th>Type</th><th class="num">n</th><th class="num">agree</th>' ~
    '<th class="num" title="Raku++ differs">R++</th>' ~
    '<th class="num" title="documentation stale">doc</th>' ~
    '<th class="num" title="Raku++ matches the docs, Rakudo does not">rk</th>' ~
    '<th class="num">all</th>' ~
    '<th>outcome</th></tr></thead><tbody>' ~ @trows.join ~ '</tbody></table></div>' ~
    '<h2 class="sec">Operators</h2>' ~
    '<p>Each dot is the same expression run on both engines. Only operators with at ' ~
    'least one disagreement are listed.</p>' ~
    '<div class="table-wrap"><table class="dv"><thead><tr>' ~
    '<th>Operator</th><th class="num">n</th><th class="num">agree</th>' ~
    '<th class="num">differ</th><th class="num">both reject</th>' ~
    '<th>outcome</th></tr></thead><tbody>' ~ @orows.join ~ '</tbody></table></div>'
}

# The gap list needs care, because read carelessly it says the wrong thing. Most
# entries are alternative UNICODE spellings whose ASCII form works perfectly —
# `⩵` is unsupported while `==` is fine — and a flat list invites the reader to
# conclude that equality is broken. So the two kinds are separated, and where the
# documentation puts a working spelling under the same heading, it is named.
sub gaps-html(@entries --> Str) {
    my @gaps = @entries.grep({ .status eq 'gap' && .op });
    return '' unless @gaps;

    # Operators documented under the same heading are the same operator, spelled
    # differently — that is what makes a suggested alternative trustworthy here
    # rather than guessed.
    my %bydoc;
    for @(%INV<ops>) -> %o {
        my $d = %o<doc> // '';
        next unless $d.chars;
        %bydoc{$d} //= [];
        %bydoc{$d}.push(%o);
    }

    sub card($e) {
        my @sib = @(%bydoc{ $e.op<doc> // '' } // [])
                    .grep({ .<sym> ne $e.op<sym> && (.<rakupp>:exists) && .<rakupp> });
        my $alt = @sib
            ?? '<span class="sym-sub">works as <code>' ~ esc(@sib[0]<sym>) ~ '</code></span>'
            !! '<span class="sym-sub">' ~ esc($e.op<level> // $e.op<cat>) ~ '</span>';
        '<a class="sym-card s-gap" href="' ~ url-of($e) ~ '"><code>' ~
        esc($e.op<sym>) ~ '</code>' ~ $alt ~ '</a>'
    }

    my @ascii = @gaps.grep({ .op<sym> ~~ / ^ <[\x20..\x7E]>+ $ / }).sort({ .op<sym> });
    my @uni   = @gaps.grep({ !(.op<sym> ~~ / ^ <[\x20..\x7E]>+ $ /) }).sort({ .op<sym> });

    my @out;
    @out.push('<h2 class="sec">Where Raku++ does not parse the spelling</h2>');
    @out.push('<p>Probed directly: a minimal use of each construct is fed to the ' ~
        'interpreter and classified by whether it parses. ' ~ @gaps.elems ~
        ' spellings do not — but read the two groups separately, because they ' ~
        'mean very different things.</p>');

    if @uni {
        @out.push('<h3>Unicode spellings (' ~ @uni.elems ~ ')</h3>');
        @out.push('<p><b>These are alternative spellings, not missing operators.</b> ' ~
            'Raku lets many operators be written with a mathematical symbol as well ' ~
            'as in ASCII — <code>⩵</code> for <code>==</code>, <code>≼</code> for ' ~
            '<code>(&lt;+)</code>. Raku++ not accepting the symbol says nothing about ' ~
            'the operator itself: <code>==</code> works exactly as expected. Where the ' ~
            'documentation puts a working spelling under the same heading, it is ' ~
            'named on the card.</p>');
        @out.push('<div class="sym-grid">' ~ @uni.map({ card($_) }).join ~ '</div>');
    }
    if @ascii {
        @out.push('<h3>ASCII spellings (' ~ @ascii.elems ~ ')</h3>');
        @out.push('<p>These are the ones that matter: an ordinary spelling the ' ~
            'interpreter cannot parse at all.</p>');
        @out.push('<div class="sym-grid">' ~ @ascii.map({ card($_) }).join ~ '</div>');
    }
    @out.join
}

sub render-coverage(@entries --> Str) {
    my $total   = @entries.elems;
    my $written = @entries.grep({ .status eq 'written' || .status eq 'partial' }).elems;
    my $gaps    = @entries.grep({ .status eq 'gap' }).elems;
    my $pct     = $total ?? (100 * $written / $total).round !! 0;
    my $rules   = @entries.map({ .rules.elems }).sum;
    my $ex      = @entries.map({ .examples.elems }).sum;

    my @rows;
    my %by-topic = group-entries(@entries);
    for @(%SITE<topics>) -> %t {
        my %secs = %(%by-topic{ %t<slug> } // %());
        next unless %secs;
        my @all = %secs.values.map({ |@($_) });
        my $w = @all.grep({ .status eq 'written' || .status eq 'partial' }).elems;
        @rows.push('<tr><td><a href="' ~ base() ~ '/' ~ %t<slug> ~ '/">' ~ esc(%t<title>) ~ '</a></td>' ~
            '<td>' ~ @all.elems ~ '</td><td>' ~ $w ~ '</td>' ~
            '<td><div class="bar"><span style="width:' ~
            (@all.elems ?? (100 * $w / @all.elems).round !! 0) ~ '%"></span></div></td></tr>');
    }

    '<h1>Coverage</h1>' ~
    '<p class="summary">What exists versus what is written. The denominator is not a ' ~
    'guess: it is every construct the official documentation describes, so a missing ' ~
    'page cannot hide.</p>' ~
    '<div class="cov-tiles">' ~
      '<div class="tile"><b>' ~ $total ~ '</b><span>constructs</span></div>' ~
      '<div class="tile"><b>' ~ $written ~ '</b><span>written up</span></div>' ~
      '<div class="tile"><b>' ~ $pct ~ '%</b><span>coverage</span></div>' ~
      '<div class="tile"><b>' ~ $rules ~ '</b><span>numbered rules</span></div>' ~
      '<div class="tile"><b>' ~ $ex ~ '</b><span>verified examples</span></div>' ~
      '<div class="tile"><b>' ~ $gaps ~ '</b><span>Raku++ gaps</span></div>' ~
      '<div class="tile"><b>' ~ @entries.grep({ .op && (.op<doc>:exists) }).elems ~
      '</b><span>linked to docs.raku.org</span></div>' ~
    '</div>' ~
    '<h2 class="sec">By topic</h2>' ~
    '<div class="table-wrap"><table><thead><tr><th>Topic</th><th>Constructs</th>' ~
    '<th>Written</th><th></th></tr></thead><tbody>' ~ @rows.join ~ '</tbody></table></div>' ~
    # (a "declared but undocumented" section lived here while the inventory was
    #  extracted from Rakudo's grammar. With the documentation as the source, an
    #  operator cannot be in the inventory without a doc section, so the section
    #  could never have entries.)
    gaps-html(@entries)
}

sub render-home(@entries, %by-topic --> Str) {
    my $total   = @entries.elems;
    my $written = @entries.grep({ .status eq 'written' || .status eq 'partial' }).elems;
    my @cards;
    for @(%SITE<topics>) -> %t {
        my %secs = %(%by-topic{ %t<slug> } // %());
        next unless %secs;
        my $n = %secs.values.map(*.elems).sum;
        @cards.push('<a class="topic-card" href="' ~ base() ~ '/' ~ %t<slug> ~ '/">' ~
            '<b>' ~ esc(%t<title>) ~ '</b><span>' ~ esc(%t<blurb> // '') ~ '</span>' ~
            '<i>' ~ $n ~ ' constructs</i></a>');
    }
    '<h1>' ~ esc(%SITE<title>) ~ '</h1>' ~
    '<p class="lede">' ~ inline(%SITE<tagline>) ~ '</p>' ~
    '<p>Start at a topic and drill down to a single construct — <code>+</code>, ' ~
    '<code>[ ]</code>, <code>Z</code>, <code>andthen</code>. Each page states what the ' ~
    'construct is for, then the numbered rules that govern it, then the behaviour that ' ~
    'surprises people: precedence traps, context effects, and the places where this ' ~
    'implementation and Rakudo disagree.</p>' ~
    '<div class="cov-tiles">' ~
      '<div class="tile"><b>' ~ $total ~ '</b><span>constructs indexed</span></div>' ~
      '<div class="tile"><b>' ~ $written ~ '</b><span>written up</span></div>' ~
      '<div class="tile"><a href="' ~ base() ~ '/coverage/">coverage →</a></div>' ~
      '<div class="tile"><a href="' ~ base() ~ '/divergences/">divergences →</a></div>' ~
    '</div>' ~
    '<div class="topic-grid">' ~ @cards.join ~ '</div>'
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

sub run-snippet(Str $exe, Str $code) {
    my $p = run($exe, '-e', $code, :out, :err);
    my $out = $p.out.slurp(:close);
    my $err = $p.err.slurp(:close);
    $out.trim-trailing, $err
}

# Every ```raku block with a declared ```output is run for real. With --oracle
# the same block is run through Rakudo and the two are compared: the declared
# output must be what Rakudo produces (Rakudo is the authority), and Raku++ must
# match it. A page that documents a known divergence marks the block `raku diverges`.
sub verify-examples(@entries, Str $rakupp, Str $oracle --> Int) {
    my $checked = 0;
    my $failed  = 0;
    my $ofail   = 0;
    for @entries -> $e {
        next unless $e.examples.elems;
        for @($e.examples) -> @ex {
            my ($code, $expected, $line) = @ex;
            next unless $expected.defined;
            $checked++;
            my ($got, $err) = run-snippet($rakupp, $code);
            if $got ne $expected.trim-trailing {
                $failed++;
                my $where = $e.path || ('(stub) ' ~ $e.slug);
                note "  MISMATCH $where:$line";
                note "    expected: {$expected.trim-trailing.subst(\"\n\", '⏎', :g)}";
                note "    got     : {$got.subst(\"\n\", '⏎', :g)}";
                note "    stderr  : {$err.lines[0] // ''}" if $err;
            }
            if $oracle {
                my ($ogot, $oerr) = run-snippet($oracle, $code);
                if $ogot ne $expected.trim-trailing {
                    $ofail++;
                    note "  ORACLE MISMATCH ($oracle) {$e.path}:$line";
                    note "    declared: {$expected.trim-trailing.subst(\"\n\", '⏎', :g)}";
                    note "    rakudo  : {$ogot.subst(\"\n\", '⏎', :g)}";
                }
            }
        }
    }
    # Claimed divergences: the page says these differ, so agreement is the
    # failure. Without this a fixed divergence sits on the site indefinitely,
    # which is exactly how the `"3abc" + 1` claim on infix-plus went stale.
    my $stale = 0;
    my $dchecked = 0;
    if $oracle {
        for @entries -> $e {
            for @($e.divergences) -> @d {
                my ($code, $line) = @d[0], @d[1];
                $dchecked++;
                my ($a, $) = run-snippet($rakupp, $code);
                my ($b, $) = run-snippet($oracle, $code);
                if $a eq $b {
                    $stale++;
                    note "  DIVERGENCE GONE {$e.path}:$line — both engines now give: " ~
                         $a.subst("\n", '⏎', :g);
                }
            }
        }
        say "checked $dchecked claimed divergence(s): $stale no longer diverge"
            if $dchecked;
    }

    say "verified $checked examples: {$checked - $failed} ok, $failed mismatched"
        ~ ($oracle ?? ", $ofail oracle mismatches" !! '');
    $failed + $ofail + $stale
}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

sub write-page(Str $path, Str $html) {
    my $dir = $path.IO.dirname;
    mkdir $dir unless $dir.IO.d;
    spurt $path, $html;
}

sub search-index(@entries --> Str) {
    my @recs;
    for @entries -> $e {
        next unless $e.status eq 'written' || $e.status eq 'partial' || $e.op;
        my $text = index-body($e.body);
        @recs.push('{"t":' ~ json-str($e.title) ~
                   ',"u":' ~ json-str(url-of($e)) ~
                   ',"c":' ~ json-str(topic-title($e.topic) ~ ' · ' ~ $e.section) ~
                   ',"s":' ~ json-str($e.summary) ~
                   ',"b":' ~ json-str($text.substr(0, 1200)) ~ '}');
    }
    '[' ~ @recs.join(",\n") ~ ']'
}

sub MAIN(
    Bool :$verify = False,
    Bool :$clean  = False,
    Str  :$rakupp = RAKUPP-DEFAULT,
    Str  :$oracle = '',
) {
    %SITE = EVAL slurp 'src/rules/site.raku';
    die "src/data/inventory.raku missing — run tools/inventory.raku first"
        unless 'src/data/inventory.raku'.IO.e;
    %INV = EVAL slurp 'src/data/inventory.raku';
    %MATRIX  = 'src/data/matrix.raku'.IO.e  ?? EVAL slurp 'src/data/matrix.raku'  !! %();
    %TYPEDOC = 'src/data/typedoc.raku'.IO.e ?? EVAL slurp 'src/data/typedoc.raku' !! %();
    %TYPERUN = 'src/data/typerun.raku'.IO.e ?? EVAL slurp 'src/data/typerun.raku' !! %();
    %ADJUDGED = 'src/rules/adjudications.raku'.IO.e
        ?? EVAL slurp 'src/rules/adjudications.raku' !! %();
    @HISTORY = load-history('src/data/history.jsonl');

    # Where the files land, which is not where they are served from: the whole
    # of out/ is mounted at /spec, so a base of /spec/rules writes to out/rules.
    my $out = 'out' ~ (%SITE<out-dir> // base());
    # This directory is entirely generated, so it is always cleared: otherwise a
    # page that stops being produced (a construct dropped from the inventory, an
    # entry collapsed onto its topic URL) lingers as a stale orphan.
    if $out.IO.d { run('rm', '-rf', $out) }

    $VERSION = asset-version();

    my @entries  = collect-entries();
    my %by-topic = group-entries(@entries);

    for %by-topic.kv -> $topic, %secs {
        my @all = %secs.values.map({ |@($_) });
        %SOLO{$topic} = @all[0].slug if @all.elems == 1;
    }

    # Pages first: rendering fills in each entry's rule list and examples, which
    # the coverage page and the search index then report on.
    my %rendered;
    for @entries -> $e {
        %rendered{ $e.topic ~ '/' ~ $e.slug } = render-entry($e, %by-topic);
    }
    for @entries -> $e {
        # a solo entry is written as its topic's page instead, just below
        next if (%SOLO{ $e.topic } // '') eq $e.slug;
        my $nav  = nav-html(%by-topic, $e);
        my $html = page-shell($e.title ~ ' — ' ~ %SITE<title>,
                              %rendered{ $e.topic ~ '/' ~ $e.slug }, $nav);
        write-page("$out/{$e.topic}/{$e.slug}/index.html", $html);
    }

    for @(%SITE<topics>) -> %t {
        next unless %by-topic{ %t<slug> }:exists;
        my $solo = %SOLO{ %t<slug> } // '';
        my $entry = $solo ?? @entries.first({ .topic eq %t<slug> && .slug eq $solo }) !! Nil;
        my $nav  = nav-html(%by-topic, $entry);
        my $body = $solo ?? %rendered{ %t<slug> ~ '/' ~ $solo }
                         !! render-topic(%t<slug>, %by-topic);
        my $title = $solo ?? $entry.title !! %t<title>;
        write-page("$out/{%t<slug>}/index.html",
            page-shell($title ~ ' — ' ~ %SITE<title>, $body, $nav));
    }

    my $nav = nav-html(%by-topic, Nil);
    write-page("$out/index.html",
        page-shell(%SITE<title>, render-home(@entries, %by-topic), $nav, :home));
    write-page("$out/symbols/index.html",
        page-shell('Symbol index — ' ~ %SITE<title>, render-symbols(@entries), $nav));
    write-page("$out/coverage/index.html",
        page-shell('Coverage — ' ~ %SITE<title>, render-coverage(@entries), $nav));
    write-page("$out/divergences/index.html",
        page-shell('Where things diverge — ' ~ %SITE<title>,
                   render-divergences(@entries), $nav));

    spurt "$out/search-index.json", search-index(@entries);
    # (rakupp has no &copy — slurp/spurt is equivalent for these text assets)
    # The theme is shared across raku.online and placed at the site root by the
    # top-level build; a sub-site shipping its own copy would shadow it.
    if %SITE<theme-out> // True {
        mkdir 'out/theme' unless 'out/theme'.IO.d;
        for <rules.css rules.js chart.js> -> $asset {
            spurt "out/theme/$asset", slurp("{%SITE<theme-dir> // 'src/theme'}/$asset")
                if "{%SITE<theme-dir> // 'src/theme'}/$asset".IO.e;
        }
    }

    my $written = @entries.grep({ .status eq 'written' || .status eq 'partial' }).elems;
    say "built {@entries.elems} construct pages into $out/  ($written written, " ~
        "{@entries.grep({ .status eq 'gap' }).elems} gaps)";
    say "rules: {@entries.map({ .rules.elems }).sum}, examples: {@entries.map({ .examples.elems }).sum}";

    if $verify {
        my $bad = verify-examples(@entries, $rakupp, $oracle);
        exit 1 if $bad;
    }
}
