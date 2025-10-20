{
  system ? builtins.currentSystem,
}:
(import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/9100a0f413b0c601e0533d1d94ffd501ce2e7885.tar.gz";
    sha256 = "09m84vsz1py50giyfpx0fpc7a4i0r1xsb54dh0dpdg308lp4p188";
  })
  {
    src = ./.;
  }
).defaultNix.packages.${system}
