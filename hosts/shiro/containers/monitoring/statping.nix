{
  config,
  pkgs,
  ...
}: let
  statping-ng = pkgs.dockerTools.buildImage {
    name = "statping-nix-wrapper";
    tag = "0.91";

    # nix run nixpkgs#nix-prefetch-docker -- --image-name adamboutcher/statping-ng --image-tag latest --quiet
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/statping-ng/statping-ng";
      imageDigest = "sha256:50ba35d79ebac36ead6bb1473f59ee5718b16dc80328d8052edb139f57f823e9";
      sha256 = "0fff2bcajqhxf7lgfm2zdf9rrn6pvy7g5mxf96miaiinp28f29cj";
      finalImageName = "ghcr.io/statping-ng/statping-ng";
      finalImageTag = "0.91";
    };

    copyToRoot = let
      root-crt-dir = pkgs.runCommand "root.crt-as-dir" {} ''
        mkdir -p $out/usr/local/share/ca-certificates/
        cp ${config.my.secrets.pki.root-crt-path} $out/usr/local/share/ca-certificates/lan-root-ca.crt
      '';
    in [root-crt-dir];

    runAsRoot = ''
      #! ${pkgs.runtimeShell}
      cat /usr/local/share/ca-certificates/lan-root-ca.crt >> /etc/ssl/certs/ca-certificates.crt
    '';

    config = {
      ExposedPorts = {
        "8080/tcp" = {};
      };
      Cmd = ["/bin/sh" "-c" "statping --port $PORT"];
      Volumes = {
        "/app" = {};
      };
      WorkingDir = "/app";
      Healthcheck = {
        Test = ["CMD-SHELL" "curl -s \"http://localhost:$PORT/health\" | jq -r -e \".online==true\""];
        Interval = 60000000000;
        Timeout = 10000000000;
        Retries = 3;
      };
      ArgsEscaped = true;
    };
  };
in {
  virtualisation.oci-containers.containers.statping-ng = {
    image = "${statping-ng.imageName}:${statping-ng.imageTag}";
    imageFile = statping-ng;

    ports = ["${toString config.shiro.ports.statping-ng}:8080"];
    environment = {
      DOMAIN = "status.shiro.lan";
      SAMPLE_DATA = "false";

      DB_CONN = "postgres";
      DB_HOST = "pgprd.shiro.lan";
      DB_PORT = "5432";
      DB_USER = "statping";
      DB_DATABASE = "statping-ng";
      POSTGRES_SSLMODE = "disable";
    };
    environmentFiles = [
      config.age.secrets."statping.env".path
    ];
    volumes = [
      "/zfs-main-pool/data/statping:/app"
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  # This is only for the nginx config of the downloader.
  modules.services.nginx.virtualHosts = {
    "status.shiro.lan" = {
      ssl = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.statping-ng}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };
  };
}
