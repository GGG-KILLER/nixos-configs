{ config, pkgs, ... }:

{
  imports = [
    ./monitoring
    ./services
    ./vpn/mullvad.nix
  ];
}
