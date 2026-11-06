cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.10"
  sha256 arm:   "97f83c86b907c2d60275ce55be6474dde92e9f5fcaf8a1647e513e561c0243bb",
         intel: "69e8ec1fcda381e0112d5ccfa3977bea04cba13ec7c58c4e9d97459d7484d9e3"

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
