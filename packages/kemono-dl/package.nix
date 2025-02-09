{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "3-unstable-2025-02-09";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "4603390cab70c252be05b225f7ae78ff48a96fb3";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "kemono-dl";
  executables = [ meta.mainProgram ];
}
