cask "karabiner-driverkit-virtualhiddevice@6.2.0" do
  version "6.2.0"
  sha256 "9e8c46239f0748161241e42444857901224e5c82f5b58a1731df4c70bf0736a8"

  url "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v#{version}/Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg",
      verified: "github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/"
  name "Karabiner-DriverKit-VirtualHIDDevice"
  desc "DriverKit-based virtual keyboard and mouse for macOS"
  homepage "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice"

  livecheck do
    skip "Pinned to the driver version supported by Kanata 1.12.0"
  end

  conflicts_with cask: "karabiner-driverkit-virtualhiddevice"
  depends_on macos: :ventura

  pkg "Karabiner-DriverKit-VirtualHIDDevice-#{version}.pkg"

  uninstall early_script: {
              executable: "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/remove_files.sh",
              sudo:       true,
            },
            pkgutil:      "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice"
  # Keep the system extension active during upgrades, matching Karabiner Elements.

  caveats <<~EOS
    This release uses client protocol 5, the version supported by Kanata 1.12.0.

    Activate the system extension after installation:
      sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate

    A standalone installation also needs the daemon running:
      sudo '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'

    Do not install this standalone package alongside Karabiner Elements; it
    already installs and manages a VirtualHIDDevice driver.
  EOS
end
