{
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "kemono-dl";
  version = "0.0.5";

  src = builtins.fetchGit {
    url = "git@github.com:GGG-KILLER/kemono-dl.git";
    rev = "a6f9a311c742f707734b8b954bffda8d484f6049";
  };

  projectFile = "KemonoDl.Console/KemonoDl.Console.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  meta.mainProgram = "kemono-dl";
  executables = [meta.mainProgram];
}
