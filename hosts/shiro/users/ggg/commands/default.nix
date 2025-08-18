{ self, pkgs, system, ... }:
{
  home-manager.users.ggg.home.packages =
    let
      inherit (self.packages.${system}) mkCommand;
    in
    [
      (mkCommand {
        dependencies = with pkgs; [
          coreutils
        ];
        buildInputs = with pkgs; [ bash ];

        filePath = ./find-ata;
      })
    ];
}
