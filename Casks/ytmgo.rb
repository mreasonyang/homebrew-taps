cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.63"
  sha256 arm:   "73ff3806dfbb1622424ef8cf3a3ac1bec70767fba062d209a2635718d07f0aef",
         intel: "1d525b3fb9f6d67f36afa0107d1afbb591c447c8dada9324266a8861c5028e98"

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
