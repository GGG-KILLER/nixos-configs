{ lib, options, ... }:
{
  # only set configs if home-manager option exists
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      (
        { inputs, config, ... }:
        {
          home.stateVersion = "21.03";

          home.activation.eliminateChannelsRoot = config.lib.dag.entryAfter [ "writeBoundary" ] ''
            # Get rid of channels
            rm -f ${config.home.homeDirectory}/.nix-channels
            rm -rf ${config.home.homeDirectory}/.nix-defexpr
            ln -sf ${inputs.nixpkgs} ${config.home.homeDirectory}/.nix-defexpr

            # Clean up older config versions
            ${lib.getExe config.nix.package} profile wipe-history --profile ${config.home.homeDirectory}/.local/state/nix/profiles/home-manager
          '';
        }
      )
    ];
  };
}
