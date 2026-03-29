{ dockerTools }:
{
  "eclipse-mosquitto:2.0" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:6852da90a65dfff7aa3a1c8b249e92bb83c17ea8bbcce56bedff8707332a1a29";
    hash = "sha256-LODqtehTDyaDQSFTg8Y1SpbZP/Fd/N8AtJRRW9u4t4g=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.0";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:009cc37796fbdbe1b631b4cc0582bed167e5e403ed8bcd06f77eb6cb5aeb6f93";
    hash = "sha256-xOmdelBmaRjdOGVwl/zx/6X/9HfqsZzzfkJpleyADyE=";
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
  "jlesage/jdownloader-2:latest" = dockerTools.pullImage {
    imageName = "jlesage/jdownloader-2";
    imageDigest = "sha256:3d6cb102bd9bacff12ab1ca5136a38cb8f93d6595a7ccf5bce60aac4df138ebd";
    hash = "sha256-fRnyCcgRYHTYjU05usrNkqesuUrtDF6rmckMrkndAqs=";
    finalImageName = "jlesage/jdownloader-2";
    finalImageTag = "latest";
  };
  "klausmeyer/docker-registry-browser:latest" = dockerTools.pullImage {
    imageName = "klausmeyer/docker-registry-browser";
    imageDigest = "sha256:04c57880532f0fa55e3bb99d02fbb01afecd7ce9641dc8e15c077277fa15670b";
    hash = "sha256-B1WKcLLyMy8raq7oW01uqzHmQ8d7q7moLHLrQV9fSBA=";
    finalImageName = "klausmeyer/docker-registry-browser";
    finalImageTag = "latest";
  };
  "openspeedtest/latest:latest" = dockerTools.pullImage {
    imageName = "openspeedtest/latest";
    imageDigest = "sha256:1745e913f596fe98882b286a67751efdae74774e9caa742a4934bb056e8748d2";
    hash = "sha256-Dost9UNh9uax6SNEguC/Jydtsr1scJ5Ilgh/SBkOCns=";
    finalImageName = "openspeedtest/latest";
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
    imageDigest = "sha256:0f2972346b7a6713563d875a7c30a97a2f45f72117573f65dfe8fd81fd44b016";
    hash = "sha256-I8HyIadY2AjUFE+G4QojSyU++kE/XEKtD+RKUAHWxZw=";
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
    imageDigest = "sha256:f8883d02ced98925c76f6e332e8dd5a53914a616b0dcb320e2b9ee4fa49eb4a1";
    hash = "sha256-HqFh7gkCYcF8WikSBCgmZcEx5XGIZeafDu4V3JEO5o8=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
}
