{ lib, config, ... }:
{
  options.ggg.iperf3.enable = (lib.mkEnableOption "iperf3 service") // {
    default = true;
  };

  config = lib.mkIf config.ggg.iperf3.enable {
    services.iperf3.enable = true;
    services.iperf3.openFirewall = true;
    # services.iperf3.rsaPrivateKey = TODO;
    # services.iperf3.authorizedUsersFile = TODO;
  };
}
