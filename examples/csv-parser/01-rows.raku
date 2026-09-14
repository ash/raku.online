#!/usr/bin/env rakupp
# CSV::Parser — Rows from a handle
# https://raku.online/modules/csv-parser/#rows-from-a-handle
#
# Install what it needs, then run it:
#     rakupp install CSV::Parser
#     rakupp 01-rows.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CSV::Parser;

my $file = $*TMPDIR.add("towns-{$*PID}.csv");
$file.spurt(qq:to/CSV/);
    name,population,motto
    Ashby,1200,"Small, but proud"
    Brill,950,"Says ""hello"""
    Cowes,10400,
    CSV
my $fh = $file.open;
my $csv = CSV::Parser.new(file_handle => $fh, contains_header_row => True);
until $fh.eof {
    my %row = $csv.get_line;
    next unless %row;
    say %row.keys.sort.map({ "$_=" ~ %row{$_} }).join(' | ');
}
$fh.close;
say $csv.headers.sort.map(*.value).join(',');
$file.unlink;

# Output:
#     motto=Small, but proud | name=Ashby | population=1200
#     motto=Says ""hello"" | name=Brill | population=950
#     motto= | name=Cowes | population=10400
#     name,population,motto
