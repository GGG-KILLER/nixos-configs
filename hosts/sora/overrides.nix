{ ... }:

{
  nixpkgs.overlays = [
    # (self: super:
    #   let
    #     dotnet-sdk = with super.dotnetCorePackages; combinePackages [
    #       sdk_7_0
    #       sdk_6_0
    #       sdk_5_0
    #       sdk_3_1 # (broken)
    #     ];
    #   in
    #   {
    #     omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (old: rec {
    #       nativeBuildInputs = [ super.makeWrapper dotnet-sdk ];

    #       # postPatch = ''
    #       #   # Relax the version requirement
    #       #   substituteInPlace global.json \
    #       #     --replace '6.0.100' '${super.dotnetCorePackages.sdk_7_0.version}'
    #       # '';

    #       installPhase = ''
    #         mkdir -p $out/bin
    #         cp -r bin/Release/OmniSharp.Stdio.Driver/net6.0 $out/src

    #         # Delete files to mimick hacks in https://github.com/OmniSharp/omnisharp-roslyn/blob/bdc14ca/build.cake#L594
    #         rm $out/src/NuGet.*.dll
    #         rm $out/src/System.Configuration.ConfigurationManager.dll

    #         makeWrapper $out/src/OmniSharp $out/bin/omnisharp \
    #           --prefix DOTNET_ROOT : ${dotnet-sdk} \
    #           --suffix PATH : ${dotnet-sdk}/bin
    #       '';
    #     });
    #   })
  ];
}
