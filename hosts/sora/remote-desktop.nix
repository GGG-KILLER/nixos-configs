{pkgs, ...}: {
  # services.chrome-remote-desktop = {
  #   enable = true;
  #   user = "ggg";
  # };
  services.xrdp = {
    enable = true;
    defaultWindowManager = "gnome-shell";
  };
}
