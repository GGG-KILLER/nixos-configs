{pkgs, ...}: let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name docker.lan/mywebsite/backend --image-tag latest --quiet
  backendImage = pkgs.dockerTools.pullImage {
    imageName = "docker.lan/mywebsite/backend";
    imageDigest = "sha256:f0e1a44865c49c701781504362d61e0db9b8c8f65a46f10c7423913f01ea37a7";
    sha256 = "18v46nfgadkmc02nkp3aiwwvldq8di3rvz9jxypfjhxk15b4m4ha";
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
