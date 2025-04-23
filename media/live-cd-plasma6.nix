{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    ./live-cd-base.nix
  ];
}
