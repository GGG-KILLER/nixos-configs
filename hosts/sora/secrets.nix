{ ... }:
{
  age.secrets = {
    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-sora-pass.age;
    nix-github-token = {
      file = ../../secrets/sora/nix-github-token.age;
      owner = "ggg";
      group = "wheel";
    };
  };
}
