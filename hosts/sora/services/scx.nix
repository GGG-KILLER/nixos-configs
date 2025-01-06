{ ... }:
{
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];
}
