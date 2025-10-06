{
  system,
  self,
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  dotnet-sdk =
    (
      with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_10_0-bin
        sdk_9_0-bin
        sdk_8_0-bin
      ]
    ).overrideAttrs
      (prev: {
        postInstall =
          prev.postInstall or ""
          + ''
            # Un-link things to avoid problems
            find "$out" -type l -exec sh -c 'PREV=$(realpath -- "$1") && echo "  $PREV -> $1" && rm -- "$1" && cp --archive --dereference --recursive -- "$PREV" "$1"' resolver {} \;

            # Fix dotnet not finding host/fxr
            rm "$out"/bin/dotnet
            ln -s "$out"/share/dotnet/dotnet "$out"/bin/dotnet
          ''
          + lib.optionalString (prev.src ? man) ''
            # Un-link things to avoid problems
            find "$man" -type l -exec sh -c 'PREV=$(realpath -- "$1") && echo "  $PREV -> $1" && rm -- "$1" && cp --archive --dereference --recursive -- "$PREV" "$1"' resolver {} \;
          '';
      });
  dotnetRoot = "${dotnet-sdk}/share/dotnet";

  agenix = inputs.agenix.packages.${system}.default;
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  git-crypt-agessh = inputs.git-crypt-agessh.packages.${system}.default;

  inherit (self.packages.${system})
    kemono-dl
    m3u8-dl
    ;
  inherit (config.boot.kernelPackages) turbostat;
in
{
  environment.systemPackages = (
    with pkgs;
    [
      # Coding
      # avalonia-ilspy # TODO: re-add when it no longer depends on .NET 6
      corepack_latest
      delta
      deno
      docker-compose
      dotnet-ef
      dotnet-outdated
      dotnet-repl
      dotnet-sdk
      nix-prefetch-scripts
      nixd
      nixf
      nixfmt-rfc-style
      nodejs_latest
      powershell
      tokei

      # Downloads
      aria
      kemono-dl
      m3u8-dl
      yt-dlp

      # Encryption
      age
      agenix
      git-crypt-agessh

      # Nix
      deploy-rs
      nh
      nix-output-monitor
      nixpkgs-review

      # Media
      ffmpeg

      # Terminal tools
      mprocs
      parted
      turbostat
      wl-clipboard
      xh
      uutils-coreutils-noprefix
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
}
