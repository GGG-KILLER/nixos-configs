{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}: let
  sdkVersion = dotnetCorePackages.sdk_6_0.version;
  runtimeVersion = dotnetCorePackages.runtime_6_0.version;
  combined-sdk = with dotnetCorePackages;
    combinePackages [
      sdk_7_0
      sdk_6_0
      sdk_5_0
      sdk_3_1
    ];
in
  buildDotnetModule rec {
    pname = "omnisharp-roslyn";
    version = "1.39.0";

    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = pname;
      rev = "v${version}";
      sha256 = "XwW4rPZKz9+p8rDoFirF5XwuouiwsKbu4bUrcZP0xhc=";
    };

    projectFile = "src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj";
    nugetDeps = ./deps.nix;

    dotnet-runtime = combined-sdk;

    dotnetInstallFlags = [
      "--framework net6.0"
    ];
    dotnetBuildFlags = [
      "--framework net6.0"
    ];

    executables = ["OmniSharp"];

    postPatch = ''
      # Relax the version requirement
      substituteInPlace global.json \
        --replace '7.0.100-preview.4.22252.9' '${sdkVersion}'
      for project in src/OmniSharp.Http.Driver/OmniSharp.Http.Driver.csproj src/OmniSharp.LanguageServerProtocol/OmniSharp.LanguageServerProtocol.csproj src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj; do
        substituteInPlace $project \
          --replace '<RuntimeFrameworkVersion>6.0.0-preview.7.21317.1</RuntimeFrameworkVersion>' '<RuntimeFrameworkVersion>${runtimeVersion}</RuntimeFrameworkVersion>' \
          --replace '<RuntimeIdentifiers>win7-x64;win7-x86;win10-arm64</RuntimeIdentifiers>' ''''''
      done
    '';

    postFixup = ''
      # Delete files to mimick hacks in https://github.com/OmniSharp/omnisharp-roslyn/blob/bdc14ca/build.cake#L594
      rm $out/lib/omnisharp-roslyn/NuGet.*.dll
      rm $out/lib/omnisharp-roslyn/System.Configuration.ConfigurationManager.dll
    '';

    meta = with lib; {
      description = "OmniSharp based on roslyn workspaces";
      homepage = "https://github.com/OmniSharp/omnisharp-roslyn";
      platforms = platforms.unix;
      sourceProvenance = with sourceTypes; [
        fromSource
        binaryNativeCode # dependencies
      ];
      license = licenses.mit;
      maintainers = with maintainers; [tesq0 ericdallo corngood mdarocha];
      mainProgram = "OmniSharp";
    };
  }
