{ pkgs }:
{
  system = pkgs.lib.recurseIntoAttrs (
    pkgs.nixos [ ./default.nix ]
  );

  recurseForDerivations = true;
}
