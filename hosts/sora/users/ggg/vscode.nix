{
  system,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (builtins) fromJSON readFile;
  inherit (lib) getExe;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./vscode/settings.json;
  inherit (pkgs.vscode-utils) extensionsFromVscodeMarketplace;
in {
  home-manager.users.ggg = {
    programs.vscode = rec {
      enable = true;
      package = pkgs.vscode;
      userSettings =
        settings
        // {
          "powershell.powerShellAdditionalExePaths" = {
            "PowerShell Core 7 (x64)" = getExe pkgs.powershell;
          };
          "powershell.promptToUpdatePowerShell" = false;

          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
          "update.mode" = "none";

          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = getExe pkgs.alejandra;
          "nix.serverPath" = getExe pkgs.nil;
          "nix.serverSettings"."nil"."formatting"."command" = [(getExe pkgs.alejandra)];
        };
      extensions =
        (with pkgs.local; [
          # C# Development
          csdevkit-vscode-ext
          csharp-vscode-ext
        ])
        ++ (with pkgs.vscode-extensions; [
          foxundermoon.shell-format
          kamadorueda.alejandra
          matklad.rust-analyzer
          ms-python.python
          ms-toolsai.jupyter
          ms-vscode-remote.remote-ssh
          timonwong.shellcheck
          valentjn.vscode-ltex
        ])
        ++ (with pkgs.vscode-marketplace; [
          arrterian.nix-env-selector
          christopherstyles.html-entities
          cschlosser.doxdocgen
          dbaeumer.vscode-eslint
          eamodio.gitlens
          editorconfig.editorconfig
          james-yu.latex-workshop
          jnoortheen.nix-ide
          l13rary.l13-diff
          mhutchie.git-graph
          mikestead.dotenv
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-containers
          ms-vscode.powershell
          oderwat.indent-rainbow
          omkov.vscode-ebnf
          pkief.material-icon-theme
          redhat.vscode-yaml
          wix.vscode-import-cost
        ]);
    };

    home.packages = with pkgs; [
      rust-analyzer
      shellcheck
      inputs.alejandra.defaultPackage.${system}
    ];
  };
}
