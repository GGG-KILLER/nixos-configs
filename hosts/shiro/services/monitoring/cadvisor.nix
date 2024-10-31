{ config, ... }:
{
  services.cadvisor.enable = true;
  services.cadvisor.port = config.shiro.ports.cadvisor;
  services.cadvisor.extraOptions = [
    "--raw_cgroup_prefix_whitelist=/machine.slice/"
  ];
}
