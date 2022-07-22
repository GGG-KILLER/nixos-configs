{...}: {
  nixpkgs.overlays = [
    (self: super: {
      combined-dotnet-sdks = with super.dotnetCorePackages;
        combinePackages [
          sdk_7_0
          sdk_6_0
          sdk_5_0
          sdk_3_1
        ];
    })
    # (self: super: {
    #   omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (old: rec {
    #     postFixup = ''
    #       # Delete files to mimick hacks in https://github.com/OmniSharp/omnisharp-roslyn/blob/bdc14ca/build.cake#L594
    #       rm $out/lib/omnisharp-roslyn/NuGet.*.dll
    #       rm $out/lib/omnisharp-roslyn/System.Configuration.ConfigurationManager.dll
    #       sed -i "s|DOTNET_ROOT='[^']*'|DOTNET_ROOT='${super.combined-dotnet-sdks}'|" $out/bin/OmniSharp
    #     '';
    #   });
    # })
  ];
}
