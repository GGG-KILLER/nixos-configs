{ ... }:
{
  imports = [
    ./gaming
    ./monitoring
    ./services
    ./vpn/mullvad.nix
    ./nginx.nix
  ];
}
