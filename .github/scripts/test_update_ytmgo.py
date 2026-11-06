import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import update_ytmgo as updater


class ReleaseValidationTests(unittest.TestCase):
    def setUp(self):
        self.version = "0.6.4"
        self.commit = "a" * 40
        self.archive = "ytmgo-" + self.version + "-arm64-notarized.zip"
        self.metadata = {"version": self.version, "architecture": "arm64", "mode": "notarized",
                         "minimum_macos": "13.0", "commit": self.commit,
                         "developer_id_signed": True, "notarized": True, "signed_updates": True}
        self.refresh()

    def refresh(self):
        files = {"build.json": json.dumps(self.metadata).encode(), self.archive: b"synthetic archive",
                 "build-amd64.json": json.dumps(dict(self.metadata, architecture="amd64")).encode(),
                 "ytmgo-" + self.version + "-amd64-notarized.zip": b"synthetic Intel archive"}
        files["SHA256SUMS"] = "".join(hashlib.sha256(data).hexdigest() + "  " + name + "\n"
                                      for name, data in files.items()).encode()
        prefix = updater.BASE + "v" + self.version + "/"
        self.files = {prefix + name: data for name, data in files.items()}
        self.release = {"tag_name": "v" + self.version, "draft": False, "prerelease": False,
                        "target_commitish": self.commit, "assets": [
                            {"name": name, "state": "uploaded", "browser_download_url": prefix + name,
                             "digest": "sha256:" + hashlib.sha256(data).hexdigest()}
                            for name, data in files.items()]}

    def test_verified_release_renders_pinned_cask(self):
        content = updater.render(self.release, self.files.__getitem__)
        self.assertIn('version "0.6.4"', content)
        self.assertIn('sha256 arm:   "' + hashlib.sha256(b"synthetic archive").hexdigest() + '"', content)
        self.assertIn('app "ytmGO.app"', content)
        self.assertNotIn("no_check", content)
        self.assertIn('intel: "amd64"', content)
        self.assertIn('depends_on macos: :ventura', content)
        self.assertIn(hashlib.sha256(b"synthetic Intel archive").hexdigest(), content)

    def test_unpublished_prerelease_and_unsafe_versions_are_rejected(self):
        for changes in ({"draft": True}, {"prerelease": True}, {"tag_name": "v0.6.3-rc.1"},
                        {"tag_name": "v0.6.003"}, {"tag_name": 'v0.6.3"; system("bad")'},
                        {"tag_name": "v0.6.2"}, {"tag_name": "v0.6.1000"}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.render(dict(self.release, **changes), self.files.__getitem__)

    def test_signing_platform_and_source_revision_must_match(self):
        baseline = copy.deepcopy(self.metadata)
        for key, value in (("notarized", False), ("developer_id_signed", False), ("signed_updates", False),
                           ("mode", "unsigned"), ("architecture", "x86_64"),
                           ("minimum_macos", "28.0"), ("commit", "b" * 40)):
            self.metadata = dict(baseline, **{key: value})
            self.refresh()
            with self.subTest(key=key), self.assertRaises(ValueError):
                updater.render(self.release, self.files.__getitem__)

    def test_tampered_metadata_and_digest_mismatch_are_rejected(self):
        for name in ("build.json", "SHA256SUMS"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                updater.render(self.release, lambda url: b"tampered" if url.endswith(name) else self.files[url])
        self.release["assets"][1]["digest"] = "sha256:" + "b" * 64
        with self.assertRaises(ValueError):
            updater.render(self.release, self.files.__getitem__)

    def test_foreign_asset_url_and_missing_digest_are_rejected(self):
        for changes in ({"browser_download_url": "https://example.com/asset"}, {"digest": ""}):
            release = copy.deepcopy(self.release)
            release["assets"][1].update(changes)
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.render(release, self.files.__getitem__)

    def test_missing_intel_artifact_is_rejected(self):
        release = copy.deepcopy(self.release)
        release["assets"] = [asset for asset in release["assets"] if asset["name"] != "ytmgo-0.6.4-amd64-notarized.zip"]
        with self.assertRaises(KeyError):
            updater.render(release, self.files.__getitem__)

    def test_downgrade_does_not_write_existing_cask(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "Casks/ytmgo.rb"
            path.parent.mkdir()
            path.write_text('cask "ytmgo" do\n  version "0.6.5"\nend\n')
            before = path.read_bytes()
            with patch.object(updater, "ROOT", root), patch.object(updater, "fetch", return_value=json.dumps(self.release).encode()):
                with self.assertRaisesRegex(ValueError, "downgrade"):
                    updater.main()
            self.assertEqual(path.read_bytes(), before)

    def test_numbering_reset_renders_verified_assets_and_updates_existing_cask(self):
        self.version = "0.0.61"
        self.archive = "ytmgo-" + self.version + "-arm64-notarized.zip"
        self.metadata["version"] = self.version
        self.refresh()
        render = updater.render
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "Casks/ytmgo.rb"
            path.parent.mkdir()
            path.write_text('cask "ytmgo" do\n  version "0.6.10"\nend\n')
            def get(url, limit=65536):
                if url.endswith("/releases/latest"):
                    return json.dumps(self.release).encode()
                return self.files[url]
            with patch.object(updater, "ROOT", root), patch.object(updater, "fetch", side_effect=get), \
                    patch.object(updater, "render", side_effect=lambda release: render(release, get)), \
                    patch("builtins.print"):
                updater.main()
            self.assertIn('version "0.0.61"', path.read_text())

    def test_numbering_reset_does_not_allow_other_downgrades(self):
        release = dict(self.release, tag_name="v0.0.61")
        for current in ("0.6.9", "0.0.62"):
            with self.subTest(current=current), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                path = root / "Casks/ytmgo.rb"
                path.parent.mkdir()
                path.write_text('cask "ytmgo" do\n  version "' + current + '"\nend\n')
                before = path.read_bytes()
                with patch.object(updater, "ROOT", root), \
                        patch.object(updater, "fetch", return_value=json.dumps(release).encode()), \
                        patch.object(updater, "render") as render:
                    with self.assertRaisesRegex(ValueError, "downgrade"):
                        updater.main()
                render.assert_not_called()
                self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
