cask "keypin" do
  version "0.0.22"
  sha256 "d30b54539b4d45d1f350f7d90a7779c005c096c18be2653b2bf322e71b6953a3"

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
  binary "#{appdir}/KeyPin.app/Contents/MacOS/keypin"

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
