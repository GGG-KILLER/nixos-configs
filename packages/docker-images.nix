{ dockerTools }:
{
  "eclipse-mosquitto:2.0" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:077fe4ff4c49df1e860c98335c77dda08360629e0e2a718147027e4db3eace9d";
    hash = "sha256-pTmZTOU++Fc67uwLu0bxlN0x2LUkUK2fFWcM4DE5qao=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.0";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:73dad4271642c5966db88db7a7585fae7cf10b685d1e48006f31e0294c29fdd7";
    hash = "sha256-i5G77fbR9C5CjYgSCDfH5X+96Fi9FNNg1ryh+2MSqiY=";
    finalImageName = "redis";
    finalImageTag = "latest";
  };
  "evazion/iqdb:latest" = dockerTools.pullImage {
    imageName = "evazion/iqdb";
    imageDigest = "sha256:3441fbe7b7e15da95624611c49821e457615bb5428cd9e08cb391a547c979622";
    hash = "sha256-eaLNlNBR3GEXI950QtcGzEj8hca+G/6XeUFwNLRIix8=";
    finalImageName = "evazion/iqdb";
    finalImageTag = "latest";
  };
  "klausmeyer/docker-registry-browser:latest" = dockerTools.pullImage {
    imageName = "klausmeyer/docker-registry-browser";
    imageDigest = "sha256:04c57880532f0fa55e3bb99d02fbb01afecd7ce9641dc8e15c077277fa15670b";
    hash = "sha256-B1WKcLLyMy8raq7oW01uqzHmQ8d7q7moLHLrQV9fSBA=";
    finalImageName = "klausmeyer/docker-registry-browser";
    finalImageTag = "latest";
  };
  "plaintextpackets/netprobe:latest" = dockerTools.pullImage {
    imageName = "plaintextpackets/netprobe";
    imageDigest = "sha256:139ed2dcb004324ef7a8d24bbfdd252bfba0012aa2b70575ca92cc38cd2afd56";
    hash = "sha256-3aY0INi+kpFvvp6btIE+E5prH2GofN7/mxcj9udYocI=";
    finalImageName = "plaintextpackets/netprobe";
    finalImageTag = "latest";
  };
  "zer0tonin/mikochi:latest" = dockerTools.pullImage {
    imageName = "zer0tonin/mikochi";
    imageDigest = "sha256:9681b31dd2e827400c5ef91560fa89f52726dcee62a36c8cb1695180b3334b11";
    hash = "sha256-kuBCiUYe7olnhjPbxqUFpWq7hoZ/2VpACtzRTzUYCts=";
    finalImageName = "zer0tonin/mikochi";
    finalImageTag = "latest";
  };
  "docker.lan/downloader/backend:latest" = dockerTools.pullImage {
    imageName = "docker.lan/downloader/backend";
    imageDigest = "sha256:98d75c28e2bbfd4a6be2114194cc9fd645a470cb0cea1dfe482e8ab99ab9c2f3";
    hash = "sha256-j8reRST4+8woi2SdOnoUoisQPHtLrxxI7DAqxhtUy6Q=";
    finalImageName = "docker.lan/downloader/backend";
    finalImageTag = "latest";
  };
  "docker.lan/downloader/frontend:latest" = dockerTools.pullImage {
    imageName = "docker.lan/downloader/frontend";
    imageDigest = "sha256:b7cd81811271f91089cc161b10e9dd26fade9c99d893c8cc9b464424b2adf0d4";
    hash = "sha256-64ihDXxrLowJrjbEYa1+aX46TDjrJmxZf8LnrKxRp0U=";
    finalImageName = "docker.lan/downloader/frontend";
    finalImageTag = "latest";
  };
  "ghcr.io/danbooru/autotagger:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/danbooru/autotagger";
    imageDigest = "sha256:9f0fa42bf0036b209c52b4ee5d9b79bdd5f0988a7d8143c71318506921a0fe8a";
    hash = "sha256-zROn3e+Sj8xUJ7k4g0FBXLodi1eclyNM3XL9tHyL6AU=";
    finalImageName = "ghcr.io/danbooru/autotagger";
    finalImageTag = "latest";
  };
  "ghcr.io/danbooru/danbooru:master" = dockerTools.pullImage {
    imageName = "ghcr.io/danbooru/danbooru";
    imageDigest = "sha256:6d8de4b1af8290486520f3b000d7a28838a1baa598e4a6bb047e95d27fb02cc8";
    hash = "sha256-Ayh4WZc+sMRtVrx5goiwrgyZBKoct6YNDj6mjS6apgE=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
}
