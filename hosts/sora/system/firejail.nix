{
  system,
  lib,
  pkgs,
  self,
  ...
}:
{
  # Enable Firejail
  programs.firejail.enable = true;

  programs.firejail.wrappedBinaries =
    let
      mkBin =
        {
          pkg,
          profile,
          bin ? null,
          desktop ? null,
        }:
        {
          executable = if bin != null then lib.getExe' pkg bin else lib.getExe pkg;
          profile = "${pkgs.firejail}/etc/firejail/${profile}";
        }
        // lib.optionalAttrs (desktop != null) {
          desktop = "${pkg}/share/applications/${desktop}";
        };
    in
    {
      # "7z" = mkBin {
      #   pkg = pkgs.p7zip;
      #   bin = "7z";
      #   profile = "7z.profile";
      # };
      # "7za" = mkBin {
      #   pkg = pkgs.p7zip;
      #   bin = "7za";
      #   profile = "7za.profile";
      # };
      # "7zr" = mkBin {
      #   pkg = pkgs.p7zip;
      #   bin = "7zr";
      #   profile = "7zr.profile";
      # };
      ark = mkBin {
        pkg = pkgs.kdePackages.ark;
        bin = "ark";
        profile = "ark.profile";
        desktop = "org.kde.ark.desktop";
      };
      # aria2c = mkBin {
      #   pkg = pkgs.aria2;
      #   bin = "aria2c";
      #   profile = "aria2c.profile";
      # };
      # b2sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "b2sum";
      #   profile = "b2sum.profile";
      # };
      chromium-browser = mkBin {
        pkg = pkgs.chromium;
        bin = "chromium-browser";
        profile = "chromium-browser.profile";
        desktop = "chromium-browser.desktop";
      };
      chromium = mkBin {
        pkg = pkgs.chromium;
        bin = "chromium";
        profile = "chromium.profile";
        desktop = "chromium-browser.desktop";
      };
      # TODO: vscode
      DiscordCanary = mkBin {
        pkg = pkgs.discord-canary;
        bin = "DiscordCanary";
        profile = "DiscordCanary.profile";
        desktop = "discord-canary.desktop";
      };
      dolphin = mkBin {
        pkg = pkgs.kdePackages.dolphin;
        bin = "dolphin";
        profile = "dolphin.profile";
        desktop = "org.kde.dolphin.desktop";
      };
      # ffmpeg = mkBin {
      #   pkg = pkgs.ffmpeg;
      #   bin = "ffmpeg";
      #   profile = "ffmpeg.profile";
      # };
      # ffplay = mkBin {
      #   pkg = pkgs.ffmpeg;
      #   bin = "ffplay";
      #   profile = "ffplay.profile";
      # };
      # ffprobe = mkBin {
      #   pkg = pkgs.ffmpeg;
      #   bin = "ffprobe";
      #   profile = "ffprobe.profile";
      # };
      # file = mkBin {
      #   pkg = pkgs.file;
      #   bin = "file";
      #   profile = "file.profile";
      # };
      # git = mkBin {
      #   pkg = pkgs.git;
      #   bin = "git";
      #   profile = "git.profile";
      # };
      gwenview = mkBin {
        pkg = pkgs.kdePackages.gwenview;
        bin = "gwenview";
        profile = "gwenview.profile";
        desktop = "org.kde.gwenview.desktop";
      };
      # host = mkBin {
      #   pkg = pkgs.bind.host;
      #   bin = "host";
      #   profile = "host.profile";
      # };
      kate = mkBin {
        pkg = pkgs.kdePackages.kate;
        bin = "kate";
        profile = "kate.profile";
        desktop = "org.kde.kate.desktop";
      };
      # less = mkBin {
      #   pkg = pkgs.less;
      #   bin = "less";
      #   profile = "less.profile";
      # };
      # man = mkBin {
      #   pkg = pkgs.man;
      #   bin = "man";
      #   profile = "man.profile";
      # };
      # md5sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "md5sum";
      #   profile = "md5sum.profile";
      # };
      mpv = mkBin {
        pkg = pkgs.mpv;
        desktop = "mpv.desktop";
        profile = "mpv.profile";
      };
      # nano = mkBin {
      #   pkg = pkgs.nano;
      #   bin = "nano";
      #   profile = "nano.profile";
      # };
      # node = mkBin {
      #   pkg = pkgs.nodejs_latest;
      #   bin = "node";
      #   profile = "node.profile";
      # };
      # npm = mkBin {
      #   pkg = pkgs.nodejs_latest;
      #   bin = "npm";
      #   profile = "npm.profile";
      # };
      # npx = mkBin {
      #   pkg = pkgs.nodejs_latest;
      #   bin = "npx";
      #   profile = "npx.profile";
      # };
      # TODO: add OBS
      okular = mkBin {
        pkg = pkgs.kdePackages.okular;
        bin = "okular";
        profile = "okular.profile";
        desktop = "org.kde.okular.desktop";
      };
      # ping = mkBin {
      #   pkg = pkgs.iputils;
      #   bin = "ping";
      #   profile = "ping.profile";
      # };
      # rnano = mkBin {
      #   pkg = pkgs.nano;
      #   bin = "rnano";
      #   profile = "rnano.profile";
      # };
      # scp = mkBin {
      #   pkg = pkgs.openssh;
      #   bin = "scp";
      #   profile = "scp.profile";
      # };
      # sftp = mkBin {
      #   pkg = pkgs.openssh;
      #   bin = "sftp";
      #   profile = "sftp.profile";
      # };
      # sha1sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sha1sum";
      #   profile = "sha1sum.profile";
      # };
      # sha224sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sha224sum";
      #   profile = "sha224sum.profile";
      # };
      # sha256sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sha256sum";
      #   profile = "sha256sum.profile";
      # };
      # sha384sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sha384sum";
      #   profile = "sha384sum.profile";
      # };
      # sha512sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sha512sum";
      #   profile = "sha512sum.profile";
      # };
      shellcheck = mkBin {
        pkg = pkgs.shellcheck;
        bin = "shellcheck";
        profile = "shellcheck.profile";
      };
      spectacle = mkBin {
        pkg = pkgs.kdePackages.spectacle;
        bin = "spectacle";
        profile = "spectacle.profile";
        desktop = "org.kde.spectacle.desktop";
      };
      # ssh-agent = mkBin {
      #   pkg = pkgs.openssh;
      #   bin = "ssh-agent";
      #   profile = "ssh-agent.profile";
      # };
      # ssh = mkBin {
      #   pkg = pkgs.openssh;
      #   bin = "ssh";
      #   profile = "ssh.profile";
      # };
      # sum = mkBin {
      #   pkg = pkgs.coreutils-full;
      #   bin = "sum";
      #   profile = "sum.profile";
      # };
      vivaldi = mkBin {
        pkg = self.packages.${system}.vivaldi-wayland;
        bin = "vivaldi";
        desktop = "vivaldi-stable.desktop";
        profile = "vivaldi.profile";
      };
      # wget = mkBin {
      #   pkg = pkgs.wget;
      #   bin = "wget";
      #   profile = "wget.profile";
      # };
      # whois = mkBin {
      #   pkg = pkgs.whois;
      #   bin = "whois";
      #   profile = "whois.profile";
      # };
      # yarn = mkBin {
      #   pkg = pkgs.corepack_latest;
      #   bin = "yarn";
      #   profile = "yarn.profile";
      # };
      yt-dlp = mkBin {
        pkg = pkgs.yt-dlp;
        bin = "yt-dlp";
        profile = "yt-dlp.profile";
      };
    };
}
