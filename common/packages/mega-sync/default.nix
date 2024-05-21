{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
buildDotnetModule rec {
  pname = "MegaSync";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "MegaSync";
    rev = "27fae306516a509aa3e9460424710679b762f16e";
    hash = "sha256-s1sHq/Ja53Kq8hRGhfYR5gdbrreNtjJn1fVsI2ohlHY=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta.mainProgram = "MegaSync";
  executables = [meta.mainProgram];
}
