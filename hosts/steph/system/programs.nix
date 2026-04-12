{
  system,
  self,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  dotnet-sdk = self.packages.${system}.combined-dotnet-sdk;
  dotnetRoot = "${dotnet-sdk}/share/dotnet";

  agenix = inputs.agenix.packages.${system}.default;
  git-crypt-agessh = inputs.git-crypt-agessh.packages.${system}.default;

  inherit (self.packages.${system})
    m3u8-dl
    ;
in
{
  environment.systemPackages = (
    with pkgs;
    [
      # Ark archives support
      unar
      unrar
      _7zz
      p7zip-rar

      # Coding
      corepack_24
      delta
      dotnet-outdated
      dotnet-repl
      dotnet-sdk
      nix-prefetch-docker
      nix-prefetch-github
      nix-prefetch-scripts
      nixd
      nixf
      nixfmt
      nodejs_24
      powershell
      python3
      tokei

      # Downloads
      aria2
      m3u8-dl
      yt-dlp

      # Encryption
      age
      agenix
      git-crypt-agessh

      # Nix
      nh
      nix-output-monitor
      nixpkgs-review

      # Media
      ffmpeg

      # Terminal tools
      mprocs
      wl-clipboard
      xh
      uutils-coreutils-noprefix
      nvtopPackages.amd

      # Misc
      glow
      iperf3
    ]
  );

  environment.shellAliases = {
    df = "dysk";
    du = "dust";
  };

  environment.variables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };

  environment.etc = {
    "dotnet/install_location".text = dotnetRoot;
  };

  # Enable mtr
  programs.mtr.enable = true;

  # btop wrapper for GPU stats
  security.wrappers.btop = {
    owner = "root";
    group = "root";
    capabilities = "cap_perfmon=+ep";
    source = lib.getExe pkgs.btop;
  };
}
