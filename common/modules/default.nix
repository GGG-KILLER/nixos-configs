{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./gaming
    ./monitoring
    ./services
    ./vpn/mullvad.nix
  ];
}
