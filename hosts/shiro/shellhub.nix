{config, ...}: {
  services.shellhub-agent = {
    enable = true;
    tenantId = config.my.secrets.shellhub.tenantId;
  };
}
