#!/usr/bin/env rakupp
# IO::Path::XDG — The directories
# https://raku.online/modules/io-path-xdg/#the-directories
#
# Install what it needs, then run it:
#     rakupp install IO::Path::XDG
#     rakupp 01-directories.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

%*ENV<XDG_CONFIG_HOME> = '/home/ada/.config';
%*ENV<XDG_DATA_HOME>   = '/home/ada/.local/share';
%*ENV<XDG_CACHE_HOME>  = '/home/ada/.cache';
%*ENV<XDG_CONFIG_DIRS> = '/etc/xdg:/opt/site/etc';
%*ENV<XDG_DATA_DIRS>:delete;

use IO::Path::XDG;

say xdg-config-home;
say xdg-data-home.add('myapp');
say xdg-cache-home.basename;
say xdg-config-dirs.join(' ');
say xdg-data-dirs.join(' ');
say xdg-config-home.^name;

# Output:
#     "/home/ada/.config".IO
#     "/home/ada/.local/share/myapp".IO
#     .cache
#     /home/ada/.config /etc/xdg /opt/site/etc
#     /home/ada/.local/share /usr/local/share /usr/share
#     IO::Path
