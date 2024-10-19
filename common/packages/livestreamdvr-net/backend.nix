{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "livestreamdvr-net-backend";
  version = "0-unstable-2024-10-19";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "LiveStreamDVR.NET";
    rev = "9f69ab3d52ebb84bdfc75a1c4093dbdc8191f4a2";
    hash = "sha256-baA55YodFvMrypQjNHXyj4xyYAGlADfjFhj6JVszgEY=";
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
