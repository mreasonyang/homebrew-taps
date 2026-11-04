"""Update the cask from verified public stable-release metadata, without credentials."""
import hashlib
import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
REPO = "mreasonyang/ytmgo"
BASE = "https://github.com/" + REPO + "/releases/download/"
VERSION = re.compile(r"0\.6\.(?:0|[1-9][0-9]{0,2})")


def fetch(url, limit=65536):
    request = urllib.request.Request(url, headers={"User-Agent": "ytmgo-homebrew-updater"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read(limit + 1)
    if len(data) > limit:
        raise ValueError("release_metadata_too_large")
    return data


def release_version(release):
    tag = release.get("tag_name", "")
    if release.get("draft") is not False or release.get("prerelease") is not False or not tag.startswith("v"):
        raise ValueError("stable_public_release_required")
    version = tag[1:]
    if not VERSION.fullmatch(version) or int(version.split(".")[2]) < 3:
        raise ValueError("unsupported_release_version")
    return version


def render(release, get=fetch):
    version = release_version(release)
    assets = {asset["name"]: asset for asset in release["assets"]}
    archive = "ytmgo-" + version + "-arm64-notarized.zip"
    prefix = BASE + "v" + version + "/"

    def asset(name, download=False):
        item = assets[name]
        if item.get("browser_download_url") != prefix + name or item.get("state") != "uploaded":
            raise ValueError("invalid_release_asset")
        digest = item.get("digest", "")
        if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
            raise ValueError("release_asset_digest_required")
        if not download:
            return digest[7:]
        data = get(prefix + name)
        if hashlib.sha256(data).hexdigest() != digest[7:]:
            raise ValueError("release_metadata_checksum_mismatch")
        return data

    metadata = json.loads(asset("build.json", True))
    if (metadata.get("version") != version or metadata.get("architecture") != "arm64"
            or metadata.get("mode") != "notarized" or metadata.get("minimum_macos") != "27.0"
            or not re.fullmatch(r"[0-9a-f]{40}", metadata.get("commit", ""))
            or metadata["commit"] != release.get("target_commitish")
            or any(metadata.get(key) is not True for key in ("developer_id_signed", "notarized", "signed_updates"))):
        raise ValueError("matching_signed_notarized_release_required")
    checksums = {}
    for line in asset("SHA256SUMS", True).decode().splitlines():
        match = re.fullmatch(r"([0-9a-f]{64})  ([A-Za-z0-9._-]+)", line)
        if not match or match[2] in checksums:
            raise ValueError("invalid_release_checksums")
        checksums[match[2]] = match[1]
    digest = asset(archive)
    if checksums.get(archive) != digest or checksums.get("build.json") != asset("build.json"):
        raise ValueError("release_checksum_mismatch")
    return '''cask "ytmgo" do
  version "%s"
  sha256 "%s"

  url "https://github.com/mreasonyang/ytmgo/releases/download/v#{version}/ytmgo-#{version}-arm64-notarized.zip"
  name "ytmGO"
  desc "Native YouTube Music desktop client"
  homepage "https://github.com/mreasonyang/ytmgo"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "ytmGO.app"

  uninstall quit: "si.kyun.ytmgo"
end
''' % (version, digest)


def main():
    release = json.loads(fetch("https://api.github.com/repos/" + REPO + "/releases/latest", 1048576))
    version = release_version(release)
    path = ROOT / "Casks/ytmgo.rb"
    if path.exists():
        current = re.search(r'^  version "([^"]+)"$', path.read_text(), re.MULTILINE)
        if not current or not VERSION.fullmatch(current[1]):
            raise ValueError("unsupported_existing_cask")
        if int(version.split(".")[2]) < int(current[1].split(".")[2]):
            raise ValueError("release_downgrade_refused")
    content = render(release)
    if path.exists() and path.read_text() == content:
        print("ytmGO cask is current: " + version)
        return
    path.parent.mkdir(exist_ok=True)
    path.write_text(content)
    print("Updated ytmGO cask: " + version)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        raise SystemExit("Homebrew update failed: public release verification did not pass")
