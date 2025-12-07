{ inputs, ... }:
{
  imports = [
    ./video.nix
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-pstate
    common-cpu-amd-zenpower

    common-pc
    common-pc-ssd
  ]);
}
