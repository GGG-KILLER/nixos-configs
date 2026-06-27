{
  config,
  pkgs,
  self,
  system,
  ...
}:
let
  imageFile = self.packages.${system}.docker-images."gggdotdev/netprobesharp:dev";
  image = imageFile.destNameTag;
in
{
  virtualisation.oci-containers.networks.netprobesh-mac = {
    driver = "macvlan";
    subnets = [ "10.0.0.0/8" ];
    gateways = [ "10.0.0.1" ];
    # 10.0.3.1 - 10.0.3.6
    ipRanges = [ "10.0.3.0/29" ];
    driverOptions = {
      parent = "enp0s31f6";
    };
  };

  # macvlan containers aren't reachable from the host (the parent interface
  # can't ARP its own macvlan children). Give the host a macvlan shim on the
  # same parent/subnet so it can reach the containers' real IPs directly,
  # instead of trying to publish ports (which doesn't work for macvlan).
  systemd.services.netprobesh-shim = {
    description = "macvlan shim for host access to netprobesh-mac containers";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.iproute2}/bin/ip link add netprobesh-shim link enp0s31f6 type macvlan mode bridge"
        "${pkgs.iproute2}/bin/ip addr add 10.0.3.3/29 dev netprobesh-shim"
        "${pkgs.iproute2}/bin/ip link set netprobesh-shim up"
      ];
      ExecStop = "${pkgs.iproute2}/bin/ip link del netprobesh-shim";
    };
  };

  virtualisation.oci-containers.containers.netprobesharp-ti = {
    inherit imageFile image;
    environmentFiles = [ config.age.secrets."netprobesharp.env".path ];
    networks = [ "netprobesh-mac" ];
    extraOptions = [
      "--ip=10.0.3.1"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobesharp-co = {
    inherit imageFile image;
    environmentFiles = [ config.age.secrets."netprobesharp.env".path ];
    networks = [ "netprobesh-mac" ];
    extraOptions = [
      "--ip=10.0.3.2"
      "--ipc=none"
    ];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "netprobesharp";
      static_configs = [
        {
          targets = [ "10.0.3.1:9464" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
            isp = "Ti";
          };
        }
        {
          targets = [ "10.0.3.2:9464" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
            isp = "Co";
          };
        }
      ];
      scrape_interval = "30s";
      scrape_timeout = "25s";
    }
  ];
}
