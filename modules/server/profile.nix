{ self, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    ggg-password
    ggg-programs
    groups
    i18n
    nix-settings
    pki
    server-services
    sudo-rs
    users
    zsh
  ];
}
