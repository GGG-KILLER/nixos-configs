{ pkgs, ... }:

let
  dotnet-sdk = pkgs: (with pkgs.dotnetCorePackages; combinePackages [
    sdk_6_0
    sdk_5_0
    sdk_3_1
  ]);
in
{
  home-manager.users.ggg = {
    home.packages = with pkgs; [
      (dotnet-sdk pkgs)
      helvum
      mono
      morph
      powershell
      rnix-lsp
      virt-manager
    ];

    programs = {
      home-manager.enable = true;
      vscode = {
        enable = true;
        package = pkgs.vscode-fhsWithPackages (pkgs: with pkgs; [
          (dotnet-sdk pkgs)
          mono
          morph
          rnix-lsp
        ]);
      };
      git = {
        enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
      };
    };
  };

  modules.home.mainUsers = [ "ggg" ];
}
