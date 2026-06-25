#!/usr/bin/env bash
# One-time: create jbearak/homebrew-sight and seed it from this scaffold with
# the REAL Apple Silicon checksum for an existing sight release. Safe to re-run.
#
#   ./bootstrap.sh [version]      # default: 0.8.2
#
# Requires: gh (authenticated), git, perl. Run from this directory.
set -euo pipefail

VERSION="${1:-0.8.2}"; VERSION="${VERSION#v}"
OWNER=jbearak
TAP=homebrew-sight
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

tmp="$(mktemp -d)"
echo "==> Downloading sight v$VERSION macOS arm64 binary..."
gh release download "v$VERSION" -R "$OWNER/sight" \
  --pattern 'sight-darwin-arm64' \
  --dir "$tmp"

echo "==> Filling formula with real checksum..."
bin/update-formula.sh "$VERSION" "$tmp/sight-darwin-arm64"

if ! gh repo view "$OWNER/$TAP" >/dev/null 2>&1; then
  echo "==> Creating $OWNER/$TAP..."
  gh repo create "$OWNER/$TAP" --public \
    --description "Homebrew tap for sight, a static analyzer and language server for Stata (jbearak/sight)"
fi

echo "==> Committing and pushing..."
[[ -d .git ]] || git init -q
git add Formula README.md bin .github
git commit -qm "Seed homebrew-sight tap: sight $VERSION formula + automated bump tooling" || echo "  (nothing new to commit)"
git branch -M main
git remote get-url origin >/dev/null 2>&1 || \
  git remote add origin "https://github.com/$OWNER/$TAP.git"
git push -u origin main

cat <<EOF

Done. Next:
  1. Settings > Branches: require the "test" check on 'main'.
  2. Create the tap-write secret in jbearak/sight and flip the bump on:
       gh secret   set HOMEBREW_TAP_TOKEN   -R $OWNER/sight           # paste the token
       gh variable set ENABLE_HOMEBREW_BUMP -R $OWNER/sight --body true
  3. Verify:
       brew install $OWNER/sight/sight && sight --version
EOF
