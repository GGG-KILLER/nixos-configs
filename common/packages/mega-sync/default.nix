{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
buildDotnetModule rec {
  pname = "MegaSync";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "MegaSync";
    rev = "628d445a8abb862de5f68e7f42fc6b934a9271d4";
    hash = "sha256-FBptzUENJQL4TPESpLOhwlH28kNiA4edn18+6oZIg68=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  meta.mainProgram = "MegaSync";
  executables = [meta.mainProgram];
}
