{ inputs, system, ... }:
{
  home-manager.users.ggg = {
    programs = {
      dircolors.enable = true;
      eza = {
        enable = true;
        extraOptions = [
          "-a"
          "-g"
        ];
      };
    };

    home.file = {
      ".cache/nix-index/files".source = inputs.nix-index-database.packages.${system}.nix-index-database;
    };
  };
}
