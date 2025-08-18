{ self, ... }:
{
  imports = with self.nixosModules; [
    pki
    i18n
    nix-settings
  ];
}
