{ dockerTools }: {
  "eclipse-mosquitto:2.1-alpine" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:38c0da4f2ef84284d47b3b3eeea1cb3bdeabe81ee10caf0cd5c5ff61ee3ea408";
    hash = "sha256-bybqSGRaCflhWPW4pdxhBWpmb/WvFHAJz/SZ6AHlnm8=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.1-alpine";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:298e5b3bc566bade82f46ad5511777a4a07a294097ce16ada2f6a42be5239df5";
    hash = "sha256-+qNXRQ3vcFfP9OJ2MNy7aebZaDwbGSfIWs36YYqSHgk=";
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
    imageDigest = "sha256:0e15af64ed88405761e150c1b7ff5684c0d0fc7b69a5ddbc3e525cf9516b353c";
    hash = "sha256-DDcgSXGX9a4fedLfgpKIYC/MHhJ3bHKLFVo7Y6OsJjY=";
    finalImageName = "gggdotdev/netprobesharp";
    finalImageTag = "dev";
  };
  "jlesage/jdownloader-2:latest" = dockerTools.pullImage {
    imageName = "jlesage/jdownloader-2";
    imageDigest = "sha256:f16d47986bf6a5db6d67484e3b7e76404bce74f6f212809127a79eb76aa1c641";
    hash = "sha256-n+71KxqLAo1pKTqDb+GNqt96hOp05md0sKWr3BSgW2A=";
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
    imageDigest = "sha256:d403300f5655844b2f88906971e9ed917a7a10430fcd6bc8d86c35620a95de67";
    hash = "sha256-E39ocBHbh8UyyuR8gl7BP4Qxp7szNlUWzSZnFapQfSw=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
  "ghcr.io/home-assistant/home-assistant:stable" = dockerTools.pullImage {
    imageName = "ghcr.io/home-assistant/home-assistant";
    imageDigest = "sha256:d8922685169707fd91e8b9729902d975f06157d005e422874d201e0261dda196";
    hash = "sha256-KqXCugCq6JFD1OtfAFPbKbvBdAvBzwaC0IYmeh972cY=";
    finalImageName = "ghcr.io/home-assistant/home-assistant";
    finalImageTag = "stable";
  };
  "ghcr.io/koenkk/zigbee2mqtt:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/koenkk/zigbee2mqtt";
    imageDigest = "sha256:fef0de769dcd04c27b3a6d277b61046eb96284bdd4198dcb1687c3a01b3020f3";
    hash = "sha256-l/0x1w10xg7bksX4soiccb85gwbxlv/867VTZ8urLx4=";
    finalImageName = "ghcr.io/koenkk/zigbee2mqtt";
    finalImageTag = "latest";
  };
  "ghcr.io/thephaseless/byparr:latest" = dockerTools.pullImage {
    imageName = "ghcr.io/thephaseless/byparr";
    imageDigest = "sha256:874f719518f617d03a60e03411fc5d090647e1a877041e81f8dc965927c7deb6";
    hash = "sha256-1BXMKL3Uv66u041MjYSBBMbwLePeDpcLXrJihJSX/bE=";
    finalImageName = "ghcr.io/thephaseless/byparr";
    finalImageTag = "latest";
  };
}
