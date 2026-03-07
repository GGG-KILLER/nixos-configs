{
  lib,
  options,
  inputs,
  system,
  ...
}:
{
  # only set configs if home-manager option exists
  config = lib.optionalAttrs (options ? home-manager) {
    assertions = [
      {
        assertion = inputs ? nix-index-database;
        message = "nix-index-database must be in the flake inputs to be able to use the ggg-programs module.";
      }
    ];

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
        zsh = {
          autosuggestion.enable = true;
          autosuggestion.strategy = [
            "history"
            "completion"
          ];
          enable = true;
          enableCompletion = true;
          enableVteIntegration = true;
          history.append = true;
          history.extended = true;
          history.findNoDups = true;
          history.ignorePatterns = [
            "rm *"
            "pkill *"
          ];
          history.ignoreSpace = true;
          history.save = 1000000;
          history.share = true;
          history.size = 1000000;
          oh-my-zsh.enable = true;
          oh-my-zsh.plugins = [
            "encode64"
            "sudo"
            "timer"
          ];
          oh-my-zsh.theme = "dpoggi";
          syntaxHighlighting.enable = true;
          syntaxHighlighting.highlighters = [
            "main"
            "brackets"
          ];
        };
      };

      home.file = {
        ".cache/nix-index/files".source = inputs.nix-index-database.packages.${system}.nix-index-database;
      };
    };
  };
}
