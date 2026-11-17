cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.66"
  sha256 arm:   "a2e93ec846b765f1d39ebc9e305d54c3974e206702f81e2b0cc9b7a5305ec96c",
         intel: "290b5996c3bcf3cde6d16f872d844827731edfa67d1c6ee2331932a62ae7939b"

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
