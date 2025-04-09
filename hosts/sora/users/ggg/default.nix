{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
in
{
  imports = [
    ./commands
    ./vscode.nix
  ];

  home-manager.users.ggg = {
    home.sessionPath = [
      "$HOME/.dotnet/tools"
    ];

    programs = {
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings.editor = "${getExe pkgs.vscode} --wait";
        extensions = with pkgs; [ gh-poi ];
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          init.defaultBranch = "main";
          core.editor = "${getExe pkgs.vscode} --wait";

          # Ensure integrity of things we fetch.
          transfer.fsckObjects = true;
          fetch.fsckObjects = true;
          receive.fsckObjects = true;
        };
      };
      tealdeer = {
        enable = true;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 72;
        };
      };
      zsh.oh-my-zsh.plugins = [
        "copybuffer"
        "copyfile"
        "docker"
        "docker-compose"
        "dotnet"
        "git"
        "git-auto-fetch"
      ];
      mangohud = {
        enable = true;
        settingsPerApplication = {
          mpv = {
            no_display = true;
          };
        };
      };
      mpv = {
        enable = true;
        config = {
          # Base
          profile = "high-quality";

          # General
          hwdec = "auto";
          vo = "gpu-next";
          gpu-api = "vulkan";
          gpu-context = "waylandvk";
          ao = "pipewire";

          # Disable OSC for mpv thumbnail script
          osc = "no";
        };
        bindings = {
          f = "cycle fullscreen";
          r = "playlist-shuffle";
          R = "playlist-unshuffle";
        };
      };
      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          # obs-nvfbc # TODO: Restore whenever it gets fixed.
          input-overlay
          obs-pipewire-audio-capture
        ];
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        config = {
          global = {
            bash_path = lib.getExe pkgs.bash;
            strict_env = true;
          };
        };
      };
    };

    services = {
      flameshot.enable = false;
      # opensnitch-ui.enable = true;
    };

    # TODO: re-enable when server is up
    # systemd.user.services.jellyfin-mpv-shim = {
    #   Unit = {
    #     Description = "Jellyfin MPV Shim";
    #     After = [ "graphical-session-pre.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };

    #   Service.ExecStart = getExe pkgs.jellyfin-mpv-shim;

    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
  };
}
