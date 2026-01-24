{ config, ... }:
{
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # GitHub token to avoid 429's
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-token.path}
  '';

  # Use sora for builds, since it has more computing power
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      hostName = "sora.lan";
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
        "gccarch-znver3"
      ];
      maxJobs = 32;
    }
  ];

  nix.settings = {
    max-jobs = 0;
    log-lines = 40;
    min-free = 50 * 1024 * 1024 * 1024; # have at least 50 GiB free
    preallocate-contents = true;
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
