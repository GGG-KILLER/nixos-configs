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

  modules.home.userConfig = { pkgs, config, ... }: {
    home.activation.link-fonts =
      config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ~/.local/share/fonts
        find ~/.local/share/fonts -type l -exec unlink {} \;
        ln -s /run/current-system/sw/share/X11/fonts/* ~/.local/share/fonts
      '';

    fonts.fontconfig.enable = true;
  };
}
