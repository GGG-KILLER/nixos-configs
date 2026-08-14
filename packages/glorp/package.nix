{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "glorp";
  version = "0-unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "glorp";
    rev = "1aebeb80bbf47b012fe05aeebba8744fcb3a3261";
    hash = "sha256-GOBDsVYwdSSG5BdVly4NvfVAtuN/XeiETaBabUJiFQc=";
  };

  projectFile = "Glorp/Glorp.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  meta.mainProgram = "Glorp";
  executables = [ meta.mainProgram ];
}
