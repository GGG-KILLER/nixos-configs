{ lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in
{
  console.font = mkForce "Cascadia Code";
  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      enable = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      hinting = {
        enable = true;
        style = "medium";
      };
      defaultFonts.monospace = [
        "Cascadia Code"
        "Consolas"
      ];
    };

    fontDir.enable = true;
    fontDir.decompressFonts = true;

    packages = with pkgs; [
      cascadia-code
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      unifont
      corefonts
      vista-fonts
      vista-fonts-cht
      vista-fonts-chs
      source-sans-pro
      source-code-pro
      # local.winfonts
    ];
  };
}
