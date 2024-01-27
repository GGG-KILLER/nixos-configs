{lib, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      nixVersions = lib.mapAttrs (x: y:
        y.overrideAttrs (previousAttrs: {
          patches =
            previousAttrs.patches
            ++ [
              (
                if previousAttrs.version == "2.19.3"
                then ./nix/getMaxCPU_2_19.patch
                else ./nix/getMaxCPU_2_18.patch
              )
            ];
        }))
      prev.nixVersions;
    })
  ];
}
