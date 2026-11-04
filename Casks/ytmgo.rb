cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.5"
  sha256 arm:   "73c3fb83a6a99523c38cd117c018ec74fa301c829a846f283490f6bf7d5a982a",
         intel: "f5f2c13a258310d52ed8785335d7dfb644d9d448c7924e7766d4d62f45184799"

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
