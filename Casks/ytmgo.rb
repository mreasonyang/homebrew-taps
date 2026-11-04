cask "ytmgo" do
  version "0.6.3"
  sha256 "19c4c7a8c90ce6fab17808243975527c3fe3b21f5b926b207759745c506caaab"

  url "https://github.com/mreasonyang/ytmgo/releases/download/v#{version}/ytmgo-#{version}-arm64-notarized.zip"
  name "ytmGO"
  desc "Native YouTube Music desktop client"
  homepage "https://github.com/mreasonyang/ytmgo"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "ytmGO.app"

  uninstall quit: "si.kyun.ytmgo"
end
