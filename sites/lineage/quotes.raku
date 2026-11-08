# quotes.raku — which evidence entries still wait for the source's own words,
# and where in the research notes those words are recorded.
#
#   rakupp quotes.raku [--rakupp=PATH] [--page=SLUG] [--all]
#
# Every entry in src/evidence/*.json without a `quote` is listed, page by page
# in the order the page cites it, with the lines of the research notes that
# mention its source, as file:line. Filling one is then: open the note at that
# line, copy the passage into `quote` — or, when the passage is longer than the
# claim needs, quote the main part and summarise the rest in `rest` — and run
# ./build.sh lineage. --all lists the quoted entries too.
#
# The notes are rakupp's docs/dev/perl6-influence-notes/; the checkout is found
# the way sync.sh finds it (--rakupp, else $RAKUPP_SRC, else ~/raku++).

use JSON::Fast;

# The URL, then the shorter spellings the notes may use for it: without the
# scheme, without its #fragment, and its last path segment when that is a
# distinctive id (a message number, a commit hash, an issue number).
sub needles(Str $url) {
    my @n = $url, $url.subst(/ ^ 'http' 's'? '://' /, '');
    @n.push($url.subst(/ '#' .* $ /, '')) if $url.contains('#');
    my $last = $url.subst(/ '/' $ /, '').split(/ <[/#]> /).tail;
    @n.push($last) if $last.chars >= 5 && $last ~~ / \d /;
    @n.unique
}

sub md-files(IO::Path $dir) {
    gather for $dir.dir.sort -> $p {
        if $p.d { .take for md-files($p) }
        elsif $p.extension eq 'md' && $p.basename ne 'README.md' { take $p }
    }
}

# file:line for every line of the first note file, among @files, that mentions
# the source; the entry's own `note` is tried before the rest.
sub locate(Str $url, @files, IO::Path $root) {
    for needles($url) -> $n {
        for @files -> $f {
            my @lines = $f.lines;
            my @hit = (^@lines).grep({ @lines[$_].contains($n) }).map(* + 1);
            return $f.relative($root) ~ ':' ~ @hit.head(8).join(', ') ~ (@hit > 8 ?? ', …' !! '') if @hit;
        }
    }
    Nil
}

sub MAIN(Str :$rakupp = %*ENV<RAKUPP_SRC> // "$*HOME/raku++", Str :$page, Bool :$all = False) {
    my $root = "$rakupp/docs/dev/perl6-influence-notes".IO;
    die "no research notes at $root (pass --rakupp=PATH, the rakupp checkout)" unless $root.d;
    my @notes = md-files($root);
    say "notes: $root\n";

    my ($total, $quoted) = 0, 0;
    for dir('src/evidence').grep(*.extension eq 'json').sort -> $f {
        my $slug = $f.basename.subst(/ '.json' $ /, '');
        next if $page && $slug ne $page;
        my $raw = slurp($f);
        my %file = from-json($raw);
        # A hash forgets the file's order; the file is in citation order.
        my @urls = %file.keys.sort({ $raw.index('"' ~ $_ ~ '"') // Inf });
        my @open = @urls.grep({ !(%file{$_}<quote> && %file{$_}<quote>.trim) });
        $total  += @urls.elems;
        $quoted += @urls.elems - @open.elems;
        say "{$f.basename}: {@urls.elems} entries, {@urls.elems - @open.elems} quoted";
        for ($all ?? @urls !! @open) -> $url {
            my %e = %file{$url};
            my $own = %e<note> ?? $root.add(%e<note>) !! Nil;
            my @files = ($own && $own.f ?? ($own, |@notes.grep(* ne $own)) !! @notes);
            my $mark = %e<quote> && %e<quote>.trim ?? '  ✓ ' !! '    ';
            say $mark ~ $url;
            say '      ' ~ %e<who> ~ ' — ' ~ %e<when>;
            say '      ' ~ (locate($url, @files, $root) // 'not found in the notes: take the words from the source itself');
        }
        say '';
    }
    say "$quoted of $total entries quoted; {$total - $quoted} waiting";
}
