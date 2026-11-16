# Homebrew taps

## KeyPin

Install the signed and notarized Universal app on macOS 13 or later:

```sh
brew install --cask mreasonyang/taps/keypin
open -a KeyPin
```

The cask also links the bundled CLI as `keypin`. Choose your input source and launch-at-login preference in the app; Homebrew installation does not enable keeping or login startup.

```sh
keypin list
keypin status --json
brew update
brew upgrade --cask mreasonyang/taps/keypin
```

Sparkle in-app updates remain available. If you installed the app manually, `brew install --cask --adopt mreasonyang/taps/keypin` can adopt an identical copy of the current release; otherwise Homebrew reports a conflict.

Before uninstalling, turn off launch at login in KeyPin Settings (or run `keypin uninstall`), then run:

```sh
brew uninstall --cask mreasonyang/taps/keypin
```

Normal uninstall preserves preferences and diagnostic logs. To also remove those files and the login agent, use `brew uninstall --cask --zap mreasonyang/taps/keypin` instead.

The [updater workflow](.github/workflows/update-keypin.yml) checks the latest public stable release every six hours and can also be run manually. It verifies the release's signing/notarization metadata and checksums before changing the pinned version and SHA-256. It needs no cross-repository token. Draft releases, prereleases, incomplete assets and version downgrades are rejected. After a cask update, it dispatches the [installation workflow](.github/workflows/verify-keypin.yml) to check installation, the native CLI, signatures, reinstall and uninstall on Apple silicon and Intel macOS runners.

Project: [mreasonyang/keypin](https://github.com/mreasonyang/keypin).

## ytmGO

```sh
brew install --cask mreasonyang/taps/ytmgo
```

Project: [mreasonyang/ytmgo](https://github.com/mreasonyang/ytmgo).
