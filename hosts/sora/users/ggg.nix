{ pkgs, rnix-lsp, ... }:

{
  users.users.ggg.packages = with pkgs; [
    powershell
    helvum
    virt-manager
    vscode
    rnix-lsp
    morph
  ];

  modules.home.mainUsers = [ "ggg" ];
}
