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
    imageDigest = "sha256:c88d347edef6249a6d2293f926f1eeb48bd40c57cbcd02c07f52e7f1fd2cb46b";
    hash = "sha256-p/pCYtRkVQaNBkFOSj7+dOe2KdGbd+HkFuvhdscH9Tg=";
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
    imageDigest = "sha256:faa153810245373dfd68b899611953d9139c337a558448a69f09e8e96374fdd0";
    hash = "sha256-4GRU2VYtL9Ti8CE+7IJAxyTkfCdqS3cT+UyG4H52EqA=";
    finalImageName = "gggdotdev/netprobesharp";
    finalImageTag = "dev";
  };
  "jlesage/jdownloader-2:latest" = dockerTools.pullImage {
    imageName = "jlesage/jdownloader-2";
    imageDigest = "sha256:47ee6c64917ca5326516ebe868714709c6bdd2e08ca0e33f6e80a943ef2019d2";
    hash = "sha256-2Nchlz6pKW0TR1u/bS83qS60NVB1fbxkTmYd61VwyiE=";
    finalImageName = "jlesage/jdownloader-2";
    finalImageTag = "latest";
  };
  "klausmeyer/docker-registry-browser:latest" = dockerTools.pullImage {
    imageName = "klausmeyer/docker-registry-browser";
    imageDigest = "sha256:b1b6a8ac182cbb346e5acb8bc80af50d0f59144758935cf59254ea799866060a";
    hash = "sha256-xU9qdSX3hmm1Q8w6ry7Q1hTjLYPEYRN1jROuDeDcAkE=";
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
    imageDigest = "sha256:42d76bb35d0a98b08a3e4be0e7b0d272b44210737370ab6014e640f6790f53db";
    hash = "sha256-vLCO47x9tQCcRYmSUfPrikqG3rCe4G+xZ2CSitUpyvE=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
  "ghcr.io/home-assistant/home-assistant:stable" = dockerTools.pullImage {
    imageName = "ghcr.io/home-assistant/home-assistant";
    imageDigest = "sha256:5a531753cea96444200158fc2b0ac7ccd739291ec50414877b396de6e0bb29b3";
    hash = "sha256-QiY8JoqZqTlITRZXvrVFcpCeFMmZgKn8BtZ90Qpc7FM=";
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
