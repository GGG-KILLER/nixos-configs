{
  system,
  lib,
  pkgs,
  self,
  ...
}:
let
  vivaldi-wayland = self.packages.${system}.vivaldi-wayland;
in
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
      "7z" = mkBin {
        pkg = pkgs.p7zip;
        bin = "7z";
        profile = "7z.profile";
      };
      "7za" = mkBin {
        pkg = pkgs.p7zip;
        bin = "7za";
        profile = "7za.profile";
      };
      "7zr" = mkBin {
        pkg = pkgs.p7zip;
        bin = "7zr";
        profile = "7zr.profile";
      };
      ark = mkBin {
        pkg = pkgs.kdePackages.ark;
        bin = "ark";
        profile = "ark.profile";
        desktop = "org.kde.ark.desktop";
      };
      aria2c = mkBin {
        pkg = pkgs.aria2;
        bin = "aria2c";
        profile = "aria2c.profile";
      };
      b2sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "b2sum";
        profile = "b2sum.profile";
      };
      bunzip2 = mkBin {
        pkg = pkgs.bzip2;
        bin = "bunzip2";
        profile = "bunzip2.profile";
      };
      bzcat = mkBin {
        pkg = pkgs.bzip2;
        bin = "bzcat";
        profile = "bzcat.profile";
      };
      bzip2 = mkBin {
        pkg = pkgs.bzip2;
        bin = "bzip2";
        profile = "bzip2.profile";
      };
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
      cpio = mkBin {
        pkg = pkgs.cpio;
        profile = "cpio.profile";
      };
      curl = mkBin {
        pkg = pkgs.curl;
        profile = "curl.profile";
      };
      dig = mkBin {
        pkg = pkgs.dig.dnsutils;
        bin = "dig";
        profile = "dig.profile";
      };
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
      ffmpeg = mkBin {
        pkg = pkgs.ffmpeg;
        bin = "ffmpeg";
        profile = "ffmpeg.profile";
      };
      ffplay = mkBin {
        pkg = pkgs.ffmpeg;
        bin = "ffplay";
        profile = "ffplay.profile";
      };
      ffprobe = mkBin {
        pkg = pkgs.ffmpeg;
        bin = "ffprobe";
        profile = "ffprobe.profile";
      };
      file = mkBin {
        pkg = pkgs.file;
        bin = "file";
        profile = "file.profile";
      };
      git = mkBin {
        pkg = pkgs.git;
        bin = "git";
        profile = "git.profile";
      };
      gunzip = mkBin {
        pkg = pkgs.gzip;
        bin = "gunzip";
        profile = "gunzip.profile";
      };
      gwenview = mkBin {
        pkg = pkgs.kdePackages.gwenview;
        bin = "gwenview";
        profile = "gwenview.profile";
        desktop = "org.kde.gwenview.desktop";
      };
      gzexe = mkBin {
        pkg = pkgs.gzip;
        bin = "gzexe";
        profile = "gzexe.profile";
      };
      gzip = mkBin {
        pkg = pkgs.gzip;
        bin = "gzip";
        profile = "gzip.profile";
      };
      host = mkBin {
        pkg = pkgs.bind.host;
        bin = "host";
        profile = "host.profile";
      };
      "kate" = mkBin {
        pkg = pkgs.kdePackages.kate;
        bin = "kate";
        profile = "kate.profile";
        desktop = "org.kde.kate.desktop";
      };
      less = mkBin {
        pkg = pkgs.less;
        bin = "less";
        profile = "less.profile";
      };
      lzcat = mkBin {
        pkg = pkgs.xz;
        bin = "lzcat";
        profile = "lzcat.profile";
      };
      lzcmp = mkBin {
        pkg = pkgs.xz;
        bin = "lzcmp";
        profile = "lzcmp.profile";
      };
      lzdiff = mkBin {
        pkg = pkgs.xz;
        bin = "lzdiff";
        profile = "lzdiff.profile";
      };
      lzegrep = mkBin {
        pkg = pkgs.xz;
        bin = "lzegrep";
        profile = "lzegrep.profile";
      };
      lzfgrep = mkBin {
        pkg = pkgs.xz;
        bin = "lzfgrep";
        profile = "lzfgrep.profile";
      };
      lzgrep = mkBin {
        pkg = pkgs.xz;
        bin = "lzgrep";
        profile = "lzgrep.profile";
      };
      lzless = mkBin {
        pkg = pkgs.xz;
        bin = "lzless";
        profile = "lzless.profile";
      };
      lzma = mkBin {
        pkg = pkgs.xz;
        bin = "lzma";
        profile = "lzma.profile";
      };
      lzmadec = mkBin {
        pkg = pkgs.xz;
        bin = "lzmadec";
        profile = "lzmadec.profile";
      };
      lzmainfo = mkBin {
        pkg = pkgs.xz;
        bin = "lzmainfo";
        profile = "lzmainfo.profile";
      };
      lzmore = mkBin {
        pkg = pkgs.xz;
        bin = "lzmore";
        profile = "lzmore.profile";
      };
      man = mkBin {
        pkg = pkgs.man;
        bin = "man";
        profile = "man.profile";
      };
      md5sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "md5sum";
        profile = "md5sum.profile";
      };
      mpv = mkBin {
        pkg = pkgs.mpv;
        desktop = "mpv.desktop";
        profile = "mpv.profile";
      };
      nano = mkBin {
        pkg = pkgs.nano;
        bin = "nano";
        profile = "nano.profile";
      };
      node = mkBin {
        pkg = pkgs.nodejs_latest;
        bin = "node";
        profile = "node.profile";
      };
      npm = mkBin {
        pkg = pkgs.nodejs_latest;
        bin = "npm";
        profile = "npm.profile";
      };
      npx = mkBin {
        pkg = pkgs.nodejs_latest;
        bin = "npx";
        profile = "npx.profile";
      };
      nslookup = mkBin {
        pkg = pkgs.dig.dnsutils;
        bin = "nslookup";
        profile = "nslookup.profile";
      };
      # TODO: add OBS
      okular = mkBin {
        pkg = pkgs.kdePackages.okular;
        bin = "okular";
        profile = "okular.profile";
        desktop = "org.kde.okular.desktop";
      };
      ping = mkBin {
        pkg = pkgs.iputils;
        bin = "ping";
        profile = "ping.profile";
      };
      pzstd = mkBin {
        pkg = pkgs.zstd;
        bin = "pzstd";
        profile = "pzstd.profile";
      };
      rnano = mkBin {
        pkg = pkgs.nano;
        bin = "rnano";
        profile = "rnano.profile";
      };
      scp = mkBin {
        pkg = pkgs.openssh;
        bin = "scp";
        profile = "scp.profile";
      };
      sftp = mkBin {
        pkg = pkgs.openssh;
        bin = "sftp";
        profile = "sftp.profile";
      };
      sha1sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sha1sum";
        profile = "sha1sum.profile";
      };
      sha224sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sha224sum";
        profile = "sha224sum.profile";
      };
      sha256sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sha256sum";
        profile = "sha256sum.profile";
      };
      sha384sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sha384sum";
        profile = "sha384sum.profile";
      };
      sha512sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sha512sum";
        profile = "sha512sum.profile";
      };
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
      ssh-agent = mkBin {
        pkg = pkgs.openssh;
        bin = "ssh-agent";
        profile = "ssh-agent.profile";
      };
      ssh = mkBin {
        pkg = pkgs.openssh;
        bin = "ssh";
        profile = "ssh.profile";
      };
      sum = mkBin {
        pkg = pkgs.coreutils-full;
        bin = "sum";
        profile = "sum.profile";
      };
      tar = mkBin {
        pkg = pkgs.gnutar;
        bin = "tar";
        profile = "tar.profile";
      };
      uncompress = mkBin {
        pkg = pkgs.gzip;
        bin = "uncompress";
        profile = "uncompress.profile";
      };
      unlzma = mkBin {
        pkg = pkgs.xz;
        bin = "unlzma";
        profile = "unlzma.profile";
      };
      unxz = mkBin {
        pkg = pkgs.xz;
        bin = "unxz";
        profile = "unxz.profile";
      };
      unzip = mkBin {
        pkg = pkgs.unzip;
        bin = "unzip";
        profile = "unzip.profile";
      };
      unzstd = mkBin {
        pkg = pkgs.zstd;
        bin = "unzstd";
        profile = "unzstd.profile";
      };
      vivaldi = mkBin {
        pkg = vivaldi-wayland;
        bin = "vivaldi";
        desktop = "vivaldi-stable.desktop";
        profile = "vivaldi.profile";
      };
      wget = mkBin {
        pkg = pkgs.wget;
        bin = "wget";
        profile = "wget.profile";
      };
      whois = mkBin {
        pkg = pkgs.whois;
        bin = "whois";
        profile = "whois.profile";
      };
      Xephyr = mkBin {
        pkg = pkgs.xorg.xorgserver;
        bin = "Xephyr";
        profile = "Xephyr.profile";
      };
      Xvfb = mkBin {
        pkg = pkgs.xorg.xorgserver;
        bin = "Xvfb";
        profile = "Xvfb.profile";
      };
      xz = mkBin {
        pkg = pkgs.xz;
        bin = "xz";
        profile = "xz.profile";
      };
      xzcat = mkBin {
        pkg = pkgs.xz;
        bin = "xzcat";
        profile = "xzcat.profile";
      };
      xzcmp = mkBin {
        pkg = pkgs.xz;
        bin = "xzcmp";
        profile = "xzcmp.profile";
      };
      xzdec = mkBin {
        pkg = pkgs.xz;
        bin = "xzdec";
        profile = "xzdec.profile";
      };
      xzdiff = mkBin {
        pkg = pkgs.xz;
        bin = "xzdiff";
        profile = "xzdiff.profile";
      };
      xzegrep = mkBin {
        pkg = pkgs.xz;
        bin = "xzegrep";
        profile = "xzegrep.profile";
      };
      xzfgrep = mkBin {
        pkg = pkgs.xz;
        bin = "xzfgrep";
        profile = "xzfgrep.profile";
      };
      xzgrep = mkBin {
        pkg = pkgs.xz;
        bin = "xzgrep";
        profile = "xzgrep.profile";
      };
      xzless = mkBin {
        pkg = pkgs.xz;
        bin = "xzless";
        profile = "xzless.profile";
      };
      xzmore = mkBin {
        pkg = pkgs.xz;
        bin = "xzmore";
        profile = "xzmore.profile";
      };
      yarn = mkBin {
        pkg = pkgs.corepack_latest;
        bin = "yarn";
        profile = "yarn.profile";
      };
      yt-dlp = mkBin {
        pkg = pkgs.yt-dlp;
        bin = "yt-dlp";
        profile = "yt-dlp.profile";
      };
      zcat = mkBin {
        pkg = pkgs.gzip;
        bin = "zcat";
        profile = "zcat.profile";
      };
      zcmp = mkBin {
        pkg = pkgs.gzip;
        bin = "zcmp";
        profile = "zcmp.profile";
      };
      zdiff = mkBin {
        pkg = pkgs.gzip;
        bin = "zdiff";
        profile = "zdiff.profile";
      };
      zegrep = mkBin {
        pkg = pkgs.gzip;
        bin = "zegrep";
        profile = "zegrep.profile";
      };
      zfgrep = mkBin {
        pkg = pkgs.gzip;
        bin = "zfgrep";
        profile = "zfgrep.profile";
      };
      zforce = mkBin {
        pkg = pkgs.gzip;
        bin = "zforce";
        profile = "zforce.profile";
      };
      zgrep = mkBin {
        pkg = pkgs.gzip;
        bin = "zgrep";
        profile = "zgrep.profile";
      };
      zless = mkBin {
        pkg = pkgs.gzip;
        bin = "zless";
        profile = "zless.profile";
      };
      zmore = mkBin {
        pkg = pkgs.gzip;
        bin = "zmore";
        profile = "zmore.profile";
      };
      znew = mkBin {
        pkg = pkgs.gzip;
        bin = "znew";
        profile = "znew.profile";
      };
      zstd = mkBin {
        pkg = pkgs.zstd;
        bin = "zstd";
        profile = "zstd.profile";
      };
      zstdcat = mkBin {
        pkg = pkgs.zstd;
        bin = "zstdcat";
        profile = "zstdcat.profile";
      };
      zstdgrep = mkBin {
        pkg = pkgs.zstd;
        bin = "zstdgrep";
        profile = "zstdgrep.profile";
      };
      zstdless = mkBin {
        pkg = pkgs.zstd;
        bin = "zstdless";
        profile = "zstdless.profile";
      };
      zstdmt = mkBin {
        pkg = pkgs.zstd;
        bin = "zstdmt";
        profile = "zstdmt.profile";
      };
    };
}
