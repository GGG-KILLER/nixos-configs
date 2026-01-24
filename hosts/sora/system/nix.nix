{ ... }:
{
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  nix.settings = {
    http-connections = 0;
    max-jobs = "auto";
    max-substitution-jobs = 128;
    min-free = 50 * 1024 * 1024 * 1024; # have at least 100 GiB free
    preallocate-contents = true;
    system-features = [ "gccarch-znver3" ];
    download-buffer-size = 500 * 1024 * 1024;

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
