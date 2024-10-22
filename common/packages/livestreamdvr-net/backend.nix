{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "livestreamdvr-net-backend";
  version = "0-unstable-2024-10-22";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "LiveStreamDVR.NET";
    rev = "e5a9a4381a118423cbec09bf1886bef058d37929";
    hash = "sha256-E/4ZLTKf/1e+tmsl2GMSjxdQbeK8l1sJ7bdvZC6NPY8=";
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
