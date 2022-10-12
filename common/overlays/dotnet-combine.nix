{...}: let
  combinePackages = packages: {
    buildEnv,
    lib,
    makeWrapper,
  }: let
    cli = builtins.head packages;
  in
    assert lib.assertMsg ((builtins.length packages) > 0)
    ''      You must include at least one package, e.g
            `with dotnetCorePackages; combinePackages [
                sdk_3_1 aspnetcore_5_0
             ];`'';
      buildEnv {
        name = "dotnet-core-combined";
        paths = packages;
        pathsToLink = ["/host" "/packs" "/sdk" "/sdk-manifests" "/shared" "/templates"];
        ignoreCollisions = true;
        nativeBuildInputs = [
          makeWrapper
        ];
        postBuild = ''
          cp -R ${cli}/{dotnet,nix-support} $out/
          mkdir $out/bin
          ln -s $out/dotnet $out/bin/dotnet
          wrapProgram $out/bin/dotnet \
            --prefix LD_LIBRARY_PATH : ${cli.icu}/lib
        '';
        passthru = {
          inherit (cli) icu packages;
        };
      };
in {
  nixpkgs.overlays = [
    (self: super: {
      dotnetCorePackages =
        super.dotnetCorePackages
        // {
          combinePackages = attrs: super.callPackage (combinePackages attrs) {};
        };
    })
  ];
}
