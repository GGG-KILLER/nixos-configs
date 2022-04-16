{ lib, config, pkgs, options, inputs, home-manager, ... }:

with lib;
let
  cfg = config.modules.keymap;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  options.modules.home.mainUsers = mkOption {
    type = types.listOf types.str;
    example = [ "root" ];
    default = [ ];
    description = "Main users for this system";
  };
  options.modules.home.xUserConfig = mkOption {
    type = options.home-manager.users.type.functor.wrapped;
    default = { };
    description = "Home-manager configuration to be used for all main X users, this will in all cases exclude the root user";
  };

  options.modules.home.userConfig = mkOption {
    type = options.home-manager.users.type.functor.wrapped;
    default = { };
    description = "Home-manager configuration to be used for all main users";
  };

  config = {
    home-manager.users = mkMerge (
      flip map config.modules.home.mainUsers (
        user: {
          ${user} = mkMerge [
            (mkAliasDefinitions options.modules.home.userConfig)
            (
              mkIf
                (config.services.xserver.enable && user != "root")
                (mkAliasDefinitions options.modules.home.xUserConfig)
            )
          ];

        }
      )
    );

    modules.home.userConfig = { inputs, config, ... }: {
      home.stateVersion = "21.03";

      # Get rid of channels
      home.activation.eliminateChannelsRoot = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        rm -f $HOME/.nix-channels
        rm -rf $HOME/.nix-defexpr
        ln -sf ${inputs.nixpkgs} $HOME/.nix-defexpr
      '';
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs; };

    assertions =
      map
        (
          user: {
            assertion = builtins.hasAttr user config.users.users;
            message = "The main user ${user} has to exist";
          }
        )
        config.modules.home.mainUsers;
  };
}
