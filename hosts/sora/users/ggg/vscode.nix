{ pkgs, ... }:

let
  inherit (builtins) fromJSON readFile map filter;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./configs/settings.json;
  keybindings = readJSON ./configs/keybindings.json;
  inherit (pkgs.vscode-utils) extensionsFromVscodeMarketplace;
in
{
  home-manager.users.ggg = {
    programs.vscode = {
      enable = true;
      userSettings =
        settings //
        {
          "omnisharp.path" = "${pkgs.omnisharp-roslyn}/bin/omnisharp";
          "omnisharp.loggingLevel" = "trace";
          "omnisharp.enableDecompilationSupport" = true;
          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
        };
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        ms-dotnettools.csharp
        ms-azuretools.vscode-docker
        editorconfig.editorconfig
        dbaeumer.vscode-eslint
        eamodio.gitlens
        hashicorp.terraform
        ms-toolsai.jupyter
        redhat.java
        james-yu.latex-workshop
        pkief.material-icon-theme
        jnoortheen.nix-ide
        octref.vetur
        redhat.vscode-yaml
      ] ++ extensionsFromVscodeMarketplace [
        {
          publisher = "vscjava";
          name = "vscode-java-debug";
          version = "0.40.1";
        }
        {
          publisher = "cschlosser";
          name = "doxdocgen";
          version = "1.4.0";
        }
        {
          publisher = "omkov";
          name = "vscode-ebnf";
          version = "1.0.4";
        }
        {
          publisher = "venner";
          name = "vscode-glua-enhanced";
          version = "2.5.1";
        }
        {
          publisher = "kumar-harsh";
          name = "graphql-for-vscode";
          version = "1.15.3";
        }
        {
          publisher = "tht13";
          name = "html-preview-vscode";
          version = "0.2.5";
        }
        {
          publisher = "christopherstyles";
          name = "html-entities";
          version = "1.1.2";
        }
        {
          publisher = "visualstudioexptteam";
          name = "vscodeintellicode";
          version = "1.2.20";
        }
        {
          publisher = "ms-vscode";
          name = "powershell";
          version = "2021.12.0";
        }
        {
          publisher = "rust-lang";
          name = "rust";
          version = "0.7.8";
        }
      ];
    };

    home.packages = with pkgs; [
      omnisharp-roslyn
    ];
  };
}
