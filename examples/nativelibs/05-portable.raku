#!/usr/bin/env rakupp
# NativeLibs — Where the two engines differ
# https://raku.online/modules/nativelibs/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install NativeLibs
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use NativeLibs;

my $lib = NativeLibs::Loader.load(NativeLibs::cannon-name('m'));
say 'check the pointer, not the Failure:';
for 'cos', 'no_such_symbol_xyz' -> $sym {
    my $p = $lib.symbol($sym);
    my $ok = $p.defined && +$p != 0;
    say sprintf('  symbol(%-20s) usable ? %s', $sym.raku, $ok);
}
$lib.dispose;
say '';
say 'that `$p.defined && +$p != 0` test is the portable one — on Rakudo';
say 'the second row is a Failure and on Raku++ it is a null Pointer, and';
say 'both fail the test.';
say '';
say 'two more engine notes. $*VM.config<nativecall_backend> is ABSENT under';
say 'Raku++, so the module`s dyncall check compares an undefined value and';
say 'silently takes the libffi branch — which is the right branch here.';
say 'And Compile.compile-all links with $*VM.config<ldlibs>, which names';
say 'MoarVM`s own build-time libraries under Rakudo and is empty under';
say 'Raku++ — so the same build succeeds on one engine and fails on the';
say 'other for reasons that have nothing to do with your C.';

# Output:
#     check the pointer, not the Failure:
#       symbol("cos"               ) usable ? True
#       symbol("no_such_symbol_xyz") usable ? False
#     
#     that `$p.defined && +$p != 0` test is the portable one — on Rakudo
#     the second row is a Failure and on Raku++ it is a null Pointer, and
#     both fail the test.
#     
#     two more engine notes. $*VM.config<nativecall_backend> is ABSENT under
#     Raku++, so the module`s dyncall check compares an undefined value and
#     silently takes the libffi branch — which is the right branch here.
#     And Compile.compile-all links with $*VM.config<ldlibs>, which names
#     MoarVM`s own build-time libraries under Rakudo and is empty under
#     Raku++ — so the same build succeeds on one engine and fails on the
#     other for reasons that have nothing to do with your C.
