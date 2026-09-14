#!/usr/bin/env rakupp
# XDG::BaseDirectory — The directories
# https://raku.online/modules/xdg-basedirectory/#the-directories
#
# Install what it needs, then run it:
#     rakupp install XDG::BaseDirectory
#     rakupp 01-directories.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

%*ENV<XDG_CONFIG_HOME> = '/home/ada/.config';
%*ENV<XDG_DATA_HOME>   = '/home/ada/.local/share';
%*ENV<XDG_CACHE_HOME>  = '/home/ada/.cache';
%*ENV<XDG_STATE_HOME>  = '/home/ada/.local/state';
%*ENV<XDG_CONFIG_DIRS> = '/etc/xdg:/opt/site/etc';
%*ENV<XDG_DATA_DIRS>:delete;
%*ENV<XDG_RUNTIME_DIR> = '/run/user/1000';

use XDG::BaseDirectory :terms;

say config-home;
say data-home.add('myapp');
say cache-home.basename, ' ', state-home.basename;
say config-dirs.join(' ');
say data-dirs.join(' ');
say runtime-dir;

# Output:
#     "/home/ada/.config".IO
#     "/home/ada/.local/share/myapp".IO
#     .cache state
#     /home/ada/.config /etc/xdg /opt/site/etc
#     /home/ada/.local/share /usr/local/share /usr/share
#     "/run/user/1000".IO
