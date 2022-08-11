{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  icu,
  lib,
  patchelf,
}: let
  sdkVersion = dotnetCorePackages.sdk_6_0.version;
  runtimeVersion = dotnetCorePackages.runtime_6_0.version;
  combined-sdk = with dotnetCorePackages;
    combinePackages [
      sdk_7_0
      sdk_6_0
      sdk_3_1
    ];
in
  buildDotnetModule rec {
    pname = "omnisharp-roslyn";
    version = "1.39.1";

    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = pname;
      rev = "v${version}";
      sha256 = "Fd9fS5iSEynZfRwZexDlVndE/zSZdUdugR0VgXXAdmI=";
    };

    projectFile = "src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj";
    nugetDeps = ./deps.nix;

    nativeBuildInputs = [
      patchelf
    ];

    dotnet-sdk = combined-sdk;
    dotnet-runtime = combined-sdk;

    dotnetInstallFlags = ["--framework net6.0"];
    dotnetBuildFlags = ["--framework net6.0"];
    dotnetFlags = [
      "-property:PackageVersion=${version}"
      "-property:AssemblyVersion=${version}.0"
      "-property:FileVersion=${version}.0"
      "-property:InformationalVersion=${version}"
      "-property:RuntimeFrameworkVersion=6.0.0-preview.7.21317.1"
      "-property:RollForward=LatestMajor"
    ];

    executables = ["OmniSharp"];

    postPatch = ''
      # Relax the version requirement
      substituteInPlace global.json \
        --replace '7.0.100-preview.4.22252.9' '${sdkVersion}'
    '';

    dontDotnetFixup = true; # we'll fix it ourselves
    postFixup = ''
      # Emulate what .NET 7 does to its binaries while a fix doesn't land in buildDotnetModule
      DOTNET_INTERPRETER=$(patchelf --print-interpreter ${dotnet-runtime}/dotnet)
      DOTNET_RPATH=$(patchelf --print-rpath ${dotnet-runtime}/dotnet)

      patchelf --set-interpreter $DOTNET_INTERPRETER \
        --set-rpath $DOTNET_RPATH \
        $out/lib/omnisharp-roslyn/OmniSharp
      # we explicitly don't set DOTNET_ROOT as it should get the one from PATH
      # as you can use any .NET SDK higher than 6 to run OmniSharp.
      makeWrapper $out/lib/omnisharp-roslyn/OmniSharp $out/bin/OmniSharp \
        --prefix LD_LIBRARY_PATH : ${icu}/lib

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
