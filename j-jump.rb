class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.33/j-jump-0.0.33-aarch64-apple-darwin.tar.gz"
      sha256 "853d42e4f7b9897aeac9c3ab497268c0319e8c1e8cc4f2e03a716c42713c617d"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.33/j-jump-0.0.33-x86_64-apple-darwin.tar.gz"
      sha256 "f12ea2bfb5835bf32b9d5a034407c736cf4bf64b5c5f353b4e05a437faa8a688"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.33/j-jump-0.0.33-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8ab017b69576d07d397cd7d481223615ce4a41dff3bafc6292c7699a153c032f"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.33/j-jump-0.0.33-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1c11e0d35ac070241ccaadbd2fab8bc7aca909e1bd77f53fff0d018ccb1860f0"
    end
  end

  def install
    bin.install "jjump"
    bin.install_symlink "jjump" => "j-jump"
    pkgshare.install "LICENSE.md", "licenses", "dependencies.json", "manifest.json", "binary.sha256"
  end

  def caveats
    <<~EOS
      Activate J-Jump in your shell startup file:
        Bash: eval "$(jjump init bash)"
        Zsh:  eval "$(jjump init zsh)"
        Fish: jjump init fish | source
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
