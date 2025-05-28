{ pkgs, ... }:
{
  imports = [
    ./desktop
    ./services
    ./boot.nix
    ./ccache.nix
    ./firejail.nix
    ./fonts.nix
    ./hardening.nix
    ./kernel.nix
    ./libvirtd.nix
    ./programs.nix
    ./yubikey.nix
  ];

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc # libdl
    gtk3 # libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libgdk-3.so.0
    libGL # libGL.so.1
    xorg.libICE # libICE.so.6
    xorg.libSM # libSM.so.6
    xorg.libX11 # libX11 libX11.so.6
    xorg.libXcursor # libXcursor.so.1
    xorg.libXi # libXi.so.6
    xorg.libXrandr # libXrandr.so.2
    fontconfig # libfontconfig.so.1
  ];

  # Enable sysdig
  programs.sysdig.enable = true;

  programs.zsh.ohMyZsh.plugins = [
    "copybuffer"
    "copyfile"
    "docker"
    "docker-compose"
    "dotnet"
    "git"
    "git-auto-fetch"
  ];
}
