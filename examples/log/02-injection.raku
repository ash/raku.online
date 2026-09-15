#!/usr/bin/env rakupp
# Log — The one thing to know
# https://raku.online/modules/log/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Log
#     rakupp 02-injection.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Log;

my $log = Log.new(level => Log::INFO, pattern => '[%c] %m%n');
$log.info('plain message');
$log.info('progress: 100%c done');
$log.info('a %x here');
$log.info('user said: %m');

# Output:
#     [INFO] plain message
#     [INFO] progress: 100INFO done
#     [INFO] a undef here
#     [INFO] user said: %m
