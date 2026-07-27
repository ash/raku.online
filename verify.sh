#!/bin/sh
# Build both sites and check every example, before pushing.
#
# This does NOT publish. spec.raku.online is GitHub Pages: push to main and
# .github/workflows/pages.yml rebuilds it. But that workflow only *builds* — it
# runs no verification at all — so this script is the gate that keeps a wrong
# example from going live.
#
# Three checks, each able to fail the run on its own:
#
#   rakupp    every declared output must match the interpreter
#   ORACLE    …and must match Rakudo, which is the authority on what is correct
#   WASM      …and must match the node-target build of raku.js under Bun, so a
#             browser-only divergence (the recursion cap, say) is caught too
#
# Configuration, from a git-ignored ./.verify.env (or ./.deploy.env), the
# environment, or the defaults:
#
#   RAKUPP   interpreter to build and verify with   (default: rakupp on PATH)
#   ORACLE   second interpreter to cross-check      (e.g. raku; optional)
#   WASM     node-target raku.js to cross-check     (optional)
set -e

cd "$(dirname "$0")"

# Local overrides. .deploy.env is still read so an existing checkout keeps
# working; its SPEC_DEST is simply ignored now that nothing is mirrored.
[ -f .verify.env ] && . ./.verify.env
[ -f .deploy.env ] && . ./.deploy.env

RAKUPP="$(command -v "${RAKUPP:-rakupp}" 2>/dev/null || true)"
[ -n "$RAKUPP" ] || { echo "rakupp not found (set RAKUPP, or put it on PATH)" >&2; exit 1; }

echo "==> Spec"
"$RAKUPP" build.raku --clean --verify --rakupp="$RAKUPP" \
    ${ORACLE:+--oracle="$ORACLE"} ${WASM:+--wasm="$WASM"}

# The Rules sub-site into out/rules. Must follow build.raku, which owns out/
# and clears it with --clean.
echo "==> Rules"
"$RAKUPP" rules.raku --verify --rakupp="$RAKUPP" ${ORACLE:+--oracle="$ORACLE"}

echo
echo "$(find out -name '*.html' | wc -l | tr -d ' ') page(s) built and verified."
echo "Nothing was published: push to main and GitHub Pages rebuilds the site."
