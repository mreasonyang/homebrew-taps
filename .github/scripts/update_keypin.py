"""Update KeyPin from its public, signed and notarized stable release."""
import hashlib
import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
REPO = "mreasonyang/keypin"
BASE = "https://github.com/" + REPO + "/releases/download/"
VERSION = re.compile(r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)")


def fetch(url, limit=65536):
    request = urllib.request.Request(url, headers={"User-Agent": "keypin-homebrew-updater"})
    with urllib.request.urlopen(request, timeout=30) as response:
        data = response.read(limit + 1)
    if len(data) > limit:
        raise ValueError("release_metadata_too_large")
    return data


def release_version(release):
    tag = release.get("tag_name", "")
    if (release.get("draft") is not False or release.get("prerelease") is not False
            or not tag.startswith("v") or not VERSION.fullmatch(tag[1:])):
        raise ValueError("stable_public_release_required")
    return tag[1:]


def render(release, get=fetch):
    version = release_version(release)
    assets = {item["name"]: item for item in release["assets"]}
    if len(assets) != len(release["assets"]):
        raise ValueError("duplicate_release_asset")
    prefix = BASE + "v" + version + "/"

    def asset(name, download=False):
        item = assets[name]
        digest = item.get("digest", "")
        if (item.get("browser_download_url") != prefix + name or item.get("state") != "uploaded"
                or not re.fullmatch(r"sha256:[0-9a-f]{64}", digest)):
            raise ValueError("invalid_release_asset")
        if not download:
            return digest[7:]
        data = get(prefix + name)
        if hashlib.sha256(data).hexdigest() != digest[7:]:
            raise ValueError("release_metadata_checksum_mismatch")
        return data

    metadata = json.loads(asset("verification.json", True))
    checks = ("developerID", "hardenedRuntime", "secureTimestamp", "staple", "gatekeeper",
              "archiveExtraction", "sparkleArchiveSignature", "sparkleFeedSignature")
    installer_checks = ("developerID", "notarized", "staple", "gatekeeper")
    if (metadata.get("schemaVersion") != 1 or metadata.get("tag") != "v" + version
            or metadata.get("version") != version or metadata.get("architecture") != "universal"
            or sorted(metadata.get("architectures", [])) != ["arm64", "x86_64"]
            or not re.fullmatch(r"[0-9a-f]{40}", metadata.get("commit", ""))
            or metadata.get("notarization", {}).get("status") != "Accepted"
            or any(metadata.get("checks", {}).get(key) is not True for key in checks)
            or metadata.get("installer", {}).get("format") != "dmg"
            or any(metadata.get("installer", {}).get(key) is not True for key in installer_checks)):
        raise ValueError("matching_signed_notarized_universal_release_required")
    checksums = {}
    for line in asset("SHA256SUMS", True).decode().splitlines():
        match = re.fullmatch(r"([0-9a-f]{64})  ([A-Za-z0-9._-]+)", line)
        if not match or match[2] in checksums:
            raise ValueError("invalid_release_checksums")
        checksums[match[2]] = match[1]
    archive = "KeyPin-" + version + "-universal.dmg"
    digest = asset(archive)
    if checksums.get(archive) != digest or checksums.get("verification.json") != asset("verification.json"):
        raise ValueError("release_checksum_mismatch")
    return '''cask "keypin" do
  version "%s"
  sha256 "%s"

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
''' % (version, digest)


def main():
    release = json.loads(fetch("https://api.github.com/repos/" + REPO + "/releases/latest", 1048576))
    version = release_version(release)
    path = ROOT / "Casks/keypin.rb"
    if path.exists():
        current = re.search(r'^  version "([^"]+)"$', path.read_text(), re.MULTILINE)
        if not current or not VERSION.fullmatch(current[1]):
            raise ValueError("unsupported_existing_cask")
        if tuple(map(int, version.split("."))) < tuple(map(int, current[1].split("."))):
            raise ValueError("release_downgrade_refused")
    content = render(release)
    if path.exists() and path.read_text() == content:
        print("KeyPin cask is current: " + version)
        return
    path.parent.mkdir(exist_ok=True)
    path.write_text(content)
    print("Updated KeyPin cask: " + version)


if __name__ == "__main__":
    main()
