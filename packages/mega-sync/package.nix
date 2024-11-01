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
    rev = "67618749fcfda09d95c0625234580f26f8db2007";
    hash = "sha256-O4Jm5SJs1Vu+sKklS89KxFikDfmwfpV6uO777P+0Umk=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta.mainProgram = "MegaSync";
  executables = [ meta.mainProgram ];
}
