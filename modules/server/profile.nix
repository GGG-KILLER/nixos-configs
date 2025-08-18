{ self, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    ggg-programs
    groups
    i18n
    nix-settings
    pki
    sudo-rs
    users
    zsh
  ];
}
