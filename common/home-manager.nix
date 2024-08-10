{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  userConfig =
    { inputs, config, ... }:
    {
      home.stateVersion = "21.03";

      # Get rid of channels
      home.activation.eliminateChannelsRoot = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        rm -f ${config.home.homeDirectory}/.nix-channels
        rm -rf ${config.home.homeDirectory}/.nix-defexpr
        ln -sf ${inputs.nixpkgs} ${config.home.homeDirectory}/.nix-defexpr

        ${getExe config.nix.package} profile wipe-history --profile ${config.home.homeDirectory}/.local/state/nix/profiles/home-manager
      '';
    };
in
{
  imports = [ (import "${inputs.home-manager}/nixos") ];

  options.modules.home.mainUsers = mkOption {
    type = types.listOf types.str;
    example = [ "root" ];
    default = [ ];
    description = "Main users for this system";
  };

  config = {
    home-manager.users = mkMerge (
      flip map config.modules.home.mainUsers (user: {
        ${user} = userConfig;
      })
    );

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };

    assertions = map (user: {
      assertion = builtins.hasAttr user config.users.users;
      message = "The main user ${user} has to exist";
    }) config.modules.home.mainUsers;
  };
}
