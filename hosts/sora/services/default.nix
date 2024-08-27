{ ... }:
{
  imports = [
    ./fancontrol.nix
    ./redis.nix
    ./restic.nix
    ./virtualisation.nix
  ];
}
