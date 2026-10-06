class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.41/j-jump-0.0.41-aarch64-apple-darwin.tar.gz"
      sha256 "545671c245174567ae82491480afd68e98f97a7a0ab435d9a9f84a1f39a88a2c"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.41/j-jump-0.0.41-x86_64-apple-darwin.tar.gz"
      sha256 "1ba684dd2a8f02134bd3ed64088a12c8aa65cc8205bc8596b5be214af25acdeb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.41/j-jump-0.0.41-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3f2feafe2399c9ed8f78f4a927183e93aef0d11a477dfe18d9a9a53b1d9f049d"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.41/j-jump-0.0.41-x86_64-unknown-linux-musl.tar.gz"
      sha256 "08c7d67cb73531aa41c5a8218bda206aa734b8ff5753d970d32eee537b57f7c8"
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
