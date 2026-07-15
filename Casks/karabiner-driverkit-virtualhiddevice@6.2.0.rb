cask "karabiner-driverkit-virtualhiddevice@6.2.0" do
  version "6.2.0"
  sha256 "9e8c46239f0748161241e42444857901224e5c82f5b58a1731df4c70bf0736a8"

  url "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v#{version}/Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"
  name "Karabiner-DriverKit-VirtualHIDDevice"
  desc "DriverKit-based virtual keyboard and mouse"
  homepage "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice"

  livecheck do
    skip "Pinned to the driver version supported by Kanata 1.12.0"
  end

  conflicts_with cask: "karabiner-driverkit-virtualhiddevice"
  depends_on macos: :ventura

  pkg "Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"

  postflight do
    daemon_label = "homebrew.mxcl.karabiner-driverkit-virtualhiddevice"
    daemon_plist = staged_path/"#{daemon_label}.plist"
    daemon_plist.write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{daemon_label}</string>
        <key>ProcessType</key>
        <string>Interactive</string>
        <key>ProgramArguments</key>
        <array>
          <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    XML

    destination = "/Library/LaunchDaemons/#{daemon_label}.plist"
    system_command "/bin/launchctl",
                   args:         ["bootout", "system/#{daemon_label}"],
                   must_succeed: false,
                   print_stderr: false,
                   print_stdout: false,
                   sudo:         true
    system_command "/usr/bin/install",
                   args: ["-o", "root", "-g", "wheel", "-m", "0644", daemon_plist, destination],
                   sudo: true
    system_command "/bin/launchctl",
                   args: ["bootstrap", "system", destination],
                   sudo: true
  end

  # Keep the system extension active during upgrades, matching Karabiner Elements.
  uninstall launchctl: "homebrew.mxcl.karabiner-driverkit-virtualhiddevice",
            script:    {
              executable: "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/remove_files.sh",
              sudo:       true,
            },
            pkgutil:   "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice"

  caveats <<~EOS
    This release uses client protocol 5, the version supported by Kanata 1.12.0.

    Activate the system extension after installation:
      sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate

    The standalone daemon is installed and started as the system LaunchDaemon
    `homebrew.mxcl.karabiner-driverkit-virtualhiddevice`.

    Do not install this standalone package alongside Karabiner Elements; it
    already installs and manages a VirtualHIDDevice driver.
  EOS
end
