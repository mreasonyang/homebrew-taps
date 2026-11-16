import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import update_keypin as updater


class KeyPinReleaseTests(unittest.TestCase):
    def setUp(self):
        self.version = "0.0.22"
        self.archive = "KeyPin-" + self.version + "-universal.dmg"
        self.metadata = {
            "schemaVersion": 1, "tag": "v" + self.version, "version": self.version,
            "commit": "a" * 40, "architecture": "universal", "architectures": ["arm64", "x86_64"],
            "notarization": {"status": "Accepted"},
            "checks": dict.fromkeys(("developerID", "hardenedRuntime", "secureTimestamp", "staple",
                                     "gatekeeper", "archiveExtraction", "sparkleArchiveSignature",
                                     "sparkleFeedSignature"), True),
            "installer": {"format": "dmg", "developerID": True, "notarized": True,
                          "staple": True, "gatekeeper": True},
        }
        self.refresh()

    def refresh(self):
        files = {self.archive: b"synthetic universal DMG", "verification.json": json.dumps(self.metadata).encode()}
        files["SHA256SUMS"] = "".join(hashlib.sha256(data).hexdigest() + "  " + name + "\n"
                                      for name, data in files.items()).encode()
        prefix = updater.BASE + "v" + self.version + "/"
        self.files = {prefix + name: data for name, data in files.items()}
        self.release = {"tag_name": "v" + self.version, "draft": False, "prerelease": False, "assets": [
            {"name": name, "state": "uploaded", "browser_download_url": prefix + name,
             "digest": "sha256:" + hashlib.sha256(data).hexdigest()} for name, data in files.items()]}

    def test_verified_release_renders_pinned_universal_cask(self):
        content = updater.render(self.release, self.files.__getitem__)
        self.assertIn('version "0.0.22"', content)
        self.assertIn('sha256 "' + hashlib.sha256(b"synthetic universal DMG").hexdigest() + '"', content)
        self.assertIn('command_wrapper "keypin", executable: "#{appdir}/KeyPin.app/Contents/MacOS/keypin"', content)
        self.assertNotIn("no_check", content)

    def test_drafts_prereleases_and_unsafe_versions_are_rejected(self):
        for changes in ({"draft": True}, {"prerelease": True}, {"tag_name": "v0.0.23-rc.1"},
                        {"tag_name": "v0.0.023"}, {"tag_name": 'v0.0.23"; system("bad")'}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.render(dict(self.release, **changes), self.files.__getitem__)

    def test_matching_universal_signed_notarized_metadata_is_required(self):
        baseline = copy.deepcopy(self.metadata)
        changes = [("version", "0.0.21"), ("tag", "v0.0.21"), ("architecture", "arm64"),
                   ("architectures", ["arm64"]), ("commit", "invalid"), ("schemaVersion", 2),
                   ("notarization", {"status": "Rejected"}), ("checks", {}), ("installer", {})]
        for key in baseline["checks"]:
            changes.append(("checks", dict(baseline["checks"], **{key: False})))
        for key in ("developerID", "notarized", "staple", "gatekeeper"):
            changes.append(("installer", dict(baseline["installer"], **{key: False})))
        for key, value in changes:
            self.metadata = dict(baseline, **{key: value})
            self.refresh()
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                updater.render(self.release, self.files.__getitem__)

    def test_tampered_metadata_is_rejected(self):
        for name in ("verification.json", "SHA256SUMS"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                updater.render(self.release, lambda url: b"tampered" if url.endswith(name) else self.files[url])

    def test_archive_checksum_url_and_upload_state_must_match(self):
        for changes in ({"digest": "sha256:" + "b" * 64}, {"digest": ""}, {"state": "new"},
                        {"browser_download_url": "https://example.com/archive.dmg"}):
            release = copy.deepcopy(self.release)
            release["assets"][0].update(changes)
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.render(release, self.files.__getitem__)

    def test_missing_or_duplicate_archive_is_rejected(self):
        release = copy.deepcopy(self.release)
        release["assets"].pop(0)
        with self.assertRaises(KeyError):
            updater.render(release, self.files.__getitem__)
        release = copy.deepcopy(self.release)
        release["assets"].append(release["assets"][0])
        with self.assertRaises(ValueError):
            updater.render(release, self.files.__getitem__)

    def test_downgrade_does_not_change_existing_cask(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "Casks/keypin.rb"
            path.parent.mkdir()
            path.write_text('cask "keypin" do\n  version "0.0.23"\nend\n')
            before = path.read_bytes()
            with patch.object(updater, "ROOT", root), \
                    patch.object(updater, "fetch", return_value=json.dumps(self.release).encode()), \
                    patch.object(updater, "render") as render:
                with self.assertRaisesRegex(ValueError, "downgrade"):
                    updater.main()
            render.assert_not_called()
            self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
