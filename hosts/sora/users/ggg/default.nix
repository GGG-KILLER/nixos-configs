{ pkgs, ... }:

let
  dotnet-sdk = pkgs: (with pkgs.dotnetCorePackages; combinePackages [
    aspnetcore_6_0
    sdk_6_0
    runtime_6_0
    aspnetcore_5_0
    sdk_5_0
    runtime_5_0
    aspnetcore_3_1
    sdk_3_1
    runtime_3_1
  ]);
  devtools = pkgs: with pkgs; [
    (dotnet-sdk pkgs)
    mono
    powershell
    rnix-lsp
  ];
in
{
  imports = [
    ./vscode.nix
  ];

  home-manager.users.ggg = {
    home.packages = (with pkgs; [
      helvum
      virt-manager
      openrgb
      libguestfs-with-appliance
    ]) ++ (devtools pkgs);

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager-core";
          credential.credentialStore = "secretservice";
          init.defaultBranch = "main";
        };
      };
    };
  };

  modules.home.mainUsers = [ "ggg" ];
}
