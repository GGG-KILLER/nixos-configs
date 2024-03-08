{
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0.0.3";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "b13e827f0ccaa6a72bfddee55dbc9196061adb80";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  meta.mainProgram = "kemono-dl";
  executables = [meta.mainProgram];
}
