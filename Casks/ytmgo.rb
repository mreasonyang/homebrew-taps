cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.64"
  sha256 arm:   "ab3e7112d23a425b800ef28e6a5eb48e8e9ece0a0adefb860d40fd66d2a51a25",
         intel: "ee28acbac8a4da36f1c5d3e1762754dc1e9fb18dfc4690f954d59453b93803c5"

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
