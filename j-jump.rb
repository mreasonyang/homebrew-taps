class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.34/j-jump-0.0.34-aarch64-apple-darwin.tar.gz"
      sha256 "8b860084098823068746b8829732ad7e61332e7e54406bb186b45cf1f8a43e0f"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.34/j-jump-0.0.34-x86_64-apple-darwin.tar.gz"
      sha256 "96fb318305ff17252dd865219351e63d85b0853a49cbed526032906f0a7e622a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.34/j-jump-0.0.34-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d2a33606a0358df169db1bc66a1af19d1edf346df529b5f78e75476dc0cb2c2e"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.34/j-jump-0.0.34-x86_64-unknown-linux-musl.tar.gz"
      sha256 "970a139c99065516c19b986dd572fd2894f62ad7278525009b6ff280c08b5fd6"
    end
  end

  def install
    bin.install "jjump"
    bin.install_symlink "jjump" => "j-jump"
    pkgshare.install "LICENSE.md", "licenses", "dependencies.json", "manifest.json", "binary.sha256"
  end

  def caveats
    <<~EOS
      Connect your shell automatically:
        jjump shell install
      Open a new terminal afterwards.
      Optional: --shell bash|zsh|fish, --cmd jump, or --rc /absolute/startup-file.
      Undo managed integration with: jjump shell uninstall
      First j/ji opens setup. Local-only setup needs no API key.
    EOS
  end

  test do
    ENV["J_JUMP_HOME"] = (testpath/"state").to_s
    ENV.delete("J_JUMP_CONFIG")
    ENV.delete("TYPESAFE_API_KEY")
    assert_match "jjump #{version}", shell_output("#{bin}/jjump --version")
    assert_match "jjump #{version}", shell_output("#{bin}/j-jump --version")
    system bin/"jjump", "config", "set", "semantic", "off"
    target = testpath/"alpha space"
    target.mkpath
    cd target do
      system bin/"jjump", "record", "--", target
    end
    assert_equal "#{target}\n", shell_output("#{bin}/jjump --offline query alpha")
    ENV.prepend_path "PATH", bin
    system "bash", "--noprofile", "--norc", "-c",
           'set -e; eval "$(jjump init bash)"; j --offline alpha; test "$PWD" = "$1"', "--", target
  end
end
