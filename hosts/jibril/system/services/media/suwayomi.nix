{
  self,
  system,
  pkgs,
  config,
  ...
}:
{
  jibril.dynamic-ports = [
    "suwayomi"
    "byparr"
  ];

  virtualisation.oci-containers.containers.byparr = rec {
    imageFile = self.packages.${system}.docker-images."ghcr.io/thephaseless/byparr:latest";
    image = imageFile.destNameTag;
    ports = [ "${toString config.jibril.ports.byparr}:8191" ];
    extraOptions = [
      "--ipc=private"
    ];
  };

  services.suwayomi-server = {
    enable = true;
    package = pkgs.suwayomi-server.overrideAttrs (old: rec {
      version = "2.2.2100";

      src = pkgs.fetchurl {
        url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}.jar";
        hash = "sha256-PIEypDv6m5WbDI/b3PmqAb2AkEf/T7waSq4OtxMx8F4=";
      };
    });

    settings = {
      server.ip = "127.0.0.1";
      server.port = config.jibril.ports.suwayomi;

      # webUI
      server.initialOpenInBrowserEnabled = false;

      # Downloader
      server.downloadAsCbz = true; # configures Suwayomi to automatically compress chapters into CBZ.
      server.autoDownloadNewChapters = true; # controls if Suwayomi should automatically download new chapters after a library update.
      server.excludeEntryWithUnreadChapters = false; # controls if Suwayomi will download new chapters for titles with unread chapters (requires server.autoDownloadNewChapters).
      server.autoDownloadIgnoreReUploads = false; # controls if Suwayomi will re-download re-uploads on update (requires server.autoDownloadNewChapters).

      # Updater
      server.excludeUnreadChapters = false; # controls if Suwayomi should include titles with unread chapters in the library update.
      server.excludeNotStarted = false; # controls if Suwayomi should include titles which weren't started yet in the library update.
      server.excludeCompleted = false; # controls if Suwayomi should include titles which are marked completed in the library update.
      server.globalUpdateInterval = 6; # sets the time in hours for the automatic library internal, 0 to disable it. Range: 6 <= n < ∞
      server.updateMangas = true; # controls if Suwayomi should also update title metadata along with fetching new chapters in the library update.

      # Authentication
      server.authMode = "none";
      server.jwtAudience = "suwayomi.lan";

      # misc
      server.systemTrayEnabled = false; # whether if Suwayomi-Server should show a System Tray Icon, disabling this on headless servers is recommended.
      server.extensionRepos = [
        "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
      ]; # is a list of extension repositories for custom sources. Uses the same format as Mihon; each entry is expected to be a string URL pointing to a JSON file representing the repository.
      server.maxSourcesInParallel = 20; # sets how many sources can do requests (updates, downloads) in parallel. Updates/downloads are grouped by source and all mangas of a source are updated/downloaded synchronously. Range: 1 <= n <= 20.

      # Cloudflare bypass
      server.flareSolverrEnabled = true; # controls if Suwayomi attempts to connect to FlareSolverr if a CloudFlare challenge is detected.
      server.flareSolverrUrl = "http://127.0.0.1:${toString config.jibril.ports.byparr}";
      server.flareSolverrAsResponseFallback = true; # allows Suwayomi to use the contents of the request that FlareSolverr received in case Suwayomi sees a CloudFlare challenge but FlareSolverr does not (which prevents it from solving the challenge).

      # OPDS
      server.opdsUseBinaryFileSizes = true; # controls if Suwayomi should display file sizes in binary units (KiB, MiB, GiB) or decimal (KB, MB, GB) in OPDS listings.
    };
  };

  services.caddy.virtualHosts = {
    "suwayomi.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.suwayomi}
    '';
    "byparr.suwayomi.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.byparr}
    '';
  };
}
