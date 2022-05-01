{ lib, pkgs, ... }:

with lib;
let
  extensionPkgs = (with pkgs.gnomeExtensions; [
    always-show-titles-in-overview
    appindicator
    mpris-indicator-button
    transparent-top-bar
    just-perfection
    status-area-horizontal-spacing
    user-themes
    static-background-in-overview
    dash-to-panel
    arcmenu
  ]);
in
{
  environment.systemPackages = [ ]
    ++ extensionPkgs;

  home-manager.users.ggg = {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Flat-Remix-GTK-Blue-Darkest-Solid";
        icon-theme = "Flat-Remix-Blue-Dark";
      };
      "org/gnome/shell" = {
        enabled-extensions = map (ext: ext.uuid or ext.extensionUuid) extensionPkgs;
        disable-extension-version-validation = true;
      };
    };

    gtk = {
      enable = true;
      theme.name = "Flat-Remix-GTK-Blue-Darkest-Solid";
      iconTheme.name = "Flat-Remix-Blue-Dark";
    };
  };

  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
}
