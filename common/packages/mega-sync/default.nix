{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
buildDotnetModule rec {
  pname = "MegaSync";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "MegaSync";
    rev = "ef5320bf19835236f5e1ebdb8aa03c89b1031711";
    hash = "sha256-m54h3Pgb0xXL2AsAlKxk6HV0dUYBNFeKHLj3H0PdY30=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta.mainProgram = "MegaSync";
  executables = [meta.mainProgram];
}
