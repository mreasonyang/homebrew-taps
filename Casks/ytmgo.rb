cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.65"
  sha256 arm:   "f5c00c33daed1de3c9df30cfbd38923289caa9330eff29718fb76b5303bd43cc",
         intel: "931241895246977c855620bd7f3d3b667991f7f67fce58022d37d6ad8948b4cd"

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
