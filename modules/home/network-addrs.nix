{ lib, ... }:
{
  options.home.addrs = lib.mkOption {
    internal = true;
    description = "Addresses of things in my home network.";
    type = with lib.types; attrsOf str;
    readOnly = true;
  };

  config.home.addrs = {
    router = "10.0.0.1";

    # Jibril (new hardware as of the izuna migration)
    jibril = "10.0.2.2";

    # Shiro: 10.0.2.0/29
    shiro-main = "10.0.2.1";
  };
}
