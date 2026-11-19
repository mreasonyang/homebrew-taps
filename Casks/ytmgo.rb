cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.67"
  sha256 arm:   "21cd18cf997758a238ad3a5c319c310e07ad1c579586d41ab931533ab49474f7",
         intel: "6fef61c934a885d06f4dfc4157770cf0165f70c8d85ddb555b0ce86e86d85a41"

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
