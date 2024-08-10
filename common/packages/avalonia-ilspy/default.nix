{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  libX11,
  libICE,
  libSM,
  fontconfig,
  stdenv,
  icu,
  libunwind,
  openssl,
  zlib,
}:
buildDotnetModule rec {
  pname = "avalonia-ilspy";
  version = "8.0.0-preview2";

  src = fetchFromGitHub {
    owner = "icsharpcode";
    repo = "AvaloniaILSpy";
    rev = "bc00df42767ee22d93366af122dee5c0faaa6ed5";
    hash = "sha256-U6UWrO70Ac3LdZB0sMr1wcA0cy3r/kV+RGXV32X3nto=";
  };

  prePatch = ''
    rm .config/dotnet-tools.json
    rm global.json
  '';
  patches = [
    ./0001-Migrate-everything-to-.NET-6.patch
    ./0002-Update-packages.patch
  ];

  projectFile = "ILSpy/ILSpy.csproj";
  nugetDeps = ./deps.nix;

  runtimeDeps = [
    # Avalonia
    libX11
    libICE
    libSM
    # SkiaSharp
    fontconfig
    stdenv.cc.cc
    # Possibly not required
    icu
    libunwind
    openssl
    zlib
  ];

  dotnet-sdk =
    with dotnetCorePackages;
    combinePackages [
      sdk_6_0
      sdk_7_0
      sdk_8_0
    ];
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  meta.mainProgram = "ILSpy";
  executables = [ meta.mainProgram ];
}
