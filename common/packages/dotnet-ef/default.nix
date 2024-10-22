{
  lib,
  buildDotnetModule,
  emptyDirectory,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "dotnet-ef";
  version = "9.0.0-rc.2.24474.1";

  src = emptyDirectory;

  buildInputs = [
    (dotnetCorePackages.fetchNupkg {
      inherit (finalAttrs) pname version;
      hash = "sha256-WS70qX7N5UaOXbVk/IfTBgRXl1v+przTmB3itMxsffE=";
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

  executables = [ finalAttrs.meta.mainProgram ];

  meta = {
    description = "Entity Framework Core Tools for the .NET Command-Line Interface.";
    longDescription = ''
      Entity Framework Core Tools for the .NET Command-Line Interface.

      Enables these commonly used dotnet-ef commands:
      dotnet ef migrations add
      dotnet ef migrations list
      dotnet ef migrations script
      dotnet ef dbcontext info
      dotnet ef dbcontext scaffold
      dotnet ef database drop
      dotnet ef database update
    '';
    homepage = "https://github.com/dotnet/efcore";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ggg ];
    mainProgram = "dotnet-ef";
    platforms = lib.platforms.linux;
  };
})
