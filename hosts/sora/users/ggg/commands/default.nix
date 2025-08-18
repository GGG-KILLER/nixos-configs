{ self, pkgs, config, system, ... }:
{
  home-manager.users.ggg.home.packages =
    let
      inherit (self.packages.${system}) mkCommand;
    in
    [
      (mkCommand {
        dependencies = with pkgs; [
          restic
          coreutils
        ];
        buildInputs = with pkgs; [ bash ];

        filePath = ./restic-b2;

        replacements = {
          soraPasswordFile = config.age.secrets.backup-password.path;
          soraEnvironmentFile = config.age.secrets.backup-envfile.path;

          shiroPasswordFile = config.age.secrets.shiro-backup-password.path;
          shiroEnvironmentFile = config.age.secrets.shiro-backup-envfile.path;
        };
      })
      (mkCommand {
        dependencies = with pkgs; [ streamlink ];
        buildInputs = with pkgs; [ bash ];

        filePath = ./dl-twitch-stream;
      })
    ];
}
