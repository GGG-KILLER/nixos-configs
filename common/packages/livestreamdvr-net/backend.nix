{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "livestreamdvr-net-backend";
  version = "1-unstable-2024-10-19";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "LiveStreamDVR.NET";
    rev = "ba4a8e29c971e76747de2591236b5e15d01151cf";
    hash = "sha256-cnZG7RA7cJrOyFQQSm5qbHa5l6Oe8tVemfJlgt7zYVQ=";
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
