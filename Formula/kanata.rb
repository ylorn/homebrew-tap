class Kanata < Formula
  desc "Cross-platform software keyboard remapper for Linux, macOS and Windows"
  homepage "https://github.com/jtroo/kanata"
  url "https://github.com/jtroo/kanata/archive/refs/tags/v1.12.0.tar.gz"
  sha256 "7081073d1d22fe4e404cf8e7d1dfa3f72562fb2d96538367c07f64877dcbf87a"
  license "LGPL-3.0-only"
  head "https://github.com/jtroo/kanata.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args, "--features", "cmd"
  end

  def post_install
    (etc/"kanata").mkpath
  end

  service do
    run [opt_bin/"kanata", "--no-wait", "--cfg", etc/"kanata/kanata.kbd"]
    keep_alive true
    require_root true
    working_dir etc/"kanata"
    environment_variables PATH: std_service_path_env
    log_path var/"log/kanata.log"
    error_log_path var/"log/kanata.log"
  end

  def caveats
    <<~EOS
      This build enables Kanata's `cmd` feature. Configurations must also opt in:
        (defcfg danger-enable-cmd yes)

      Kanata #{version} embeds VirtualHIDDevice client protocol 5. On macOS, use
      the supported driver cask rather than the unversioned latest-driver cask:
        brew install --cask ylorn/tap/karabiner-driverkit-virtualhiddevice@6.2.0

      The root service reads #{etc}/kanata/kanata.kbd. Copy your config there
      before starting or restarting the service:
        cp ~/.config/kanata/kanata.kbd #{etc}/kanata/kanata.kbd
    EOS
  end

  test do
    (testpath/"kanata.kbd").write <<~LISP
      (defcfg
        danger-enable-cmd yes
      )

      (defsrc a)

      (deflayer base @run)

      (defalias
        run (cmd /usr/bin/true)
      )
    LISP

    system bin/"kanata", "--check", "--cfg", testpath/"kanata.kbd"
  end
end
