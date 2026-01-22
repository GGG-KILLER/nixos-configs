{
  lib,
  config,
  pkgs,
  ...
}:
{
  assertions = [
    {
      assertion = config.programs.zsh.enable;
      message = "programs.zsh.enable must be true for the users module. (did you include the zsh module?)";
    }
  ];

  users.mutableUsers = lib.mkDefault false;

  users.users.danbooru = {
    uid = 261;
    isSystemUser = true;
    group = "data-members";
  };
  users.users.downloader = {
    uid = 259;
    isSystemUser = true;
    group = "data-members";
  };
  users.users.file-browser = {
    uid = 262;
    isSystemUser = true;
    group = "data-members";
  };
  users.users.my-sonarr = {
    uid = 258;
    isSystemUser = true;
    group = "data-members";
  };
  users.users.my-torrent = {
    uid = 256;
    isSystemUser = true;
    group = "data-members";
  };
  users.users.streamer = {
    uid = 257;
    isSystemUser = true;
    group = "data-members";
    extraGroups = [
      "video"
      "render"
    ];
  };
  users.users.valheim = {
    uid = 260;
    isSystemUser = true;
    group = "data-members";
  };

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
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn ggg"
    ];
  };
  nix.settings.trusted-users = [ "ggg" ];
  users.users.root.openssh.authorizedKeys.keys = config.users.users.ggg.openssh.authorizedKeys.keys;
}
