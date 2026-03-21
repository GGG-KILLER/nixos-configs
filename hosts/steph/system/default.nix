{
  pkgs,
  options,
  config,
  ...
}:
{
  imports = [
    ./desktop
    ./services
    ./boot.nix
    ./firejail.nix
    ./fonts.nix
    ./hardening.nix
    ./kernel.nix
    ./programs.nix
    ./yubikey.nix
  ];

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc # libdl
    gtk3 # libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libgdk-3.so.0
    libGL # libGL.so.1
    libice # libICE.so.6
    libsm # libSM.so.6
    libx11 # libX11 libX11.so.6
    libxcursor # libXcursor.so.1
    libxi # libXi.so.6
    libxrandr # libXrandr.so.2
    fontconfig # libfontconfig.so.1
  ];

  programs.zsh.ohMyZsh.plugins = [
    "copybuffer"
    "copyfile"
    "docker"
    "docker-compose"
    "dotnet"
    "git"
    "git-auto-fetch"
  ];

  # Enable kanidm
  services.kanidm.package = pkgs.kanidm_1_9;
  services.kanidm.client.enable = true;
  services.kanidm.client.settings.uri = "https://sso.lan";

  # SSH Agent
  programs.ssh.startAgent = true;
  systemd.user.services.ssh-agent-setup = {
    inherit (config.systemd.user.services.ssh-agent) unitConfig wantedBy;
    bindsTo = [
      "ssh-agent.service"
    ];
    environment.SSH_AUTH_SOCK = "%t/ssh-agent";
    path = [
      options.programs.ssh.package.value
    ];
    script = "${options.programs.ssh.package.value}/bin/ssh-add";
    serviceConfig = {
      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectHostname = true;
      PrivateNetwork = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = "AF_UNIX";
      RestrictNamespaces = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @resources @swap";
      UMask = "0777";
    };
  };
}
