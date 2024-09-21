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
    rev = "ecbe60d4defcc62c9feb9b910e12ef575de183f4";
    hash = "sha256-tY9eW8Pn6MFXMBnteFTSDpNV7bgq1dtU6Oe1gv2wPsA=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta.mainProgram = "MegaSync";
  executables = [ meta.mainProgram ];
}
