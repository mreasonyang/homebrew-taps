cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.4"
  sha256 arm:   "31a21d38ac56c8f834c99c1ad8957558766f034a3cbdf9c851116fe52b55a69a",
         intel: "e2c24d0fe6a5ffd464a30a7fb6463ae987ad049edd70cee29a2d896e90ba7621"

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
