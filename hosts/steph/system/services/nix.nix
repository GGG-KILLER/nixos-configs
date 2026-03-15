{ lib, config, ... }:
{
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # GitHub token to avoid 429's
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-token.path}
  '';

  # Use sora for builds, if available, since it has more computing power
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines =
    let
      mkMachine =
        {
          hostName,
          arch ? null,
          maxJobs ? 1,
        }:
        {
          protocol = "ssh-ng";
          inherit hostName;
          sshUser = "remotebld";
          sshKey = "/root/.ssh/remotebld";
          systems = [
            "x86_64-linux"
            "i686-linux"
          ];
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ]
          ++ lib.optional (arch != null) "gccarch-${arch}";
          inherit maxJobs;
        };
    in
    [
      (mkMachine {
        hostName = "sora.lan";
        maxJobs = 32;
      })
    ];

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
