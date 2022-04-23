{ pkgs, ... }:

{
  services.chrome-remote-desktop = {
    enable = true;
    user = "ggg";
  };
}
