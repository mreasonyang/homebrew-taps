cask "keypin" do
  version "0.0.23"
  sha256 "877eff51f546ad5295d07f37c1c137bd6657839698a2ae862684ddbe5a9ffe74"

  url "https://github.com/mreasonyang/keypin/releases/download/v#{version}/KeyPin-#{version}-universal.dmg"
  name "KeyPin"
  desc "Keep a preferred input source active across apps"
  homepage "https://github.com/mreasonyang/keypin"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "KeyPin.app"
  command_wrapper "keypin", executable: "#{appdir}/KeyPin.app/Contents/MacOS/keypin"

  uninstall quit: "app.keypin"

  zap launchctl: "app.keypin",
      trash:     [
        "~/Library/Application Support/KeyPin",
        "~/Library/Caches/app.keypin",
        "~/Library/Logs/KeyPin",
        "~/Library/Preferences/app.keypin.plist",
        "~/Library/Saved Application State/app.keypin.savedState",
      ]
end
