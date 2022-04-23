{ ... }:

{
  environment.systemPackages = with pkgs; [
    chromium
  ];

  services.chrome-remote-desktop = {
    enable = true;
    user = "ggg";
  };
}
