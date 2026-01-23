{ inputs, ... }:
{
  imports = [
    inputs.jovian.nixosModules.default
    ./audio
    ./programs.nix
  ];

  # Enable Steam
  jovian.steam.enable = true;
  programs.steam = {
    extest.enable = true;
    protontricks.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  # Enable gamescope as our compositor by enabling auto-start
  jovian.steam.autoStart = true;

  # Enableauto-login for our user
  jovian.steam.user = "ggg";

  # Enable only select Jovian NixOS settings
  # We don't need the zram swap, serial access, udev rules nor bluetooth
  jovian.steamos.useSteamOSConfig = false;
  jovian.steamos.enableDefaultCmdlineConfig = true;
  jovian.steamos.enableEarlyOOM = true;
  jovian.steamos.enableSysctlConfig = true;

  # Enable KDE for actual desktop
  jovian.steam.desktopSession = "plasma";
  services.desktopManager.plasma6.enable = true;
}
