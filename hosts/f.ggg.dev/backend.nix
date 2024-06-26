{pkgs, ...}: let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/mywebsite/backend --image-tag latest --quiet
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:15f62841b9b33ec20c80bfba54fd76abbcd8baf6665713612926df41083ee92d";
    sha256 = "04r47j78r9c9xv9rc11k0gs2k05yxl0825db5wbqipvdilsj6cy3";
    finalImageName = "docker.lan/mywebsite/backend";
    finalImageTag = "latest";
  };
in {
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.containers.mywebsite-backend = {
    image = "${backendImage.imageName}:${backendImage.imageTag}";
    imageFile = backendImage;

    ports = ["80:8080/tcp" "443:8083/tcp" "443:8083/udp"];

    extraOptions = [
      "-v=/home/ggg/MyWebsiteData:/data"
      "--dns=1.1.1.1"
      "--dns=8.8.8.8"
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };
}
