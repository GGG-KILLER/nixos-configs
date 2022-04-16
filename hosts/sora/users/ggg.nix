{ pkgs, rnix-lsp, morph, ... }:

{
  users.users.ggg.packages = with pkgs; [
    powershell
    helvum
    virt-manager
    vscode
    rnix-lsp
    morph
  ];
}
