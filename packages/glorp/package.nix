{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "glorp";
  version = "0-unstable-2025-05-22";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "glorp";
    rev = "1c1568987457200fcf6ee5c21025170c8c8d60b0";
    hash = "sha256-pkQclcH/tqQt2I5IbDGY3PYK7lFzLuzJoV0ioBkawrg=";
  };

  projectFile = "Glorp/Glorp.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  meta.mainProgram = "Glorp";
  executables = [ meta.mainProgram ];
}
