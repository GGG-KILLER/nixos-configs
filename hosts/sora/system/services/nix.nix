{ config, ... }:
{
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # GitHub token to avoid 429's
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-token.path}
  '';

  nix.settings = {
    http-connections = 0;
    keep-derivations = true; # keep derivations, so we don't need to redownload/recreate.
    keep-going = true;
    keep-outputs = true; # keep build inputs, so we don't need to redownload.
    log-lines = 40;
    max-jobs = "auto";
    max-substitution-jobs = 128;
    min-free = 50 * 1024 * 1024 * 1024; # have at least 100 GiB free
    preallocate-contents = true;
    require-drop-supplementary-groups = true;
    system-features = [ "gccarch-znver3" ];
    use-cgroups = true;
    warn-dirty = false;
  };

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 3d";
  };
}
