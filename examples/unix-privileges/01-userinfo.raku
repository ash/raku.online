#!/usr/bin/env rakupp
# UNIX::Privileges — Looking a user up
# https://raku.online/modules/unix-privileges/#looking-a-user-up
#
# Install what it needs, then run it:
#     rakupp install UNIX::Privileges
#     rakupp 01-userinfo.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UNIX::Privileges :USER;

# root is uid 0 on every POSIX machine. Nothing here prints a login,
# a home directory or a shell.
my $u = userinfo('root');
say 'type        : ', $u.^name;
say 'attributes  : ', $u.^attributes.map(*.name).sort.join(' ');
say 'uid         : ', $u.uid;
say 'gid is Int  : ', $u.gid ~~ Int;
say 'login is Str: ', $u.login ~~ Str;
say 'home is absolute : ', $u.home.starts-with('/');
say '';
my $g = groupinfo('daemon');
say 'group type  : ', $g.^name;
say 'group attrs : ', $g.^attributes.map(*.name).sort.join(' ');
say 'gid is Int  : ', $g.gid ~~ Int;

# Output:
#     type        : UNIX::Privileges::User
#     attributes  : $!gid $!home $!login $!shell $!uid
#     uid         : 0
#     gid is Int  : True
#     login is Str: True
#     home is absolute : True
#     
#     group type  : UNIX::Privileges::Group
#     group attrs : $!gid $!name
#     gid is Int  : True
