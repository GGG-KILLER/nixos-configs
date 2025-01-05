{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0-unstable-2025-01-05";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "8b7e4e21e71c36851004cba3239b005d4e9f2db3";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "kemono-dl";
  executables = [ meta.mainProgram ];
}
