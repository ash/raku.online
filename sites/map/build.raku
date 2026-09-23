# build.raku — generated Rakumap programs at raku.online/map.
#
#   rakupp build.raku [--clean] [--map=PATH]
#   rakupp build.raku --record [--map=PATH] [--oracle=rakudo] [--engine=rakupp]
#
# Reads the small, committed fixture corpus from a Rakumap checkout. Campaign
# output under Rakumap's ignored out/ directory is deliberately never published.
#
# The pages say, for every program, what the reference compiler printed and
# what Raku++ printed. Those outputs are not produced by an ordinary build —
# a machine without Rakudo would then fail a build that has nothing wrong with
# it. --record runs every program under both engines (twice each, so a
# nondeterministic answer is caught) and writes src/results.raku, which is
# committed; the ordinary build only reads it. Re-record whenever the corpus
# or the engine changes.

my %SITE;
my $BASE = '';

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)
      .subst('"', '&quot;', :g)
}

sub page(Str $title, Str $body, Bool :$editor = False --> Str) {
    my $engine = $editor ?? "\n" ~ '<script src="/raku.js?v=00000000"></script>' !! '';
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
    <link rel="stylesheet" href="/theme/map.css">
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
    <main><div class="content">
    $body
    <footer>
      <span>Programs are generated deterministically from recorded seeds.</span>
      <span><a href="{%SITE<repo>}">Rakumap on GitHub ↗</a></span>
    </footer>
    </div></main>
    <script src="/theme/shell.js" defer></script>{$engine}
    </body>
    </html>
    HTML
}

# ---------------------------------------------------------------- the corpus

sub read-cases(IO::Path $root) {
    my $generated = $root.add('fixtures/generated');
    die "no committed generated corpus at {$generated.Str}" unless $generated.d;
    my $findings = $root.add('fixtures/findings');
    my @cases;
    for $generated.dir.grep(*.d).sort(*.basename) -> $group {
        my $topic = $group.basename.subst(/ '-v' \d+ $ /, '');
        my $n = 0;
        for $group.dir.grep({ .f && .extension eq 'raku' }).sort(*.basename) -> $file {
            my $name = $file.basename.subst(/ '.raku' $ /, '');
            my $seed = $name ~~ / (\d ** 8) $ / ?? +$0 !! 0;
            my $code = $file.slurp;
            @cases.push: {
                group => $group.basename, topic => $topic, name => $name, seed => $seed,
                number => ++$n, file => $file, code => $code, snippet => snippet($code),
                finding => $findings.add($name).d,
                repo-path => 'fixtures/generated/' ~ $group.basename ~ '/' ~ $file.basename,
            };
        }
    }
    @cases
}

# Nearly every generated program is a few lines that build $value, followed by
# the same reporting harness: a safe-str helper and four `say` lines. The
# snippet is the part that differs from program to program — what a reader
# wants to see on a card.
sub snippet(Str $code --> Str) {
    my @keep;
    my $in-helper = False;
    for $code.lines -> $line {
        if $in-helper {
            $in-helper = False if $line ~~ / ^ '}' \s* $ /;
            next;
        }
        if $line ~~ / ^ 'sub safe-str' / {
            $in-helper = True unless $line ~~ / '}' \s* $ /;
            next;
        }
        next if $line ~~ / ^ 'say "' [ TYPE | RAKU | STR | BOOL ] '\t"' /;
        @keep.push($line);
    }
    @keep.join("\n").trim
}

sub has-harness(Str $code --> Bool) {
    so $code ~~ / 'say "TYPE\t"' /
}

# ---------------------------------------------------------------- recording

constant RUN-TIMEOUT = 30;

sub run-bounded(Str $exe, IO::Path $file) {
    my $proc = Proc::Async.new($exe, $file.absolute);
    my ($out, $err) = ('', '');
    $proc.stdout.tap({ $out ~= $_ });
    $proc.stderr.tap({ $err ~= $_ });
    my $done  = $proc.start;
    my $timer = Promise.in(RUN-TIMEOUT);
    await Promise.anyof($done, $timer);
    my $exit;
    if $done.status != Kept {
        $proc.kill(SIGKILL);
        my $ = try await $done;
        $err ~= "TIMEOUT: still running after {RUN-TIMEOUT}s, killed\n";
        $exit = -1;
    }
    else {
        my $r = try await $done;
        $exit = $r.defined ?? $r.exitcode !! -1;   # a failed Proc is False, not undefined
    }
    # The absolute path of the checkout means nothing to a reader; the file's
    # name does. Colour codes mean nothing in HTML.
    $err = $err.subst($file.absolute, $file.basename, :g).subst(/ \e '[' <[0..9;]>* 'm' /, '', :g)
               .subst('⏏', '<HERE>', :g);
    %( exit => $exit, out => $out, err => $err )
}

sub version-of(Str $exe --> Str) {
    my $p = run($exe, '--version', :out, :err);
    my $v = $p.out.slurp(:close).lines.head // '';
    $p.err.slurp(:close);
    return "Rakudo $0" if $v ~~ / 'Rakudo' \S* \s+ 'v' (\d+ '.' \d+ [ '.' \d+ ]?) /;
    return "Raku++ $0" if $v ~~ / 'Raku++' \s+ (\S+) /;
    $v || $exe
}

sub record(@cases, Str $oracle, Str $engine) {
    my $ov = version-of($oracle);
    my $ev = version-of($engine);
    die "record: REFUSED — '$oracle' and '$engine' are both $ov; the oracle must be a real Rakudo\n"
        if $ov eq $ev;
    say "record: oracle $ov ($oracle) · engine $ev ($engine)";
    my @entries;
    for @cases -> %case {
        my %r;
        for (rakudo => $oracle, rakupp => $engine) -> $p {
            my %a = run-bounded($p.value, %case<file>);
            my %b = run-bounded($p.value, %case<file>);
            %a<unstable> = True if %a<out> ne %b<out> || %a<exit> != %b<exit>;
            %r{$p.key} = %a;
        }
        my $same = %r<rakudo><out> eq %r<rakupp><out> && (%r<rakudo><exit> == 0) == (%r<rakupp><exit> == 0);
        say sprintf('  %-22s %s', %case<name>, $same ?? 'same' !! 'DIFFERS');
        @entries.push: '  ' ~ %case<name>.raku ~ " => \{\n"
            ~ (<rakudo rakupp>.map: -> $k {
                  my %x = %r{$k};
                  "    $k => \{ exit => {%x<exit>}, "
                  ~ (%x<unstable> ?? 'unstable => True, ' !! '')
                  ~ "out => {%x<out>.raku}, err => {%x<err>.raku} \},\n"
              }).join
            ~ '  },';
    }
    spurt 'src/results.raku', qq:to/RAKU/;
    # Written by `rakupp build.raku --record`. Do not edit by hand: re-record.
    \{
      recorded => {Date.today.Str.raku},
      oracle   => {$ov.raku},
      engine   => {$ev.raku},
      cases    => \{
    {@entries.join("\n")}
      \},
    \}
    RAKU
    say "recorded {@cases.elems} program(s) -> src/results.raku";
}

# ---------------------------------------------------------------- verdicts

# What a reader needs to know about one program, in one word:
#   same      Raku++ prints exactly what Rakudo prints
#   rejected  a deliberately broken program, and both engines refuse it
#   differs   the two engines print different things
#   warns     same output, but only one engine complains on stderr
#   unknown   no recording for this program yet
sub verdict(%case, %res --> Str) {
    my $r = %res<cases>{%case<name>} or return 'unknown';
    my ($o, $e) = $r<rakudo>, $r<rakupp>;
    if %case<topic> eq 'invalid' {
        return 'rejected' if $o<exit> != 0 && $e<exit> != 0 && !$o<out> && !$e<out>;
        return 'differs';
    }
    return 'differs' if $o<out> ne $e<out> || ($o<exit> == 0) != ($e<exit> == 0);
    return 'warns'   if so($o<err>.trim) != so($e<err>.trim);
    'same'
}

my %LABEL =
    same     => 'Same as Rakudo',
    rejected => 'Both reject it',
    differs  => 'Differs from Rakudo',
    warns    => 'Warnings differ',
    unknown  => 'Not recorded',
;
my %ICON = same => '✓', rejected => '✓', differs => '≠', warns => '!', unknown => '?';

sub badge(Str $v --> Str) {
    '<span class="mv mv-' ~ $v ~ '">' ~ %ICON{$v} ~ ' ' ~ %LABEL{$v} ~ '</span>'
}

sub topic-info(Str $topic) {
    %SITE<topics>{$topic} // %( title => $topic.tc, blurb => '' )
}

sub short-engine(Str $v --> Str) {
    $v.subst(/ '-' \d+ '-g' .* $ /, '')
}

# ---------------------------------------------------------------- the index

sub index-page(@cases, %res --> Str) {
    my %count;
    %count{verdict($_, %res)}++ for @cases;
    my $total  = +@cases;
    my $oracle = esc(%res<oracle> // 'Rakudo');
    my $engine = esc(short-engine(%res<engine> // 'Raku++'));
    my $agree  = (%count<same> // 0) + (%count<rejected> // 0);

    my @body = '<h1>' ~ esc(%SITE<title>) ~ '</h1>',
        '<p class="tagline">' ~ esc(%SITE<tagline>) ~ '</p>',
        '<p class="map-lede">Rakumap writes small Raku programs by machine, runs each one under '
        ~ "<strong>{$oracle}</strong>, the reference compiler, and under <strong>{$engine}</strong>, "
        ~ 'the engine behind this site, and compares what they print. '
        ~ "Below are {$total} of those programs, sorted by topic. Open one to see both outputs "
        ~ 'side by side, change the code and run it yourself.</p>';

    # The scoreboard: one bar, three numbers.
    my @bar;
    for <same rejected warns differs unknown> -> $v {
        next unless %count{$v};
        @bar.push: '<span class="mv-bar-' ~ $v ~ '" style="flex:' ~ %count{$v} ~ '" title="'
            ~ %count{$v} ~ ' — ' ~ %LABEL{$v} ~ '"></span>';
    }
    @body.push: '<div class="map-score">',
        '<div class="map-score-nums">',
        "<div><b>{$agree}</b><span>of {$total} agree with Rakudo</span></div>",
        '<div><b>' ~ (%count<differs> // 0) ~ '</b><span>print something different</span></div>',
        (%count<warns> ?? '<div><b>' ~ %count<warns> ~ '</b><span>agree, but warn differently</span></div>' !! ()),
        '</div>',
        '<div class="map-bar">' ~ @bar.join ~ '</div>',
        ('<p class="map-when">Recorded ' ~ esc(%res<recorded>) ~ ' with ' ~ esc(%res<oracle>)
            ~ ' and ' ~ esc(%res<engine>) ~ '.</p>' if %res<recorded>),
        '</div>';

    @body.push: '<details class="map-how"><summary>How to read these results</summary>',
        '<ul>',
        '<li>' ~ badge('same') ~ ' Raku++ prints exactly the same text as Rakudo.</li>',
        '<li>' ~ badge('rejected') ~ ' The program is broken on purpose, and both compilers refuse to run it. That is the right answer.</li>',
        '<li>' ~ badge('differs') ~ ' The outputs are not the same. That is a lead to investigate, not automatically a Raku++ bug: '
            ~ 'sometimes both answers are valid Raku, and sometimes Rakudo is the one that is wrong.</li>',
        (%count<warns> ?? '<li>' ~ badge('warns') ~ ' Same output, but only one compiler printed a warning.</li>' !! ()),
        '</ul>',
        '<p>Most programs share a four-line tail that prints what they computed: its <b>type</b>, its <code>.raku</code> '
            ~ 'representation, its <b>string</b> form and its <b>truth</b> value. The cards show only the part before that tail.</p>',
        '</details>';

    @body.push: '<div class="map-filter" role="group" aria-label="Show">',
        '<button data-f="all" aria-pressed="true">All <span>' ~ $total ~ '</span></button>',
        '<button data-f="ok" aria-pressed="false">Agree <span>' ~ $agree ~ '</span></button>',
        '<button data-f="bad" aria-pressed="false">Differ <span>'
            ~ ((%count<differs> // 0) + (%count<warns> // 0)) ~ '</span></button>',
        '</div>';

    # Topic contents, so a reader can jump straight to regexes.
    my @topics = @cases.map(*<topic>).unique;
    @body.push: '<nav class="map-toc">' ~ @topics.map({
        '<a href="#' ~ $_ ~ '">' ~ esc(topic-info($_)<title>) ~ '</a>'
    }).join ~ '</nav>';

    for @topics -> $topic {
        my @in = @cases.grep(*<topic> eq $topic);
        my %info = topic-info($topic);
        my $ok = +@in.grep({ verdict($_, %res) eq 'same' | 'rejected' });
        @body.push: '<section class="map-topic" id="' ~ $topic ~ '">',
            '<h2>' ~ esc(%info<title>) ~ ' <span class="map-topic-score">' ~ $ok ~ ' of ' ~ @in.elems ~ ' agree</span></h2>',
            (%info<blurb> ?? '<p>' ~ esc(%info<blurb>) ~ '</p>' !! ()),
            '<div class="map-programs">';
        for @in -> %case {
            my $v = verdict(%case, %res);
            my $f = $v eq 'same' | 'rejected' ?? 'ok' !! 'bad';
            my @lines = %case<snippet>.lines;
            my $shown = @lines.head(4).join("\n") ~ (@lines > 4 ?? "\n…" !! '');
            @body.push: '<a class="map-program" data-f="' ~ $f ~ '" href="' ~ $BASE ~ '/' ~ %case<name> ~ '/">'
                ~ '<pre>' ~ esc($shown) ~ '</pre>'
                ~ '<span class="map-card-foot">' ~ badge($v) ~ '<span>#' ~ %case<number> ~ '</span></span></a>';
        }
        @body.push: '</div>', '</section>';
    }

    @body.push: q:to/JS/;
    <script>
    (function () {
      var btns = document.querySelectorAll('.map-filter button');
      btns.forEach(function (b) {
        b.addEventListener('click', function () {
          var f = b.dataset.f;
          btns.forEach(function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); });
          document.querySelectorAll('.map-program').forEach(function (c) {
            c.hidden = f !== 'all' && c.dataset.f !== f;
          });
          document.querySelectorAll('.map-topic').forEach(function (s) {
            s.hidden = !s.querySelector('.map-program:not([hidden])');
          });
        });
      });
    })();
    </script>
    JS
    page(%SITE<title> ~ ' — generated Raku programs, checked against Rakudo', @body.join("\n"))
}

# ---------------------------------------------------------------- one program

# The harness prints KEY<tab>value lines; a table reads better than raw text.
sub fields(Str $out) {
    my @f;
    for $out.lines -> $l {
        return Nil unless $l ~~ / ^ (TYPE | RAKU | STR | BOOL | PHASE) \t (.*) $ /;
        @f.push: ~$0 => ~$1;
    }
    @f ?? @f !! Nil
}

my %FIELD =
    TYPE => 'Type <small>.^name</small>',
    RAKU => 'Code form <small>.raku</small>',
    STR  => 'String <small>.Str</small>',
    BOOL => 'True or false <small>.Bool</small>',
    PHASE => 'Printed by a phaser',
;

sub outblock(Str $text, Str $empty = 'nothing') {
    $text.chars
        ?? '<pre class="map-out">' ~ esc($text.chomp) ~ '</pre>'
        !! '<p class="map-none">(' ~ ($empty eq 'nothing' ?? 'printed nothing' !! $empty) ~ ')</p>'
}

# What an empty stderr means depends on how the run ended.
sub quiet(%run --> Str) {
    %run<exit> == 0 ?? 'no error — the program ran to the end' !! 'nothing, but exited with status ' ~ %run<exit>
}

sub comparison(%case, %res --> Str) {
    my $r = %res<cases>{%case<name>}
        or return '<p class="map-none">This program has not been recorded yet.</p>';
    my ($o, $e) = $r<rakudo>, $r<rakupp>;
    my $oracle = esc(%res<oracle>);
    my $engine = esc(short-engine(%res<engine>));
    my @h = '<h2>What each compiler printed</h2>';

    my $fo = fields($o<out>);
    my $fe = fields($e<out>);
    if $fo && $fe && $fo.elems == $fe.elems && $fo.map(*.key) eq $fe.map(*.key) {
        @h.push: '<div class="map-table-wrap"><table class="map-table">',
            "<thead><tr><th></th><th>{$oracle}</th><th>{$engine}</th></tr></thead><tbody>";
        for $fo.list Z $fe.list -> ($a, $b) {
            my $same = $a.value eq $b.value;
            @h.push: '<tr class="' ~ ($same ?? 'eq' !! 'ne') ~ '"><th>' ~ (%FIELD{$a.key} // $a.key)
                ~ '</th><td><code>' ~ esc($a.value) ~ '</code></td><td><code>' ~ esc($b.value) ~ '</code>'
                ~ ($same ?? '' !! ' <span class="map-flag">≠</span>') ~ '</td></tr>';
        }
        @h.push: '</tbody></table></div>';
    }
    else {
        @h.push: '<div class="map-side">',
            "<div><h3>{$oracle}</h3>" ~ outblock($o<out>) ~ '</div>',
            "<div><h3>{$engine}</h3>" ~ outblock($e<out>) ~ '</div>',
            '</div>';
    }

    if $o<err>.trim || $e<err>.trim {
        my $label = %case<topic> eq 'invalid' ?? 'Error messages' !! 'Errors and warnings';
        @h.push: "<h3 class=\"map-sub\">{$label}</h3>",
            '<div class="map-side map-errs">',
            "<div><h4>{$oracle}</h4>" ~ outblock($o<err>, quiet($o)) ~ '</div>',
            "<div><h4>{$engine}</h4>" ~ outblock($e<err>, quiet($e)) ~ '</div>',
            '</div>';
        @h.push: '<p class="map-note">The wording of an error message is up to each compiler; what matters is that both refuse the program.</p>'
            if verdict(%case, %res) eq 'rejected';
    }
    for <rakudo rakupp> -> $k {
        @h.push: '<p class="map-note">' ~ ($k eq 'rakudo' ?? $oracle !! $engine)
            ~ ' printed different output on two runs of this program, so either answer may appear.</p>'
            if $r{$k}<unstable>;
    }
    @h.join("\n")
}

sub banner(%case, %res --> Str) {
    my $v = verdict(%case, %res);
    my $oracle = esc(%res<oracle> // 'Rakudo');
    my $engine = esc(short-engine(%res<engine> // 'Raku++'));
    my $r = %res<cases>{%case<name>};
    my ($title, $text);
    given $v {
        when 'same' {
            $title = "{$engine} prints exactly what {$oracle} prints";
            $text  = "This is valid Raku: {$oracle}, the reference compiler, runs it without complaint, "
                   ~ 'and the two outputs match character for character.';
        }
        when 'rejected' {
            $title = 'Both compilers refuse this program — correctly';
            $text  = 'The program is broken on purpose. The right behaviour is a compile-time error '
                   ~ 'instead of output, and that is what both compilers give.';
        }
        when 'warns' {
            $title = 'Same output, different warnings';
            my ($loud, $silent) = $r<rakudo><err>.trim ?? ($oracle, $engine) !! ($engine, $oracle);
            $text  = "Both compilers print the same result, but {$loud} also writes a warning and {$silent} does not. "
                   ~ 'See the messages below.';
        }
        when 'differs' {
            if %case<topic> eq 'invalid' {
                if $r && $r<rakudo><exit> != 0 && $r<rakupp><exit> == 0 {
                    $title = "{$oracle} rejects this broken program; {$engine} runs it anyway";
                    $text  = 'The program is broken on purpose, so the right behaviour is a compile-time error. '
                           ~ "{$oracle} reports one; {$engine} accepts the program without an error. "
                           ~ 'Here the reference compiler is right.';
                }
                else {
                    $title = 'The compilers disagree about whether this program is valid';
                    $text  = 'The program is broken on purpose and should be rejected, but not both compilers refuse it.';
                }
            }
            elsif $r && $r<rakudo><exit> != 0 {
                $title = "{$oracle} fails on this program; {$engine} " ~ ($r<rakupp><exit> == 0 ?? 'runs it' !! 'fails differently');
                $text  = 'The reference compiler does not run this program cleanly, so there is no reference answer to match.';
            }
            else {
                $title = "{$engine} prints something different from {$oracle}";
                $text  = "{$oracle} runs this program cleanly; the lines marked ≠ below are where the answers part. "
                       ~ 'A difference is a lead, not a verdict: sometimes both are valid Raku, and sometimes Rakudo is the one that is wrong.';
            }
        }
        default {
            $title = 'Not recorded yet';
            $text  = 'Nobody has run this program under both compilers since it was added. Press Run to see what Raku++ prints.';
        }
    }
    my $finding = %case<finding> && $v eq 'differs' | 'warns'
        ?? ' <a href="' ~ %SITE<repo> ~ '/tree/main/fixtures/findings/' ~ %case<name>
           ~ '">This difference is preserved as a Rakumap finding ↗</a>'
        !! '';
    '<div class="map-verdict mv-box-' ~ $v ~ '"><span class="map-verdict-icon">' ~ %ICON{$v} ~ '</span>'
        ~ '<div><strong>' ~ $title ~ '</strong><p>' ~ $text ~ $finding ~ '</p></div></div>'
}

sub case-page(%case, %res, $prev, $next --> Str) {
    my %info = topic-info(%case<topic>);
    my $rows = min(%case<code>.lines.elems + 1, 28);
    my @body = '<p class="crumb"><a href="' ~ $BASE ~ '/">← All programs</a> · <a href="' ~ $BASE ~ '/#'
            ~ %case<topic> ~ '">' ~ esc(%info<title>) ~ '</a></p>',
        '<h1>' ~ esc(%info<title>) ~ ' <span class="map-num">#' ~ %case<number> ~ '</span></h1>',
        banner(%case, %res);

    @body.push: '<h2>The program</h2>';
    @body.push: '<p>The first lines compute <code>$value</code>. The last four lines are the same in every program: '
        ~ 'they print what kind of thing <code>$value</code> is, how it looks as code, as a string, and as true or false.</p>'
        if has-harness(%case<code>);
    @body.push: '<pre data-raku data-rows="' ~ $rows ~ '">' ~ esc(%case<code>.chomp) ~ '</pre>',
        '<p class="map-note">Run executes the program in your browser, with the Raku++ build this site ships. '
        ~ 'Edit it and try variations.</p>';

    @body.push: comparison(%case, %res);

    @body.push: '<p class="map-links">' ~ %case<group> ~ ' · seed ' ~ %case<seed>
        ~ (%res<recorded> ?? ' · recorded ' ~ esc(%res<recorded>) ~ ' with ' ~ esc(%res<oracle>) ~ ' and ' ~ esc(%res<engine>) !! '')
        ~ ' · <a href="' ~ %SITE<repo> ~ '/blob/main/' ~ %case<repo-path> ~ '">Source on GitHub ↗</a></p>';

    my @nav;
    @nav.push('<a href="' ~ $BASE ~ '/' ~ $prev<name> ~ '/">← ' ~ esc(topic-info($prev<topic>)<title>) ~ ' #' ~ $prev<number> ~ '</a>') if $prev;
    @nav.push('<a class="next" href="' ~ $BASE ~ '/' ~ $next<name> ~ '/">' ~ esc(topic-info($next<topic>)<title>) ~ ' #' ~ $next<number> ~ ' →</a>') if $next;
    @body.push('<nav class="map-next">' ~ @nav.join(' ') ~ '</nav>') if @nav;
    page(%info<title> ~ ' #' ~ %case<number> ~ ' — Rakumap', @body.join("\n"), :editor)
}

sub MAIN(Bool :$clean = False, Str :$map = '', Bool :$record = False,
         Str :$oracle = 'rakudo', Str :$engine = 'rakupp') {
    %SITE = EVAL slurp('src/site.raku');
    $BASE = %SITE<base>;
    my $root = ($map || %SITE<map-src>).IO.absolute.IO;
    my %rank = %SITE<order>.antipairs;
    my @cases = read-cases($root).sort({ %rank{.<topic>} // 999, .<name> });
    die 'Rakumap generated corpus is empty' unless @cases;
    return record(@cases, $oracle, $engine) if $record;

    my %res = 'src/results.raku'.IO.f ?? (EVAL slurp('src/results.raku')) !! %( cases => {} );
    my @missing = @cases.grep({ !%res<cases>{.<name>} });
    note "map: {+@missing} program(s) not recorded — run `rakupp build.raku --record`" if @missing;

    run('rm', '-rf', 'out') if $clean && 'out'.IO.d;
    mkdir('out');
    for @cases.kv -> $i, %case {
        mkdir("out/{%case<name>}");
        my $prev = $i > 0 ?? @cases[$i - 1] !! Nil;
        my $next = $i < @cases.end ?? @cases[$i + 1] !! Nil;
        spurt("out/{%case<name>}/index.html", case-page(%case, %res, $prev, $next));
    }
    spurt('out/index.html', index-page(@cases, %res));
    say "built {@cases.elems} Rakumap program page(s) + index -> out/";
}
