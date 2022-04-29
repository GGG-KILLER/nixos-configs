{ pkgs, ... }:

{
  writeSecretFile =
    { name
    , text
    , perms ? "400"
    }:
    pkgs.writeTextFile {
      inherit name text;
      checkPhase = ''
        chmod ${perms} $target;
      '';
    };
}
