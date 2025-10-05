{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-downloaders) {
    systemd.services."${config.virtualisation.oci-containers.backend}-downloader-network" =
      let
        backend = config.virtualisation.oci-containers.backend;
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
        ];
        before = [
          "${backend}-downloader-backend.service"
          "${backend}-downloader-frontend.service"
        ];
        requiredBy = [
          "${backend}-downloader-backend.service"
          "${backend}-downloader-frontend.service"
        ];

        serviceConfig =
          let
            backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
          in
          {
            Type = "simple";
            RemainAfterExit = "yes";

            ExecStartPre = "-${backendBin} network rm downloader";
            ExecStart = "${backendBin} network create downloader";
            ExecStop = "${backendBin} network rm downloader";
          };
      };

    virtualisation.oci-containers.containers.downloader-frontend = rec {
      # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/downloader/frontend --image-tag latest --arch amd64 --os linux --quiet
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "docker.lan/downloader/frontend";
        imageDigest = "sha256:b7cd81811271f91089cc161b10e9dd26fade9c99d893c8cc9b464424b2adf0d4";
        hash = "sha256-64ihDXxrLowJrjbEYa1+aX46TDjrJmxZf8LnrKxRp0U=";
        finalImageName = "docker.lan/downloader/frontend";
        finalImageTag = "latest";
      };
      image = imageFile.destNameTag;
      ports = [ "${toString config.shiro.ports.downloader}:8080" ];
      dependsOn = [ "downloader-backend" ];
      extraOptions = [
        "--cap-drop=ALL"
        "--dns=${config.home.addrs.router}"
        "--ipc=none"
        "--network=downloader"
        "--network-alias=frontend"
      ];
    };

    virtualisation.oci-containers.containers.downloader-backend = rec {
      # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/downloader/backend --image-tag latest --arch amd64 --os linux --quiet
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "docker.lan/downloader/backend";
        imageDigest = "sha256:98d75c28e2bbfd4a6be2114194cc9fd645a470cb0cea1dfe482e8ab99ab9c2f3";
        hash = "sha256-j8reRST4+8woi2SdOnoUoisQPHtLrxxI7DAqxhtUy6Q=";
        finalImageName = "docker.lan/downloader/backend";
        finalImageTag = "latest";
      };
      image = imageFile.destNameTag;
      user = "downloader:data-members";
      volumes = [
        "pgo:/app/PGO"
        "/storage/animu:/mnt/animu"
        "/storage/h:/mnt/h"
        "/storage/etc:/mnt/etc"
      ];
      environment = {
        ConnectionStrings__Main = config.my.secrets.downloader.connection-string;
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--dns=${config.home.addrs.router}"
        "--ipc=none"
        "--network=downloader"
        "--network-alias=backend"
      ];
    };

    # This is only for the nginx config of the downloader.
    modules.services.nginx.virtualHosts."downloader.lan" = {
      ssl = true;
      locations."/" = {
        recommendedProxySettings = true;
        # sso = true;
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.downloader}";
      };
    };
  };
}
