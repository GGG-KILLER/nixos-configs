{ config, pkgs, ... }:
let
  statping-ng = pkgs.dockerTools.buildImage {
    name = "statping-nix-wrapper";
    tag = "0.91";

    # nix run nixpkgs#nix-prefetch-docker -- --image-name adamboutcher/statping-ng --image-tag latest --quiet
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "adamboutcher/statping-ng";
      imageDigest = "sha256:e32bd2e50ca023f37b0650e1942d51cb9269a2caab11042bc0cc53fac0474a2b";
      sha256 = "16q341rvqc0a7cq3q1qbbk4h1pll76hny7m7xdhfj43raz1d2ppk";
      finalImageName = "adamboutcher/statping-ng";
      finalImageTag = "latest";
    };

    copyToRoot =
      let
        root-crt-dir = pkgs.runCommand "root.crt-as-dir" { } ''
          mkdir -p $out/usr/local/share/ca-certificates/
          cp ${config.my.secrets.pki.root-crt-path} $out/usr/local/share/ca-certificates/lan-root-ca.crt
        '';
      in
      [ root-crt-dir ];

    runAsRoot = ''
      #! ${pkgs.runtimeShell}
      cat /usr/local/share/ca-certificates/lan-root-ca.crt >> /etc/ssl/certs/ca-certificates.crt
    '';

    config = {
      ExposedPorts = {
        "8080/tcp" = { };
      };
      Cmd = [
        "/bin/sh"
        "-c"
        "statping --port $PORT"
      ];
      Volumes = {
        "/app" = { };
      };
      WorkingDir = "/app";
      Healthcheck = {
        Test = [
          "CMD-SHELL"
          "curl -s \"http://127.0.0.1:$PORT/health\" | jq -r -e \".online==true\""
        ];
        Interval = 60000000000;
        Timeout = 10000000000;
        Retries = 3;
      };
      ArgsEscaped = true;
    };
  };
in
{
  virtualisation.oci-containers.containers.statping-ng = {
    image = "${statping-ng.imageName}:${statping-ng.imageTag}";
    imageFile = statping-ng;

    ports = [ "${toString config.shiro.ports.statping-ng}:8080" ];
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
    environmentFiles = [ config.age.secrets."statping.env".path ];
    volumes = [ "/zfs-main-pool/data/statping:/app" ];
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
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };
  };
}
