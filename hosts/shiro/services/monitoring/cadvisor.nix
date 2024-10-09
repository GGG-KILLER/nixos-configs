{config, ...}:{
  services.cadvisor.enable = true;
  services.cadvisor.port = config.shiro.ports.cadvisor;
}
