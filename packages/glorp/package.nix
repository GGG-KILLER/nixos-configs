{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "glorp";
  version = "0-unstable-2025-05-08";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/Glorp.git";
    rev = "a4ead6cb0e4d347eec1101ef91b1eb27e7d8e08e";
  };

  projectFile = "Glorp/Glorp.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "Glorp";
  executables = [ meta.mainProgram ];
}
