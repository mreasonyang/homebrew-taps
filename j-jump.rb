class JJump < Formula
  desc "Independent directory navigation with optional Jev suggestions"
  homepage "https://github.com/mreasonyang/j-jump"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.47/j-jump-0.0.47-aarch64-apple-darwin.tar.gz"
      sha256 "a371a7796dd7080a843163001aad9a38343ff583cdaf34d96c17ab042a69a7d9"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.47/j-jump-0.0.47-x86_64-apple-darwin.tar.gz"
      sha256 "1e1ff5541fc3f730fb30e019f4aeee29fd74b772f9c3a0edc590aaadeef29fc9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.47/j-jump-0.0.47-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e5680bf85788d0cb8eca0f452b7681af1cdae6db01eda06704b60f1e3a1e1598"
    end
    on_intel do
      url "https://github.com/mreasonyang/j-jump/releases/download/v0.0.47/j-jump-0.0.47-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6a824ad5b6d92c4c592192ce87c2bfeb50180d8907c004ec5d840478ef020095"
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
