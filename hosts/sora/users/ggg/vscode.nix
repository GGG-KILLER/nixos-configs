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
          sha256 = "Fd35SIwdOvoue7j94nuKluEJqjQrazg/Hi5c7nFF7/0=";
        }
        {
          publisher = "cschlosser";
          name = "doxdocgen";
          version = "1.4.0";
          sha256 = "InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
        }
        {
          publisher = "omkov";
          name = "vscode-ebnf";
          version = "1.0.4";
          sha256 = "7qAdCGWTThBAoI/axT+YckEc8h78t7Nq80EwHAudb0s=";
        }
        {
          publisher = "venner";
          name = "vscode-glua-enhanced";
          version = "2.5.1";
          sha256 = "QLHUFCepddhlsPMrKhxoeI/a6kdHWPCg+BPO2fBu6K4=";
        }
        {
          publisher = "kumar-harsh";
          name = "graphql-for-vscode";
          version = "1.15.3";
          sha256 = "0Al+69quQXPdFBMsSDWXjITJiux+OQSzQ7i/pgnlm/Q=";
        }
        {
          publisher = "tht13";
          name = "html-preview-vscode";
          version = "0.2.5";
          sha256 = "22CeRp/pz0UicMgocfmkd4Tko9Avc96JR9jJ/+KO5Uw=";
        }
        {
          publisher = "christopherstyles";
          name = "html-entities";
          version = "1.1.2";
          sha256 = "P+IKHH9DDAgvU4Gfsc7c7QYZBE4QPooIteFSzoSoMzw=";
        }
        {
          publisher = "visualstudioexptteam";
          name = "vscodeintellicode";
          version = "1.2.20";
          sha256 = "YfGpgIIKNK2yLE1X9vLtXBXzTD2EckiKVVOD9OnVvEA=";
        }
        {
          publisher = "ms-vscode";
          name = "powershell";
          version = "2021.12.0";
          sha256 = "QKtFxJn5ze0TbsLdQKQ7c4i6u64PzkmROqhdf2uLGvo=";
        }
        {
          publisher = "rust-lang";
          name = "rust";
          version = "0.7.8";
          sha256 = "Y33agSNMVmaVCQdYd5mzwjiK5JTZTtzTkmSGTQrSNg0=";
        }
      ];
    };

    home.packages = with pkgs; [
      omnisharp-roslyn
    ];
  };
}
