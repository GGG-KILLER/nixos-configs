{ buildDotnetModule, dotnetCorePackages }:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0-unstable-2025-04-14";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "c70747a6a0ff0c1216a8095be73778ce2966eb0d";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "kemono-dl";
  executables = [ meta.mainProgram ];
}
