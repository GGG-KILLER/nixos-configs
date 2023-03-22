{...}: {
  nixpkgs.overlays = [
    (self: super: {
      nixpkgs-review = super.nixpkgs-review.overrideAttrs (old: rec {
        version = "2.9.0";

        src = super.fetchFromGitHub {
          owner = "Mic92";
          repo = "nixpkgs-review";
          rev = version;
          sha256 = "sha256-SNAroKkPXiX5baGPRYnzqiVwPwko/Uari/tvjIU7/4k=";
        };
      });
    })
  ];
}
