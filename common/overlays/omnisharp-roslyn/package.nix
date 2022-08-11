{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  icu,
  lib,
  patchelf,
}: let
  inherit (dotnetCorePackages) sdk_6_0;
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

    dotnetInstallFlags = ["--framework net6.0"];
    dotnetBuildFlags = ["--framework net6.0"];
    dotnetFlags = [
      # These flags are set by the cake build.
      "-property:PackageVersion=${version}"
      "-property:AssemblyVersion=${version}.0"
      "-property:FileVersion=${version}.0"
      "-property:InformationalVersion=${version}"
      "-property:RuntimeFrameworkVersion=6.0.0-preview.7.21317.1"
      "-property:RollForward=LatestMajor"
    ];

    postPatch = ''
      # Relax the version requirement
      substituteInPlace global.json \
        --replace '7.0.100-preview.4.22252.9' '${sdk_6_0.version}'
    '';

    dontDotnetFixup = true; # we'll fix it ourselves
    postFixup = ''
      # Emulate what .NET 7 does to its binaries while a fix doesn't land in buildDotnetModule
      patchelf --set-interpreter $(patchelf --print-interpreter ${sdk_6_0}/dotnet) \
        --set-rpath $(patchelf --print-rpath ${sdk_6_0}/dotnet) \
        $out/lib/omnisharp-roslyn/OmniSharp

      # Now create a wrapper without DOTNET_ROOT
      # we explicitly don't set DOTNET_ROOT as it should get the one from PATH
      # as you can use any .NET SDK higher than 6 to run OmniSharp and you most
      # likely will NOT want the .NET 6 runtime running it (as it'll use that to
      # detect the SDKs for its own use, so it's better to let it find it in PATH).
      makeWrapper $out/lib/omnisharp-roslyn/OmniSharp $out/bin/OmniSharp \
        --prefix LD_LIBRARY_PATH : ${sdk_6_0.icu}/lib

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
