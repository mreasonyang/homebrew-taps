class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.35/j-jump-0.0.35-aarch64-apple-darwin.tar.gz"
      sha256 "53baa02056684481744cb74ec02c5e5d9cd2d790777dba44516c229656f12560"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.35/j-jump-0.0.35-x86_64-apple-darwin.tar.gz"
      sha256 "fcc162baef0f74d648783a050c5d2f42c7b90c72130eb17764c6e87014b46c2c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.35/j-jump-0.0.35-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f3e2af1cd0d149890f8f05a51d5c498f35ddcd74665be2231f05af1692f2d303"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.35/j-jump-0.0.35-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2c68d29c06ac1eafeb123a6114e965ba4331d339ed10e5f7aa3f278e1b803aac"
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
