cask "karabiner-driverkit-virtualhiddevice" do
  version "8.0.0"
  sha256 "0d412ea49613b70a981d816461dc3019b84a9659fde0a156939697283a61a7ac"

  url "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v#{version}/Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"
  name "Karabiner-DriverKit-VirtualHIDDevice"
  desc "DriverKit-based virtual keyboard and mouse for macOS"
  homepage "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice"

  conflicts_with cask: "karabiner-driverkit-virtualhiddevice@6.2.0"
  depends_on macos: :ventura

  pkg "Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"

  uninstall early_script: {
              executable: "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/remove_files.sh",
              sudo:       true,
            },
            pkgutil:      "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice"
  # Keep the system extension active during upgrades, matching Karabiner Elements.

  caveats <<~EOS
    Activate the system extension after installation:
      /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate

    A standalone installation also needs the daemon running:
      sudo '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'

    This latest release uses client protocol 7. Kanata 1.12.0 embeds protocol 5
    and is incompatible. For Kanata, install the supported cask instead:
      brew install --cask ylorn/tap/karabiner-driverkit-virtualhiddevice@6.2.0

    Do not install this standalone package alongside Karabiner Elements; it
    already installs and manages a VirtualHIDDevice driver.
  EOS
end
