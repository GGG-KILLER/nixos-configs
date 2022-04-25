{ ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideAttrs (old: rec {
      installPhase = ''
        mkdir -p $out/bin
        cp -r bin/Release/OmniSharp.Stdio.Driver/net6.0 $out/src

        # Delete files to mimick hacks in https://github.com/OmniSharp/omnisharp-roslyn/blob/bdc14ca/build.cake#L594
        rm $out/src/NuGet.*.dll
        rm $out/src/System.Configuration.ConfigurationManager.dll

        makeWrapper $out/src/OmniSharp $out/bin/omnisharp \
          --prefix DOTNET_ROOT : ${pkgs.dotnet-sdk} \
          --suffix PATH : ${pkgs.dotnet-sdk}/bin
      '';
    });
  };
}
