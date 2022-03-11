{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
}:

let
  morph-tar = pkgs.fetchFromGitHub {
    owner = "DBCDK";
    repo = "morph";
    rev = "master";
    hash = "sha256-0CHmjqPxBgALGZYjfJFLoLBnoI0U7oZ8WyCtu1bkzZg=";
  };
  morph = pkgs.callPackage (morph-tar + "/default.nix") { };
in

pkgs.mkShell {
  buildInputs = [
    morph
  ];
}
