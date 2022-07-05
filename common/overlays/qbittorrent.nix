{ ... }:

let
  version = "4.3.9";
  sha256 = "sha256-pFHeozx72qVjA3cmW6GK058IIAOWmyNm1UQVCQ1v5EU=";
in
{
  nixpkgs.overlays = [
    (self: super: {
      qbittorrent = (super.qbittorrent.overrideAttrs
        (oldAttrs: {
          inherit version;

          src = super.fetchFromGitHub {
            owner = "qbittorrent";
            repo = "qBittorrent";
            rev = "release-${version}";
            inherit sha256;
          };
        })
      );
      qbittorrent-nox = (super.qbittorrent-nox.overrideAttrs
        (oldAttrs: {
          inherit version;

          src = super.fetchFromGitHub {
            owner = "qbittorrent";
            repo = "qBittorrent";
            rev = "release-${version}";
            inherit sha256;
          };
        })
      );
    })
  ];
}
