{pkgs, ...}: {
  home-manager.users.ggg.home.packages = let
    mkCommand = pkgs.callPackage ../../../../../common/users/mk-command.nix;
  in [
    (mkCommand {
      dependencies = with pkgs; [curl jq];
      buildInputs = with pkgs; [bash];

      filePath = ./docker-registry-cleanup;
    })
  ];
}
