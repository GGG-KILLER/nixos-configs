{ pkgs, ... }:
let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/mywebsite/backend --image-tag latest --quiet
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:d50dad2e944b86330d15743e5d371f97635878302fd3a6689be5b845bfb55eec";
    sha256 = "0533czk7rjjnbal40n6z6mmpy0i43xwz3v2ns36inrm1vx3ppwkg";
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
