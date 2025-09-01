{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      gallery-dl = assert prev.gallery-dl.version == "1.30.2"; prev.gallery-dl.overrideAttrs rec {
        version = "1.30.5";

        src = final.fetchFromGitHub {
          owner = "mikf";
          repo = "gallery-dl";
          tag = "v${version}";
          hash = "sha256-RsYg3DSiB6DWVlwAJT7iN7rNxUJqT5EAIGNEuMuIm8Y=";
        };
      };
    })
  ];

  environment.systemPackages = [
    pkgs.gallery-dl
  ];
}
