{...}: let
  combinePackages = packages: {
    buildEnv,
    lib,
  }: let
    cli = builtins.head packages;
  in
    assert lib.assertMsg ((builtins.length packages) != 0)
    ''      You must include at least one package, e.g
            `with dotnetCorePackages; combinePackages [
                sdk_3_1 aspnetcore_5_0
             ];`'';
      buildEnv {
        name = "dotnet-core-combined";
        paths = packages;
        pathsToLink = ["/host" "/packs" "/sdk" "/shared" "/templates"];
        ignoreCollisions = true;
        postBuild = ''
          mkdir $out/bin
          cp ${cli}/dotnet $out/dotnet
          ln -s $out/dotnet $out/bin/.dotnet-wrapped
          cp ${cli}/bin/dotnet $out/bin/dotnet
        '';
        passthru.icu = cli.icu;
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
