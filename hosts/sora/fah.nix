{config, ...}: {
  services.foldingathome = {
    enable = true;
    user = "GGG";
    extraArgs = ["--config=${config.age.secrets."foldingathome.xml".path}"];
    daemonNiceLevel = 19;
  };
}
