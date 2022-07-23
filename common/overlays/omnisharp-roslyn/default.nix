{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}: let
  sdk-version = dotnetCorePackages.sdk_6_0.version;
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

    dotnet-sdk = dotnetCorePackages.sdk_6_0;
    dotnet-runtime = dotnetCorePackages.runtime_6_0;

    dotnetInstallFlags = ["--framework net6.0" "--no-self-contained"];
    dotnetBuildFlags = ["--framework net6.0" "--no-self-contained"];
    dotnetFlags = ["--runtime linux-x64"];

    executables = ["OmniSharp"];

    postPatch = ''
      # Relax the version requirement
      substituteInPlace global.json \
        --replace '7.0.100-preview.4.22252.9' '${sdk-version}'
      for project in src/OmniSharp.Http.Driver/OmniSharp.Http.Driver.csproj src/OmniSharp.LanguageServerProtocol/OmniSharp.LanguageServerProtocol.csproj src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj; do
        substituteInPlace $project \
          --replace '<RuntimeFrameworkVersion>6.0.0-preview.7.21317.1</RuntimeFrameworkVersion>' "" \
          --replace '<RollForward>LatestMajor</RollForward>' ""
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
