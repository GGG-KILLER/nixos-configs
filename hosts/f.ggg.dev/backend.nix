{
  lib,
  config,
  pkgs,
  ...
}: let
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:cd5c1fab20ad8956c0d8059f89b0932d41e98d82203fb0751f1741d125ec4718";
    sha256 = "1q3hfhvm1g1clx94phzs1p69khrr21j51vzj64jlrav5dang9508";
    finalImageName = "docker.lan/mywebsite/backend";
    finalImageTag = "latest";
  };
in {
  virtualisation.oci-containers.containers.mywebsite-backend = {
    image = "${backendImage.imageName}:${backendImage.imageTag}";
    imageFile = backendImage;

    ports = ["80:8080/tcp" "443:8083/tcp" "443:8083/udp"];

    extraOptions = [
      "--dns=1.1.1.1"
      "--dns=8.8.8.8"
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };
}
