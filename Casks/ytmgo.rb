cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.0.62"
  sha256 arm:   "c12740b09a27d0708f256e515526c1a8672ea23fee83d7f2b3b3cd79e80a297c",
         intel: "483ed8fba0f6ca3f47521f366064cdc3ce25899fb426d640c94d7d420db9abb9"

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
