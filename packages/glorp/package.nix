{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "glorp";
  version = "0-unstable-2025-05-21";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/Glorp.git";
    rev = "3a2afab756d8032dd53fc11e5c66fc65ae5dcfa9";
  };

  projectFile = "Glorp/Glorp.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "Glorp";
  executables = [ meta.mainProgram ];
}
