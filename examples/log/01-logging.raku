#!/usr/bin/env rakupp
# Log — Levels, patterns, contexts
# https://raku.online/modules/log/#levels-patterns-contexts
#
# Install what it needs, then run it:
#     rakupp install Log
#     rakupp 01-logging.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Log;

my $log = Log.new(level => Log::TRACE, pattern => '[%c] %m%n');
$log.error('disk on fire');
$log.warn('disk warm');
$log.info('disk fine');
$log.debug('and the detail');

$log.level = Log::WARN;
$log.info('dropped now');
say $log.is-error, ' ', $log.is-info;

my $req = Log.new(level => Log::INFO, pattern => '[%c][%x][%X{user}] %m%n');
$req.ndc.push('req-7');
$req.ndc.push('shard-3');
$req.mdc.put('user', 'ada');
$req.info('handling');
$req.ndc.pop;
$req.info('one frame up');
$req.ndc.clear;
$req.mdc.delete('user');
$req.info('context gone');

# Output:
#     [ERROR] disk on fire
#     [WARN] disk warm
#     [INFO] disk fine
#     [DEBUG] and the detail
#     True False
#     [INFO][req-7 shard-3][ada] handling
#     [INFO][req-7][ada] one frame up
#     [INFO][undef][undef] context gone
