cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.68"
  sha256 arm:   "bf424b773cf8778f3df5f682a14e5e165db2a3f96b6446ba381478131bc4fdb3",
         intel: "3b89ea32277c390a0073f8605e9d8a7d2ab0e37614430d566f4aa8745db14047"

  url "https://github.com/mreasonyang/ytmgo/releases/download/v#{version}/ytmgo-#{version}-#{arch}-notarized.zip"
  name "ytmGO"
  desc "Native YouTube Music desktop client"
  homepage "https://github.com/mreasonyang/ytmgo"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "ytmGO.app"

  uninstall quit: "si.kyun.ytmgo"
end
