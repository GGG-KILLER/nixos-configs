{ ... }:
{
  imports = [
    ./authentik.nix
    ./step-ca.nix
    ./wireguard.nix
  ];
}
