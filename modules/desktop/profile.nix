{ self, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    i18n
    nix-settings
    pki
    zsh
  ];
}
