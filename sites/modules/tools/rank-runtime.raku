#!/usr/bin/env rakupp
# rank-runtime.raku — how many OTHER distributions name each module as a
# RUNTIME dependency, over the latest release of every dist in the REA index.
#
#   rakupp tools/rank-runtime.raku ~/.raku/rakupp-install/rea-meta.json > rank.tsv
#
# This is the `deps` column of /modules/ecosystem/ — the ecosystem's own
# ordering, most-depended-on first. Runtime ONLY: a module that half the
# ecosystem names in `test-depends` (Test::META) is not a module half the
# ecosystem RUNS, and the page's column claims the latter.
#
# Output: `rank  dist  run`, the three columns distill-ecosweep.raku reads
# (it takes the name from column 2 and the count from column 3).

sub field($line, $key) {
    $line ~~ /'"' $key '":"' (<-["]>+) '"'/ ?? ~$0 !! ''
}

my $have-own-json = ?(try { ::('Rakupp::Internals::JSON').from-json('1') === 1 });
sub json-decode(Str $text) {
    $have-own-json
        ?? ::('Rakupp::Internals::JSON').from-json($text)
        !! Rakudo::Internals::JSON.from-json($text)
}

# `depends` is an array of strings or hashes, or a phase hash
# ({runtime => [...], test => [...]}) — only the runtime phase counts here.
# An entry hash names its module under <name>.
sub names-of($v, @out) {
    return unless $v.defined;
    if $v ~~ Positional {
        names-of($_, @out) for @$v;
    }
    elsif $v ~~ Associative {
        if $v<name>.defined {
            @out.push(~$v<name>);
        }
        else {
            names-of($v<runtime>, @out) if $v<runtime>.defined;
        }
    }
    elsif $v ~~ Str {
        @out.push($v);
    }
}

# "JSON::Fast:ver<0.17+>:auth<zef:timo>" — the name is everything before the
# first SINGLE colon. A dep that is not a Raku dist (ssl:from<native>) is not
# a distribution anyone can be blocked by.
sub dist-name(Str $s --> Str) {
    return '' if $s ~~ /':from<' <-[>]>+ '>'/ && $s !~~ /':from<raku>'/;
    my $name = $s ~~ /^ ( [ <-[:\s]>+ | '::' ]+ ) / ?? ~$0 !! '';
    return '' if $name eq 'Rakudo' | 'perl6' | 'nqp';
    $name
}

sub MAIN($rea) {
    # pass 1: the latest line of each dist, kept as TEXT — json-decode runs
    # over the ~2.5k survivors, not all 15k dist-versions
    my %latest;
    for $rea.IO.lines -> $line {
        next unless $line.starts-with('{');
        my $date = field($line, 'release-date');
        my $dist = field($line, 'dist');
        my $name = $dist ~~ /^ (.+?) ':ver<'/ ?? ~$0 !! field($line, 'name');
        next unless $name && $date;
        my $have = %latest{$name};
        if !$have.defined || $date gt $have<date> {
            %latest{$name} = { :$date, :$line };
        }
    }
    note "{%latest.elems} dists at latest version";

    my %count;
    for %latest.kv -> $dist, %e {
        # the index is a JSON array printed one object per line, so every
        # line but the last drags the array's comma along
        my %m = try json-decode(%e<line>.trim.subst(/ ',' $ /, ''));
        next unless %m;
        my @names;
        names-of(%m<depends>, @names);
        # a dist naming itself is not a dependent, and naming the same
        # module twice (two phases, two spellings) still counts once
        %count{$_}++ for @names.map(&dist-name).grep({ .chars && $_ ne $dist }).unique;
    }

    my @ranked = %count.pairs.sort({ $^b.value <=> $^a.value || $^a.key leg $^b.key });
    note "{+@ranked} modules named as a runtime dependency";
    say "rank\tdist\trun";
    say "{$_ + 1}\t{@ranked[$_].key}\t{@ranked[$_].value}" for ^@ranked;
}
