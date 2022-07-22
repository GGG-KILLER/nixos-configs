{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}: let
  sdkVersion = dotnetCorePackages.sdk_6_0.version;
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

    dotnetInstallFlags = ["--framework net6.0"];
    dotnetBuildFlags = ["--framework net6.0"];

    executables = ["OmniSharp"];

    postPatch = ''
      # Relax the version requirement
      substituteInPlace global.json \
        --replace '7.0.100-preview.4.22252.9' '${sdkVersion}'
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
    passthru.updateScript = ./updater.sh;
  }
