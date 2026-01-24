{
  self,
  system,
  config,
  ...
}:
{
  jibril.dynamic-ports = [ "openspeedtest" ];

  virtualisation.oci-containers.containers.openspeedtest = rec {
    imageFile = self.packages.${system}.docker-images."openspeedtest/latest:latest";
    image = imageFile.destNameTag;
    ports = [ "${toString config.jibril.ports.openspeedtest}:3000" ];
    extraOptions = [
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };

  services.caddy.virtualHosts."speed.jibril.lan".extraConfig = ''
    reverse_proxy http://localhost:${toString config.jibril.ports.openspeedtest} {
      request_buffers 35MiB
      response_buffers 35MiB
      flush_interval -1
    }
  '';
}
