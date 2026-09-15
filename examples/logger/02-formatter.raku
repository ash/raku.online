#!/usr/bin/env rakupp
# Logger — A pinned timestamp
# https://raku.online/modules/logger/#a-pinned-timestamp
#
# Install what it needs, then run it:
#     rakupp install Logger
#     rakupp 02-formatter.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Logger;

my $log = Logger.new(level => Logger::INFO, pattern => '[%d] %m%n');

$log.dt-formatter = sub ($x) { 'given a ' ~ $x.^name };
$log.info('what does the hook receive?');

$log.dt-formatter = sub ($dt) {
    sprintf('%04d-%02d-%02d', $dt.year, $dt.month, $dt.day)
};
$log.info('a date only');

my $a = Logger.new(level => Logger::INFO, pattern => '[%x] %m%n');
$a.ndc.push('orig');
my $b = $a.clone;
$b.ndc.push('cloned-only');
$a.info('from the original');
$b.info('from the clone');

# Output:
#     [given a DateTime] what does the hook receive?
#     [2026-09-15] a date only
#     [orig] from the original
#     [orig cloned-only] from the clone
