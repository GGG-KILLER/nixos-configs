{ ... }:
{
  age.secrets = {
    nix-github-token = {
      file = ../../secrets/steph/nix-github-token.age;
      owner = "ggg";
      group = "wheel";
    };
  };
}
