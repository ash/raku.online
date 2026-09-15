#!/usr/bin/env rakupp
# Pod::Tangle — Telling success from failure
# https://raku.online/modules/pod-tangle/#telling-success-from-failure
#
# Install what it needs, then run it:
#     rakupp install Pod::Tangle
#     rakupp 03-guard.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Tangle;

my $dir = $*TMPDIR.add("tangle3-{$*PID}");
LEAVE { .unlink for $dir.dir; $dir.rmdir }
$dir.mkdir;
$dir.add('good.raku').spurt("my \$x = 1;\n=begin pod\ndocs\n=end pod\nsay \$x;\n");
$dir.add('abbrev.raku').spurt("=head1 NAME\nsay 1;\n");
$dir.add('podonly.raku').spurt("=begin pod\njust docs\n=end pod\n");
$dir.add('empty.raku').spurt('');

say 'an empty result cannot be distinguished from a legitimate one —';
say 'a Pod-only file and an empty file both tangle to "":';
for <good abbrev podonly empty> -> $n {
    my $r = tangle($dir.add("$n.raku"));
    say sprintf('  %-10s -> code survived ? %s', $n, $r.contains('say').so);
}
say '';
say 'so check the input yourself before you trust the output:';
sub safe-tangle(IO::Path $f) {
    my $src = $f.slurp;
    die "abbreviated Pod directive in {$f.basename}"
        if $src ~~ /^^ '=' <!before 'begin'> <!before 'end'> /;
    die "no trailing newline in {$f.basename}" unless $src.ends-with("\n");
    tangle($f)
}
for <good abbrev> -> $n {
    my $r = try safe-tangle($dir.add("$n.raku"));
    say sprintf('  safe-tangle(%-12s) -> %s', "$n.raku",
                $! ?? $!.message !! 'code survived ' ~ $r.contains('say').so);
}

# Output:
#     an empty result cannot be distinguished from a legitimate one —
#     a Pod-only file and an empty file both tangle to "":
#       good       -> code survived ? True
#       abbrev     -> code survived ? False
#       podonly    -> code survived ? False
#       empty      -> code survived ? False
#     
#     so check the input yourself before you trust the output:
#       safe-tangle(good.raku   ) -> code survived True
#       safe-tangle(abbrev.raku ) -> abbreviated Pod directive in abbrev.raku
