{ config, ... }:
{
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # GitHub token to avoid 429's
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-token.path}
  '';

  nix.settings = {
    # Substitution
    http-connections = 0;
    download-buffer-size = 500 * 1024 * 1024;
    max-substitution-jobs = 128;

    # Building
    log-lines = 40;
    max-jobs = "auto";
    keep-derivations = true; # keep derivations, so we don't need to redownload/recreate.
    keep-outputs = true; # keep build inputs, so we don't need to redownload.
    system-features = [ "gccarch-znver3" ];

    # Store
    min-free = 50 * 1024 * 1024 * 1024; # have at least 50 GiB free
    preallocate-contents = true;

    # Security
    require-drop-supplementary-groups = true;
    use-cgroups = true;
  };

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 3d";
  };
}
