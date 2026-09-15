#!/usr/bin/env rakupp
# Fortune — The one thing to know
# https://raku.online/modules/fortune/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Fortune
#     rakupp 03-nil-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Fortune;

my $dir = $*TMPDIR.add("fortune2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $db = $dir.add('one');
# ONE saying, written exactly the way every fortune file is written
$db.spurt("the only saying\n\%\n");

say 'records found : ', Fortune.new($db.absolute).fortune.map(*.raku).join(' ');
say '';
my %seen;
%seen{ fortune($db.absolute).defined ?? 'a quote' !! 'Nil' }++ for ^400;
say '400 draws from a one-record database:';
say sprintf('  %-8s : %s', $_, %seen{$_} > 100 ?? 'hundreds' !! 'a few') for %seen.keys.sort;
say '';
my $bundled = Fortune.new($Fortune::DATABASE.absolute);
say 'the shipped database has ', $bundled.fortune.grep(* eq '').elems,
    ' empty records among ', $bundled.fortune.elems;

# Output:
#     records found : "the only saying" ""
#     
#     400 draws from a one-record database:
#       Nil      : hundreds
#       a quote  : hundreds
#     
#     the shipped database has 3 empty records among 16942
