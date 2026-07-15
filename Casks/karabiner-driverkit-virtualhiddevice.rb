cask "karabiner-driverkit-virtualhiddevice" do
  version "8.0.0"
  sha256 "0d412ea49613b70a981d816461dc3019b84a9659fde0a156939697283a61a7ac"

  url "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v#{version}/Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"
  name "Karabiner-DriverKit-VirtualHIDDevice"
  desc "DriverKit-based virtual keyboard and mouse"
  homepage "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice"

  conflicts_with cask: "karabiner-driverkit-virtualhiddevice@6.2.0"
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
    Activate the system extension after installation:
      /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate

    The standalone daemon is installed and started as the system LaunchDaemon
    `homebrew.mxcl.karabiner-driverkit-virtualhiddevice`.

    This latest release uses client protocol 7. Kanata 1.12.0 embeds protocol 5
    and is incompatible. For Kanata, install the supported cask instead:
      brew install --cask ylorn/tap/karabiner-driverkit-virtualhiddevice@6.2.0

    Do not install this standalone package alongside Karabiner Elements; it
    already installs and manages a VirtualHIDDevice driver.
  EOS
end
