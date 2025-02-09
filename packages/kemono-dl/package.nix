{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "2-unstable-2025-02-09";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "e409b36a0454ecde766f57c9aef8105325b73417";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "kemono-dl";
  executables = [ meta.mainProgram ];
}
