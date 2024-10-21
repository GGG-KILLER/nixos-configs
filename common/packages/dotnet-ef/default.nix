{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "dotnet-ef";
  version = "9.0.0-rc.2.24474.1";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "efcore";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xH8saQZvIOU38I9AoIVIYSvR83ZNz5+MoBhjirdZ+vk=";
  };

  projectFile = "src/dotnet-ef/dotnet-ef.csproj";
  nugetDeps = ./deps.nix;

  runtimeDeps = [ ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = finalAttrs.dotnet-sdk;

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
