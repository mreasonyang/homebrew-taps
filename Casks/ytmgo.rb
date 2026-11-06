cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.9"
  sha256 arm:   "9a845207837d154f9aff21db590ede547993b43b8faf14c2ebd9e355ed1e0e8f",
         intel: "57c6304266dd961b27415e7b5c950b83f8872cf1d78cb7c163f4369e175842cf"

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
