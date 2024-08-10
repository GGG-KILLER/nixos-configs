{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          pyre-extensions = python-final.callPackage ./external/pyre-extensions.nix { };

          torchsnapshot = python-final.callPackage ./external/torchsnapshot.nix {
            torch = python-prev.torch;
          };

          torchtnt = python-final.callPackage ./external/torchtnt.nix { torch = python-prev.torch; };

          torcheval = python-final.callPackage ./external/torcheval.nix { torch = python-prev.torch; };
        })
      ];
    })
  ];
}
