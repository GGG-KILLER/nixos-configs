{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
in {
  console.font = mkForce "Cascadia Code";
  fonts = {
    enableDefaultFonts = true;

    fontconfig = {
      enable = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      hinting = {
        autohint = true;
        enable = true;
      };
      # defaultFonts.serif = [
      #   "Times New Roman"
      #   # "DejaVu Serif"
      # ];
      # defaultFonts.emoji = [
      #   "Segoe UI Emoji"
      #   # "Noto Color Emoji"
      # ];
      # defaultFonts.sansSerif = [
      #   "Arial"
      #   # "DejaVu Sans"
      # ];
      defaultFonts.monospace = [
        "Cascadia Code"
        "Consolas"
      ];
    };

    fontDir.enable = true;
    fonts = with pkgs; [
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
