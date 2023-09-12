{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (python-final: python-prev: {
            pyre-extensions = python-final.callPackage ./external/pyre-extensions.nix {};
            torchsnapshot = python-final.callPackage ./external/torchsnapshot.nix {
              torch = python-prev.torchWithCuda;
            };

            torchtntWithCuda = python-final.callPackage ./external/torchtnt.nix {
              torch = python-prev.torchWithCuda;
            };

            torchevalWithCuda = python-final.callPackage ./external/torcheval.nix {
              torch = python-prev.torchWithCuda;
            };

            torchvisionWithCuda = python-prev.torchvision.override {
              torch = python-final.torchWithCuda;
            };

            linear_operatorWithCuda = python-prev.linear_operator.override {
              torch = python-final.torchWithCuda;
            };

            gpytorchWithCuda = python-prev.gpytorch.override {
              torch = python-final.torchWithCuda;
              linear_operator = python-final.linear_operatorWithCuda;
            };

            pyro-pplWithCuda = python-prev.pyro-ppl.override {
              torch = python-final.torchWithCuda;
              torchvision = python-final.torchvisionWithCuda;
            };

            botorchWithCuda = python-prev.botorch.override {
              torch = python-final.torchWithCuda;
              gpytorch = python-final.gpytorchWithCuda;
              linear_operator = python-final.linear_operatorWithCuda;
              pyro-ppl = python-final.pyro-pplWithCuda;
            };

            torchinfoWithCuda = python-prev.torchinfo.override {
              torch = python-final.torchWithCuda;
              torchvision = python-final.torchvisionWithCuda;
            };

            lion-pytorchWithCuda = python-prev.lion-pytorch.override {
              torch = python-final.torchWithCuda;
            };

            torch-tb-profilerWithCuda = python-prev.torch-tb-profiler.override {
              torch = python-final.torchWithCuda;
              torchvision = python-final.torchvisionWithCuda;
            };
          })
        ];
    })
  ];
}
