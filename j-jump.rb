class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.42/j-jump-0.0.42-aarch64-apple-darwin.tar.gz"
      sha256 "1c8cb24a9e3a6be37d409363847d9bb6f39da2b9465eb94c4a86046028080dd9"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.42/j-jump-0.0.42-x86_64-apple-darwin.tar.gz"
      sha256 "f26fdd7cf0c698423e23d5ad7c28368504835073f8a59dd17bd61d113213f125"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.42/j-jump-0.0.42-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0ff2952cae4904ec2986de00fb6dd7cd812ba52af2eb60ca3af3498e3530c361"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.42/j-jump-0.0.42-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4f51bc28572d068e6633dd3bccbf73c4c1a63375370850e816b0ac9ba1474300"
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
