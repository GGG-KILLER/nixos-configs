{
  pkgs,
  config,
  lib,
  ...
}: {
  home-manager.users.ggg.home.packages = let
    mkCommand = {
      dependencies,
      filePath,
      replacements ? {},
    } @ args:
      pkgs.callPackage ./mk-command.nix args;
  in [
    (mkCommand {
      dependencies = with pkgs; [restic];
      filePath = ./restic-b2;
      replacements = {
        soraPasswordFile = config.age.secrets.backup-password.path;
        soraEnvironmentFile = config.age.secrets.backup-envfile.path;

        shiroPasswordFile = config.age.secrets.shiro-backup-password.path;
        shiroEnvironmentFile = config.age.secrets.shiro-backup-envfile.path;
      };
    })
  ];
}
