{ dockerTools }:
{
  "eclipse-mosquitto:2.0" = dockerTools.pullImage {
    imageName = "eclipse-mosquitto";
    imageDigest = "sha256:914f529386804c8278a4e581526b9be5e1604df44b30daabc70aa97dcefe5268";
    hash = "sha256-Pd3HH2Ppki9hhx647CWXcw6JbEbsYhg2t0XkS4VPKlw=";
    finalImageName = "eclipse-mosquitto";
    finalImageTag = "2.0";
  };
  "redis:latest" = dockerTools.pullImage {
    imageName = "redis";
    imageDigest = "sha256:832d7785830f3f4b559300e6191fc914b15642c1935252338825cf4332200148";
    hash = "sha256-BlayEU/uaKgnLZQSJJ7ywb43ZkSpFQ3db+C16NWDGp0=";
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
    imageDigest = "sha256:af60a5dd3504c97d6734322fae46784146f2becb01ec14f6a66c7ebe79c681ed";
    hash = "sha256-Mv/7AHS0XfpcpkHrkXbh6F0lhWCCGw879dE20Lh4EZk=";
    finalImageName = "ghcr.io/danbooru/danbooru";
    finalImageTag = "master";
  };
}
