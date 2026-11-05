cask "ytmgo" do
  arch arm: "arm64", intel: "amd64"

  version "0.6.6"
  sha256 arm:   "a32960af02345eb4de9db76f6b6eb34fda807e5ae07606c5198ab5919a8a4964",
         intel: "7b83191e830520ce815ac2bed9a984b84564e96f2401c2d9b5472956d8c6b87b"

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
