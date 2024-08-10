{
  lib,
  config,
  pkgs,
  liveCd ? false,
  ...
}:
{
  imports = lib.optional (!liveCd) ./programs.nix;

  users.users.ggg = {
    uid = 1000;
    isNormalUser = true;
    description = "GGG";
    extraGroups = [
      "adbusers"
      "data-members"
      "docker"
      "grafana"
      "libvirtd"
      "lxd"
      "nginx"
      "prometheus"
      "wheel"
      "video"
    ];
    hashedPassword = config.my.secrets.users.ggg.hashedPassword;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn ggg"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = config.users.users.ggg.openssh.authorizedKeys.keys;

  nix.settings.trusted-users = [ "ggg" ];
  modules.home.mainUsers = lib.mkIf (!liveCd) [ "ggg" ];
  programs.zsh.enable = true;
}
