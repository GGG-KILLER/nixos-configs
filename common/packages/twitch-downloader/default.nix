{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  stdenv,
  ffmpeg,
  fontconfig,
}:

buildDotnetModule rec {
  pname = "twitch-downloader";
  version = "1.55.0";

  src = fetchFromGitHub {
    owner = "lay295";
    repo = "TwitchDownloader";
    rev = version;
    hash = "sha256-OB11WN+oSwLCBUX2tsUN+A1Fw8zNQYCjv5eB4XkZ1jA=";
  };

  projectFile = "TwitchDownloaderCLI/TwitchDownloaderCLI.csproj";
  nugetDeps = ./deps.nix;

  runtimeDeps = [
    # SkiaSharp
    fontconfig
    stdenv.cc.cc
    # Xabe.FFmpeg
    ffmpeg
  ];

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  executables = [ meta.mainProgram ];

  meta = {
    description = "Twitch VOD/Clip Downloader - Chat Download/Render/Replay";
    homepage = "https://github.com/lay295/TwitchDownloader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ggg ];
    mainProgram = "TwitchDownloaderCLI";
    platforms = lib.platforms.all;
  };
}
