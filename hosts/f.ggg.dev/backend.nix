{
  lib,
  config,
  pkgs,
  ...
}: let
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:13f8f07f177e539057bf24ab3a30d5e931dc3f6895e7e73936074c29a3bcaff8";
    sha256 = "1lbkhbwg1j9yz7d270wil9zcw90jmzz0gv9zpl34np0jncgqi7an";
    finalImageName = "docker.lan/mywebsite/backend";
    finalImageTag = "latest";
  }; # /nix/store/hf21fbwi4ihm9g266rvjj8pk017jb4yb-docker-image-docker.lan-mywebsite-backend-latest.tar
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
