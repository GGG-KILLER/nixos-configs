{ dockerTools }: {
  "eclipse-mosquitto:2.1-alpine" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:6f8d8a947c506f8a2290ec65cd4bd2bc7cb4d43fb5f6271f861cb013e2ef9797";
    hash = "sha256-x0kJD3J/M9YgJOGRxrjG8D93HRgMSTvdupT++8ZZjPs=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.1-alpine";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:2838d5524559494f6f1cd66e97e76b200d64a633a8614200620755ed395daf32";
    hash = "sha256-/Ay8okLgGQn7hmuxEZSLvBDP/lns3mJXZQVDgWbE2IA=";
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
  "gggdotdev/netprobesharp:dev" = dockerTools.pullImage {
    imageName = "gggdotdev/netprobesharp";
    imageDigest = "sha256:880f336d13ed536c3f0dbce17f4364ede63fd277c655d201acbffe2f263a6bbe";
    hash = "sha256-mBYbsu5vR+bbMft8itWBHIRD5gVPYZHBCAJUOXji6R0=";
    finalImageName = "gggdotdev/netprobesharp";
    finalImageTag = "dev";
  };
  "jlesage/jdownloader-2:latest" = dockerTools.pullImage {
    imageName = "jlesage/jdownloader-2";
    imageDigest = "sha256:00729f90c5d057fa19c1883a3452e86a00857d2e59b0685fd6a0226f530b5bc9";
    hash = "sha256-UYwqPinCKcJgO4Kvz5B4T5HB+RYQe7CLmZDzV76Yl+o=";
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
  "zer0tonin/mikochi:latest" = dockerTools.pullImage {
    imageName = "zer0tonin/mikochi";
    imageDigest = "sha256:09872bae1554ca9c291e33be2bbff2e0d7bbe265082d2355ef28662f7bab5320";
    hash = "sha256-xls7zlXLKyIqSapeq8rgiQemJLMmKPAOdnk16Sy/D/8=";
    finalImageName = "zer0tonin/mikochi";
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
    imageDigest = "sha256:0e8de2d600f2765ec4ac69e7033e0341f8f3dec7d5f13007d85ef67f21c07551";
    hash = "sha256-ogBBIUrtWZFA7nBd2iMfObADwv8uOIVhfYeMl5QURlQ=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
  "ghcr.io/home-assistant/home-assistant:stable" = dockerTools.pullImage {
    imageName = "ghcr.io/home-assistant/home-assistant";
    imageDigest = "sha256:1476924357b46e80735c13e94232ba5c853cac052e9df4bb28d50fa56348097b";
    hash = "sha256-NFCQA5CVY9+gvpxqpraZr38TJOUlDa3eCeIY4PM0Tno=";
    finalImageName = "ghcr.io/home-assistant/home-assistant";
    finalImageTag = "stable";
  };
  "ghcr.io/koenkk/zigbee2mqtt:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/koenkk/zigbee2mqtt";
    imageDigest = "sha256:80f7f04f72a99e4c4ef51ef7e98ee736edba6db0ecbb7abc626d0c4b0f1871f1";
    hash = "sha256-0NO+nhWnQ41RX/ix04kNBPnRMoPtr14a12JiTSPSF+M=";
    finalImageName = "ghcr.io/koenkk/zigbee2mqtt";
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
