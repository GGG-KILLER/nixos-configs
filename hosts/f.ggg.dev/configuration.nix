{...}: let
  sshPort = 17606;
in {
  imports = [
    ./hardware-configuration.nix
    ./store.nix
  ];

  networking.hostName = "f"; # Define your hostname.
  networking.domain = "ggg.dev";

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [sshPort];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [sshPort];
  networking.firewall.allowedUDPPorts = [sshPort];

  zramSwap.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
