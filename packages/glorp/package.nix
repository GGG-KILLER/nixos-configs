{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "glorp";
  version = "0-unstable-2025-05-08";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/Glorp.git";
    rev = "1f13d033c73f3d6b0c7e4395313cf1c0585a2559";
  };

  projectFile = "Glorp/Glorp.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "Glorp";
  executables = [ meta.mainProgram ];
}
