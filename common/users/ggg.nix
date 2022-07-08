{ config, pkgs, ... }:

{
  users.users.ggg = {
    uid = 1000;
    isNormalUser = true;
    description = "GGG";
    extraGroups = [ "wheel" "data-members" "grafana" "prometheus" "libvirtd" "nginx" "docker" ];
    hashedPassword = config.my.secrets.users.ggg.hashedPassword;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn ggg"
    ];
    packages = with pkgs; [ man git netcat tcpdump htop nmon restic ];
  };

  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.ggg.openssh.authorizedKeys.keys;

  nix.settings.trusted-users = [ "ggg" ];
}
