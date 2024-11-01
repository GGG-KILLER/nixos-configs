{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "livestreamdvr-net-backend";
  version = "2-unstable-2024-10-26";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "LiveStreamDVR.NET";
    rev = "e6887b1b5f45754769c246c65fff9b02d0ab5898";
    hash = "sha256-L+KGZ+jdycXS4MtGzyUFCrGMIl3W4b1Oo+YnTI7mqxU=";
  };

  projectFile = "backend/src/LiveStreamDVR.Api.csproj";
  nugetDeps = ./deps.nix;

  runtimeDeps = [ ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;

  executables = [ meta.mainProgram ];

  meta = {
    description = "An automatic livestream recorder";
    homepage = "https://github.com/GGG-KILLER/LiveStreamDVR.NET";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ggg ];
    mainProgram = "LiveStreamDVR.Api";
    platforms = lib.platforms.linux;
  };
}
