# homebrew-sight

A [Homebrew](https://brew.sh) tap for [`sight`](https://github.com/jbearak/sight),
a static analyzer and language server for Stata. The formula installs a
**prebuilt macOS (Apple Silicon) binary** from sight's GitHub Releases — no
compilation, no toolchain.

## Install

```sh
brew install jbearak/sight/sight
```

`brew tap jbearak/sight` is implied by the fully-qualified install. Using the
fully-qualified path also means you trust only *this* formula, not the whole tap
— relevant as Homebrew tightens [tap trust](https://docs.brew.sh/Taps). The
binary is installed on PATH as `sight`.

## Upgrade

```sh
brew update
brew upgrade jbearak/sight/sight
```

## Brewfile

```ruby
tap "jbearak/sight"
brew "jbearak/sight/sight"
```

Then `brew bundle --file=/path/to/Brewfile`.

## Supported platforms

macOS on Apple Silicon (`arm64`) only. The formula declares `depends_on :macos`
and `depends_on arch: :arm64`; Intel macOS and Linux are intentionally out of
scope.

The shipped binary is a standalone (Bun-compiled) executable that is codesigned
in sight's release build, so `sight` runs after a normal `brew install`. If your
environment enforces an EDR/MDM policy that blocks unsigned executables, confirm
the signature satisfies it before relying on this tap.

## How updates land here

The `bump-homebrew` job in [`jbearak/sight`](https://github.com/jbearak/sight)
runs after each `v*` release is published, recomputes the Apple Silicon sha256
from the release artifact, and opens a **PR** against this repo bumping
`version` and the checksum. CI on that PR (`brew audit`/`install`/`test`) must
pass before it merges — a broken formula never reaches users via a silent push.

## Rollback / bad release

- **Never mutate a published release asset.** The pinned `sha256` is deliberate:
  silently replacing the binary will make `brew` refuse it (checksum mismatch)
  rather than ship a swapped binary.
- To pull a bad version, **revert the formula PR** (or commit) to the previous
  `version` + checksum, or cut a new patch release upstream and let the bump PR
  carry the fix forward.
- For a formula-only fix against the *same* upstream version (no URL/sha
  change), bump the formula `revision` so clients reinstall.
- **Never force-push this tap's `main`.** `brew update` rebases each client's
  local clone; rewritten history leaves git conflict markers in the formula and
  breaks `brew`. Iterate only via PRs (the bump flow already does).

## Maintainer: the tap-write token

The bump job authenticates with a secret named `HOMEBREW_TAP_TOKEN` stored in
`jbearak/sight`. A leaked token can ship arbitrary formula Ruby to anyone who
installs from this tap, so:

- Prefer a **GitHub App** installation token scoped to this repo, or a
  **fine-grained PAT** restricted to `jbearak/homebrew-sight` with **Contents:
  write** and **Pull requests: write** only.
- Set an expiration and document a rotation/revocation step.
