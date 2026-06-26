{
  inputs,
  system,
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge optionalAttrs;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.users.ggg;
in
{
  options.ggg.users.ggg = {
    enable = mkEnableOption "the pre-configured ggg user and shared accounts";
    password = (mkEnableOption "the agenix-backed password") // {
      default = true;
    };
    root-ssh = (mkEnableOption "add ggg ssh key to root user") // {
      default = true;
    };
    hm-defaults = (mkEnableOption "the home-manager defaults for ggg") // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = config.programs.zsh.enable;
          message = "programs.zsh.enable must be true for the ggg user module. (did you include the zsh module?)";
        }
      ];

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
    }
    (mkIf cfg.root-ssh {
      users.users.root.openssh.authorizedKeys.keys = config.users.users.ggg.openssh.authorizedKeys.keys;
    })
    (mkIf cfg.password (
      optionalAttrs (options ? age) {
        age.secrets.ggg-hashed-password.file = ../../../secrets/ggg_hashed_password.age;
        users.users.ggg.hashedPasswordFile = config.age.secrets.ggg-hashed-password.path;
      }
    ))
    (mkIf cfg.hm-defaults (
      {
        assertions = [
          {
            assertion = inputs ? nix-index-database;
            message = "nix-index-database must be in the flake inputs to be able to use the ggg-programs module.";
          }
        ];
      }
      // optionalAttrs (options ? home-manager) {
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
      }
    ))
  ]);
}
