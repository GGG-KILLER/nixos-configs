{ pkgs, ... }:

let
  dotnet-sdk = pkgs: (with pkgs.dotnetCorePackages; combinePackages [
    sdk_6_0
    sdk_5_0
    sdk_3_1
  ]);
  devtools = pkgs: with pkgs; [
    (dotnet-sdk pkgs)
    mono
    morph
    powershell
    rnix-lsp
  ];
in
{
  home-manager.users.ggg = {
    home.packages = (with pkgs; [
      helvum
      virt-manager
      openrgb
      libguestfs-with-appliance
    ]) ++ (devtools pkgs);

    programs = {
      home-manager.enable = true;
      vscode = {
        enable = true;
        package = pkgs.vscode-fhsWithPackages devtools;
      };
      git = {
        enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager-core";
          credential.credentialStore = "secretservice";
        };
      };
    };
  };

  modules.home.mainUsers = [ "ggg" ];
}
