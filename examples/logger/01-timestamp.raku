#!/usr/bin/env rakupp
# Logger — A pinned timestamp
# https://raku.online/modules/logger/#a-pinned-timestamp
#
# Install what it needs, then run it:
#     rakupp install Logger
#     rakupp 01-timestamp.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Logger;

my $log = Logger.new(
    level        => Logger::INFO,
    dt-formatter => sub ($dt) { 'TS' },
);
$log.error('disk on fire');
$log.warn('disk warm');
$log.info('disk fine');
$log.debug('dropped: level is INFO');

$log.level = Logger::TRACE;
$log.debug('now it appears');

$log.pattern = '[%c] %m%n';
$log.info('a different layout');

# Output:
#     [TS][ERROR] disk on fire
#     [TS][WARN] disk warm
#     [TS][INFO] disk fine
#     [TS][DEBUG] now it appears
#     [INFO] a different layout
