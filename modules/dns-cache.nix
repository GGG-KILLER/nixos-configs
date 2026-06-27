{ lib, config, ... }:
{
  options.ggg.dns-cache.enable = lib.mkEnableOption "local caching DNS resolver (systemd-resolved)";

  config = lib.mkIf config.ggg.dns-cache.enable {
    services.resolved = {
      enable = true;
      settings.Resolve.Cache = "yes";
      settings.Resolve.CacheFromLocalhost = "no";
      settings.Resolve.DNSSEC = false;
    };
  };
}
