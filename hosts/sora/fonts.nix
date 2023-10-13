{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
in {
  console.font = mkForce "Cascadia Code";
  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      enable = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      hinting = {
        autohint = true;
        enable = true;
      };
      defaultFonts.monospace = [
        "Cascadia Code"
        "Consolas"
      ];
    };

    fontDir.enable = true;
    packages = with pkgs; [
      cascadia-code
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      unifont
      corefonts
      vistafonts
      vistafonts-cht
      vistafonts-chs
      source-sans-pro
      source-code-pro
      # local.winfonts
    ];
  };
}
