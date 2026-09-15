#!/usr/bin/env rakupp
# Term::Size — The native layer
# https://raku.online/modules/term-size/#the-native-layer
#
# Install what it needs, then run it:
#     rakupp install Term::Size
#     rakupp 03-native.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Term::Size;

say 'the class is a thin wrapper over two C helpers and two CStructs:';
say '  get_termsize(TermSize)            — the ioctl';
say '  get_kitty_termsize(TermSize, CellSize) — the kitty query';
say '';
say 'both return -1 with no terminal, and every struct field stays 0.';
say 'the native library itself loads fine — the failure is the ioctl, not';
say 'the %?RESOURCES lookup.';
say '';
say 'two shapes worth knowing:';
say '  TermSize.cell_width / cell_height divide by ws_col / ws_row and';
say '  return 0 rather than dividing by zero — another zero meaning';
say '  "unknown".';
say '  CellSize.ws_cwidth and ws_cheight are `is rw`, so a caller can';
say '  overwrite the measured cell size. TermSize`s fields are read-only.';

# Output:
#     the class is a thin wrapper over two C helpers and two CStructs:
#       get_termsize(TermSize)            — the ioctl
#       get_kitty_termsize(TermSize, CellSize) — the kitty query
#     
#     both return -1 with no terminal, and every struct field stays 0.
#     the native library itself loads fine — the failure is the ioctl, not
#     the %?RESOURCES lookup.
#     
#     two shapes worth knowing:
#       TermSize.cell_width / cell_height divide by ws_col / ws_row and
#       return 0 rather than dividing by zero — another zero meaning
#       "unknown".
#       CellSize.ws_cwidth and ws_cheight are `is rw`, so a caller can
#       overwrite the measured cell size. TermSize`s fields are read-only.
