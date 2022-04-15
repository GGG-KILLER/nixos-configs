{ pkgs, ... }:

{
  users.users.ggg.packages = with pkgs; [
    powershell
    helvum
    virt-manager
    vscode-fhs
    rnix-lsp
  ];
}
