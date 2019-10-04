class KnotResolver < Formula
  desc "Minimalistic, caching, DNSSEC-validating DNS resolver"
  homepage "https://www.knot-resolver.cz"
  url "https://secure.nic.cz/files/knot-resolver/knot-resolver-4.2.1.tar.xz"
  sha256 "286e432762f8aa5e605e5e8fecf81815b55c4ed0be19a63e81fbc28171ae553b"
  head "https://gitlab.labs.nic.cz/knot/knot-resolver.git"

  depends_on "cmocka" => :build
  depends_on "pkg-config" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "gnutls"
  depends_on "knot"
  depends_on "libuv"
  depends_on "lmdb"
  depends_on "luajit"
  depends_on "nettle"

  def install

    # Meson build
    system "meson", "build_dir", "--prefix=#{prefix}", "--sysconfdir=#{etc}", "--default-library=static"
    system "ninja", "-C", "build_dir"
    system "ninja", "install", "-C", "build_dir"

    # Since we don't run `make install` or `make etc-install`, we need to
    # install root.hints manually before running `make check`.
    # cp "etc/root.hints", buildpath
    # (etc/"kresd").install "root.hints"
    #
    # %w[all lib-install daemon-install client-install modules-install
    #    check].each do |target|
    #   system "make", target, "PREFIX=#{prefix}", "ETCDIR=#{etc}/kresd"
    # end
    #
    # cp "etc/config.personal", "config"
    # inreplace "config", /^\s*user\(/, "-- user("
    # (etc/"kresd").install "config"

    # (etc/"kresd").install "etc/root.hints"
    # (etc/"kresd").install "etc/icann-ca.pem"
    #
    # (buildpath/"root.keys").write(root_keys)
    # (var/"kresd").install "root.keys"

  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>WorkingDirectory</key>
      <string>#{var}/kresd</string>
      <key>RunAtLoad</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{sbin}/kresd</string>
        <string>-c</string>
        <string>#{etc}/knot-resolver/kresd.conf</string>
        <string>-f</string>
        <string>1</string>
      </array>
      <key>StandardInPath</key>
      <string>/dev/null</string>
      <key>StandardOutPath</key>
      <string>/dev/null</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/kresd.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system sbin/"kresd", "--version"
  end
end
