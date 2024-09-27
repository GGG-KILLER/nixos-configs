{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
buildDotnetModule rec {
  pname = "MegaSync";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "MegaSync";
    rev = "dbd12bd7e5ccd8465d27fab59f0f1a2db50c0507";
    hash = "sha256-ZYZx/olpMA3zy2ohtAGT9vRlTCiAjWxKQRWRm2DRR/k=";
  };

  projectFile = "MegaSync.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta.mainProgram = "MegaSync";
  executables = [ meta.mainProgram ];
}
