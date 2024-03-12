{pkgs, ...}: let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/mywebsite/backend --image-tag latest --quiet
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:f2a79a6eb54705264268d91167e98d93a13404af5f93647c301d14e17a991e30";
    sha256 = "08z693z1zb1l8175mm09j1ijd0ynwp6syhcivqkffxm54g3ygnwp";
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
