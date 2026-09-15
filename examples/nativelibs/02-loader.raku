#!/usr/bin/env rakupp
# NativeLibs — Opening and resolving
# https://raku.online/modules/nativelibs/#opening-and-resolving
#
# Install what it needs, then run it:
#     rakupp install NativeLibs
#     rakupp 02-loader.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeLibs;

my $lib = NativeLibs::Loader.load(NativeLibs::cannon-name('m'));
say 'loaded : ', $lib.defined;
say '  name : ', $lib.name;
say '';
my $cos = $lib.symbol('cos');
say 'symbol("cos") : a Pointer, non-null : ', (+$cos != 0);
say '';
say 'disposing closes it:';
say '  dispose      : ', $lib.dispose.so;
say '';
my $missing = NativeLibs::Loader.load('libdefinitely-not-here');
say 'a library that does not exist : ',
    $missing ~~ Failure ?? 'a Failure' !! $missing.raku;

# Output:
#     loaded : True
#       name : libm.dylib
#     
#     symbol("cos") : a Pointer, non-null : True
#     
#     disposing closes it:
#       dispose      : True
#     
#     a library that does not exist : a Failure
