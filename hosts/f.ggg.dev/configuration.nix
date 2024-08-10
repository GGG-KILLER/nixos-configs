{ ... }:
let
  sshPort = 17606;
in
{
  imports = [
    ./backend.nix
    ./hardware-configuration.nix
    ./store.nix
  ];

  networking.hostName = "f"; # Define your hostname.
  networking.domain = "ggg.dev";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ sshPort ];
  };
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = true;
    extraOptions = [
      "-4"
      "-l 16"
      "-d 20000"
    ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    443
    sshPort
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
    sshPort
  ];

  zramSwap.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
