{
  lib,
  config,
  pkgs,
  ...
}: let
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:642dd8473db3b123eb42fa525996c052fa037058c0f20f865c68c158014fa8b4";
    sha256 = "155i4qyma9s2b0dsc4w2wsvscrpj5zyyzrnw4fjizwny4zqjk66v";
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
