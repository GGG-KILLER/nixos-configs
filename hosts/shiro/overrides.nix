{...}: {
  nixpkgs.overlays = [
    (self: super: {
      step-ca = super.step-ca.overrideDerivation (oldAttrs: {
        src = super.fetchFromGitHub {
          owner = "smallstep";
          repo = "certificates";
          rev = "refs/tags/v${oldAttrs.version}";
          hash = "sha256-byVWNab6Q3yryluhMomzLkRNfXQ/68pAq+YGFjbvX1o=";
        };
      });
    })
  ];
}
