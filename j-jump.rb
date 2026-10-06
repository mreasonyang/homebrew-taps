class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.38/j-jump-0.0.38-aarch64-apple-darwin.tar.gz"
      sha256 "e6e07b8cc6d4f7661d11b91943b0713175bfa45a9d05dafa18c1be1bec30a5c2"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.38/j-jump-0.0.38-x86_64-apple-darwin.tar.gz"
      sha256 "ee4a5782fe62ad5ea44c69762e1fdbd09ee8b378925bac2511d033b187a75704"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.38/j-jump-0.0.38-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7e8cdcd72eea69cd788faf992e1afe1fb160ab483b75d429926701dd0b6eca9f"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.38/j-jump-0.0.38-x86_64-unknown-linux-musl.tar.gz"
      sha256 "eacb4131964a0d6c6ddb7fd8bd0884b48905bb224ea97cb3cd7c0dd9470f458d"
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
