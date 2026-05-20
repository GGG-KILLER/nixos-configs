{ dockerTools }:
{
  "eclipse-mosquitto:2.1-alpine" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:a908c65cc8e67ec9d292ef27c2c0360dbaaee7eb1b935cdd194e67697f15dea1";
    hash = "sha256-ILI5MOApV9eNT7l4Vd6PqvTD/aBmd/QgVb/sgdTKXjM=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.1-alpine";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:0c341492924cad6f5483f9133e43bd6c51ecdecbcadfac5b51657393b6a7936c";
    hash = "sha256-W1kyCJzK30iHmCWdGrUWDcbKe7vpwwx9fmMLjXoWJ2Q=";
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
    imageDigest = "sha256:78593b6cd4ddf12d335e7341a0aaca4a0ea9b781895ce0a536bdb801c700a4a5";
    hash = "sha256-7LJ6rOObrKFpmahedt/aMwbn/eGiLWjs7+fb+p5U0h0=";
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
    imageDigest = "sha256:8e5ed623422b61a846499fab7291afffc18f52884e080b30df37b4d6c5e26b97";
    hash = "sha256-nEwtBViYquAE1p9iM7HHsP77lMRYIBaVhCM4mcNHaz8=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
  "ghcr.io/home-assistant/home-assistant:stable" = dockerTools.pullImage {
    imageName = "ghcr.io/home-assistant/home-assistant";
    imageDigest = "sha256:ff875078181a0383bf3fca9f061be12d6180896dbd531de04e094e25505b0bb9";
    hash = "sha256-kf5KkHVxnb8ygztd05jpOsMIfoe4xydX9WQbrsVEPTw=";
    finalImageName = "ghcr.io/home-assistant/home-assistant";
    finalImageTag = "stable";
  };
  "ghcr.io/koenkk/zigbee2mqtt:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/koenkk/zigbee2mqtt";
    imageDigest = "sha256:67c26dcf8346aced02fe1380a6afd1b57268bcef10faae3f6057c13d5d3dfa80";
    hash = "sha256-4Z+6Th9TE4Yp9Vw2nvJqdAXek5uOHfaHw7DN45DQyvk=";
    finalImageName = "ghcr.io/koenkk/zigbee2mqtt";
    finalImageTag = "latest";
  };
  "ghcr.io/suwayomi/suwayomi-server:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/suwayomi/suwayomi-server";
    imageDigest = "sha256:6bb8fa8cf1cf86589e5851f2f1c2ede5c8248d53982ec1795a715dcde85b1da2";
    hash = "sha256-+QoJNBdrS/2k/T5ljPMZXQKUawVIb/iicrFYkhHppak=";
    finalImageName = "ghcr.io/suwayomi/suwayomi-server";
    finalImageTag = "latest";
  };
  "ghcr.io/thephaseless/byparr:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/thephaseless/byparr";
    imageDigest = "sha256:01a46a2865d9a6db5eb8ead04ec0dd33b8fbe233e8565ae70b50d4cc0af4cfb0";
    hash = "sha256-SujZfBhngyDfYTAMecMTMQ+vF4ldL4mQ8YrYY9sQbBY=";
    finalImageName = "ghcr.io/thephaseless/byparr";
    finalImageTag = "latest";
  };
}
