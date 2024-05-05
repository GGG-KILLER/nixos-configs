{
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0.0.6";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "9ef41ef8a58357f099d1b6afd0d795fb39b4d390";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  meta.mainProgram = "kemono-dl";
  executables = [meta.mainProgram];
}
