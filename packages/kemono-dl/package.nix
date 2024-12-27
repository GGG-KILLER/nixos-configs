{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0.0.8";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "129390cccd01646d967bd9c55da0b4c1bfe20845";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "kemono-dl";
  executables = [ meta.mainProgram ];
}
