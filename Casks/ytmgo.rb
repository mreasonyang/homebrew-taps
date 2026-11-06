cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.7"
  sha256 arm:   "8764938e0eb749ca2ab648319a168afca2f4d14ea5b2d8bc8f030249b91d7a06",
         intel: "319315bb79d561105f01db517d825d3146db26be9679560d2572e832fdd45301"

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
