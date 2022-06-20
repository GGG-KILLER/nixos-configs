{ ... }:

{
  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "0.0.0.0";
  };
}
