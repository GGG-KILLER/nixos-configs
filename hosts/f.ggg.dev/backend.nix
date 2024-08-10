{ pkgs, ... }:
let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/mywebsite/backend --image-tag latest --quiet
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:b80ea6da752e35b0ddecae8ead5432f1f8c12be28022f8797f1bbe2ea0bf752b";
    sha256 = "1as71yhp2g18jz6agqsp5dsgx10pjj9p9njszgizr2d04jij2xv3";
    finalImageName = "docker.lan/mywebsite/backend";
    finalImageTag = "latest";
  };
in
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.containers.mywebsite-backend = {
    image = "${backendImage.imageName}:${backendImage.imageTag}";
    imageFile = backendImage;

    ports = [
      "80:8080/tcp"
      "443:8083/tcp"
      "443:8083/udp"
    ];

    extraOptions = [
      "-v=/home/ggg/MyWebsiteData:/data"
      "--dns=1.1.1.1"
      "--dns=8.8.8.8"
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };
}
