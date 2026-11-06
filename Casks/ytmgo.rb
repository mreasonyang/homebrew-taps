cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.61"
  sha256 arm:   "de0b6d866566c9e4667289f6504b20b5b9e1470a9d628fe1113d91eeffee8e40",
         intel: "ca7d6129cdbd5d9be769d780e7658f535bd7049ef4ac130cd844b3875d91cff4"

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
