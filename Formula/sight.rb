# Binary-download formula: installs the prebuilt `sight` from a GitHub Release.
# This is NOT a Homebrew bottle and NOT build-from-source — `brew install` just
# drops the standalone (Bun-compiled, codesigned) arm64 binary into the keg.
# Version + sha256 are kept current automatically by the `bump-homebrew` job in
# jbearak/sight, which opens a PR here on every `v*` release.
#
# Apple Silicon (arm64) only. Install fully-qualified: brew install jbearak/sight/sight
class Sight < Formula
  desc "Static analyzer and language server for Stata"
  homepage "https://github.com/jbearak/sight"
  url "https://github.com/jbearak/sight/releases/download/v0.10.0/sight-darwin-arm64"
  version "0.10.0"
  sha256 "d5f6b984c20a03b04a3c485ba7885b0738b3b712d163f6dc3284bac415a3cfed"
  license "GPL-3.0-or-later"

  # Drives `brew livecheck` / `brew bump` off the upstream GitHub releases.
  # The automated bump PR is the source of truth; this is a manual safety net.
  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    # The release asset is a bare arm64 binary named sight-darwin-arm64;
    # install it on PATH as `sight`.
    bin.install "sight-darwin-arm64" => "sight"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sight --version")
  end
end
