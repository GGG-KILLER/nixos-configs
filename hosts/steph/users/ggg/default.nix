{
  lib,
  system,
  self,
  pkgs,
  ...
}:
{
  imports = [
    ./vscode.nix
    ./xdg-mimeapps.nix
  ];

  home-manager.users.ggg = {
    home.packages = with self.packages.${system}; [
      dl-twitch-stream
      batwhich
    ];

    home.sessionPath = [
      "$HOME/.dotnet/tools"
    ];

    programs = {
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings.editor = "code --wait";
        extensions = with pkgs; [ gh-poi ];
      };
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
      git = {
        enable = true;
        lfs.enable = true;
        signing = {
          format = "ssh";
          key = "/home/ggg/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
        settings = {
          user.name = "GGG";
          user.email = "github@ggg.dev";

          init.defaultBranch = "main";
          core.editor = "code --wait";

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
      bash.profileExtra = lib.mkOrder 900 ''
        if [ -z "$SSH_AUTH_SOCK" ]; then
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
        fi
      '';
      zsh = {
        envExtra = lib.mkOrder 900 ''
          if [ -z "$SSH_AUTH_SOCK" ]; then
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
          fi
        '';
        oh-my-zsh.plugins = [
          "copybuffer"
          "copyfile"
          "docker"
          "docker-compose"
          "dotnet"
          "git"
          "git-auto-fetch"
        ];
      };
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
        };
        bindings = {
          f = "cycle fullscreen";
          r = "playlist-shuffle";
          R = "playlist-unshuffle";
        };
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        config.global = {
          bash_path = lib.getExe pkgs.bash;
          strict_env = true;
        };
      };
    };

    services = {
      ssh-agent.enable = true;
      easyeffects.enable = true;
      flameshot.enable = false;
      jellyfin-mpv-shim.enable = true;
    };
  };
}
