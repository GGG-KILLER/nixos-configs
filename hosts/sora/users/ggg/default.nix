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

    # TODO: Consider versioning this here?
    # xdg.mimeApps =
    #   let
    #     associateApp = app: mimes: lib.genAttrs mimes (_: app);
    #     browserAssociations = associateApp "vivaldi-stable.desktop" [
    #       "text/html"
    #       "application/xhtml+xml"
    #       "x-scheme-handler/http"
    #       "x-scheme-handler/https"
    #       "x-scheme-handler/mailto"
    #       "x-scheme-handler/tel"
    #     ];
    #     vscodeAssociations = associateApp "code.desktop" [
    #       "application/javascript"
    #       "application/json"
    #       "application/octet-stream"
    #       "application/ovf"
    #       "application/toml"
    #       "application/x-docbook+xml"
    #       "application/x-shellscript"
    #       "application/x-wine-extension-ini"
    #       "application/x-yaml"
    #       "application/xml"
    #       "text/markdown"
    #       "text/plain"
    #       "text/x-cmake"
    #       "text/x-csharp"
    #       "text/x-log"
    #       "text/x-matlab"
    #     ];
    #     readerAssociations = associateApp "org.kde.okular.desktop" [
    #       "application/pdf"
    #       "application/vnd.comicbook+zip"
    #     ];
    #     imageAssociations = associateApp "org.kde.gwenview.desktop" [
    #       "image/avif"
    #       "image/bmp"
    #       "image/gif"
    #       "image/heic"
    #       "image/heif"
    #       "image/jpeg"
    #       "image/jpg"
    #       "image/jxl"
    #       "image/pjpeg"
    #       "image/png"
    #       "image/svg+xml-compressed"
    #       "image/svg+xml"
    #       "image/tiff"
    #       "image/vnd-ms.dds"
    #       "image/vnd.microsoft.icon"
    #       "image/vnd.radiance"
    #       "image/vnd.wap.wbmp"
    #       "image/webp"
    #       "image/x-bmp"
    #       "image/x-dds"
    #       "image/x-exr"
    #       "image/x-gray"
    #       "image/x-icb"
    #       "image/x-icns"
    #       "image/x-ico"
    #       "image/x-pcx"
    #       "image/x-png"
    #       "image/x-portable-anymap"
    #       "image/x-portable-bitmap"
    #       "image/x-portable-graymap"
    #       "image/x-portable-pixmap"
    #       "image/x-qoi"
    #       "image/x-tga"
    #       "image/x-xbitmap"
    #       "image/x-xpixmap"
    #     ];
    #     videoAssociations = associateApp "mpv.desktop" [
    #       "application/x-matroska"
    #       "video/3gp"
    #       "video/3gpp"
    #       "video/3gpp2"
    #       "video/avi"
    #       "video/divx"
    #       "video/dv"
    #       "video/fli"
    #       "video/flv"
    #       "video/mp2t"
    #       "video/mp4"
    #       "video/mp4v-es"
    #       "video/mpeg"
    #       "video/msvideo"
    #       "video/ogg"
    #       "video/quicktime"
    #       "video/vnd.divx"
    #       "video/vnd.mpegurl"
    #       "video/vnd.rn-realvideo"
    #       "video/webm"
    #       "video/x-avi"
    #       "video/x-flv"
    #       "video/x-m4v"
    #       "video/x-matroska"
    #       "video/x-mpeg2"
    #       "video/x-ms-asf"
    #       "video/x-msvideo"
    #       "video/x-ms-wmv"
    #       "video/x-ms-wmx"
    #       "video/x-ogm"
    #       "video/x-ogm+ogg"
    #       "video/x-theora"
    #       "video/x-theora+ogg"
    #     ];
    #     archiveAssociations = associateApp "org.kde.ark.desktop" [
    #       "application/gzip"
    #       "application/vnd.ms-cab-compressed"
    #       "application/vnd.rar"
    #       "application/x-7z-compressed"
    #       "application/x-archive"
    #       "application/x-bcpio"
    #       "application/x-bzip"
    #       "application/x-bzip-compressed-tar"
    #       "application/x-cd-image"
    #       "application/x-compress"
    #       "application/x-compressed-tar"
    #       "application/x-cpio"
    #       "application/x-cpio-compressed"
    #       "application/x-iso9660-appimage"
    #       "application/x-lha"
    #       "application/x-lrzip-compressed-tar"
    #       "application/x-lz4-compressed-tar"
    #       "application/x-lzip-compressed-tar"
    #       "application/x-lzma"
    #       "application/x-lzma-compressed-tar"
    #       "application/x-rar"
    #       "application/x-source-rpm"
    #       "application/x-sv4cpio"
    #       "application/x-sv4crc"
    #       "application/x-tar"
    #       "application/x-tarz"
    #       "application/x-tzo"
    #       "application/x-xar"
    #       "application/x-xz"
    #       "application/x-xz-compressed-tar"
    #       "application/x-zstd-compressed-tar"
    #       "application/zip"
    #       "application/zstd"
    #     ];
    #     miscAssociations = { };
    #   in
    #   {
    #     enable = true;
    #     defaultApplications =
    #       browserAssociations
    #       // vscodeAssociations
    #       // readerAssociations
    #       // imageAssociations
    #       // videoAssociations
    #       // archiveAssociations
    #       // miscAssociations;
    #     associations.added =
    #       browserAssociations
    #       // vscodeAssociations
    #       // readerAssociations
    #       // imageAssociations
    #       // videoAssociations
    #       // archiveAssociations
    #       // miscAssociations;
    #   };

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
