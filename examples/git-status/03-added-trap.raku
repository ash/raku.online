#!/usr/bin/env rakupp
# Git::Status — The one thing to know
# https://raku.online/modules/git-status/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Git::Status
#     rakupp 03-added-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Git::Status;

my $repo = $*TMPDIR.add("gs3-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('base.txt').spurt("x\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;

$repo.add('staged-new.txt').spurt("new\n");
run 'git', '-C', $repo.Str, 'add', 'staged-new.txt', :out, :err;

my $porcelain = run('git', '-C', $repo.Str, 'status', '--porcelain', :out).out.slurp(:close);
say 'git itself reports : ', $porcelain.trim.raku;
my $st = Git::Status.new(directory => $repo.Str);
say 'clean flag flipped : ', !$st.is-clean;
say '.added reports     : ', $st.added.elems, ' entries';
say '.gist mentions it  : ', $st.gist.contains('staged-new') ?? 'yes' !! 'no';

# Output:
#     git itself reports : "A  staged-new.txt"
#     clean flag flipped : True
#     .added reports     : 0 entries
#     .gist mentions it  : no
