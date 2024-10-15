{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "livestreamdvr-net-backend";
  version = "2-unstable-2024-10-14";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "LiveStreamDVR.NET";
    rev = "4cfa7c065506dbd8d51570bd7edea92a49626483";
    hash = "sha256-uVMk5zMfolRYt54tCxu8Ur572t1J9XSTaw+DMwZH5lY=";
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
