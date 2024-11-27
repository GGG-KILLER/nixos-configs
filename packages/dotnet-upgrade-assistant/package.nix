{
  lib,
  buildDotnetModule,
  emptyDirectory,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "upgrade-assistant";
  version = "0.5.829";

  src = emptyDirectory;

  buildInputs = [
    (dotnetCorePackages.fetchNupkg {
      inherit (finalAttrs) pname version;
      hash = "sha256-N0xEmPQ88jfirGPLJykeAJQYGwELFzKwUWdFxIgiwhY=";
      installable = true;
    })
  ];

  dotnetGlobalTool = true;

  useDotnetFromEnv = true;

  dontBuild = true;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.sdk_9_0;

  installPhase = ''
    runHook preInstall

    dotnet tool install --tool-path $out/lib/${finalAttrs.pname} --version ${finalAttrs.version} ${finalAttrs.pname}

    # remove files that contain nix store paths to temp nuget sources we made
    find $out -name 'project.assets.json' -delete
    find $out -name '.nupkg.metadata' -delete

    runHook postInstall
  '';

  executables = [ finalAttrs.pname ];

  meta = {
    description = "A tool to assist developers in upgrading .NET Framework and .NET applications to latest versions of .NET.";
    homepage = "https://dotnet.microsoft.com/en-us/platform/upgrade-assistant";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ggg ];
    mainProgram = finalAttrs.pname;
    platforms = lib.platforms.linux;
  };
})
