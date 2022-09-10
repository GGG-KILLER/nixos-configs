{
  system,
  pkgs,
  inputs,
  ...
}: let
  inherit (builtins) fromJSON readFile map filter;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./configs/settings.json;
  inherit (pkgs.vscode-utils) extensionsFromVscodeMarketplace;
in {
  home-manager.users.ggg = {
    programs.vscode = {
      enable = true;
      userSettings =
        settings
        // {
          # "omnisharp.path" = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
          # "omnisharp.dotnetPath" = "/dev/null";
          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
          "update.mode" = "none";
        };
      extensions = with pkgs.vscode-extensions;
        [
          dbaeumer.vscode-eslint
          eamodio.gitlens
          editorconfig.editorconfig
          foxundermoon.shell-format
          hashicorp.terraform
          james-yu.latex-workshop
          jnoortheen.nix-ide
          kamadorueda.alejandra
          matklad.rust-analyzer
          mhutchie.git-graph
          mikestead.dotenv
          ms-azuretools.vscode-docker
          ms-dotnettools.csharp
          ms-toolsai.jupyter
          ms-vscode-remote.remote-ssh
          octref.vetur
          oderwat.indent-rainbow
          pkief.material-icon-theme
          redhat.java
          redhat.vscode-yaml
          svelte.svelte-vscode
          timonwong.shellcheck
          valentjn.vscode-ltex
          wix.vscode-import-cost
        ]
        ++ extensionsFromVscodeMarketplace [
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
            version = "1.2.25";
            sha256 = "sha256-MpOZQsenSGBgPpVTlRGvXFgZqfAGwuDzsys8tm7d/FE=";
          }
          {
            publisher = "ms-vscode";
            name = "powershell";
            version = "2022.8.5";
            sha256 = "sha256-QwsVUakeSsdxiYdS1Z2+9jnPEyp0MeXNaaN038wJGCU=";
          }
          {
            publisher = "ms-vscode-remote";
            name = "remote-containers";
            version = "0.252.0";
            sha256 = "sha256-pXd2IjbRwYgUAGVIMLE9mQwR8mG/x0MoMfK8zVh3Mvs=";
          }
          {
            publisher = "L13RARY";
            name = "l13-diff";
            version = "1.0.3";
            sha256 = "sha256-dZAtNyMaVmBMGWCVpizK8JDZASzMo4AkIKkjPYWJn1U=";
          }
        ];
    };

    home.packages = with pkgs; [
      rust-analyzer
      shellcheck
      inputs.alejandra.defaultPackage.${system}
    ];
  };
}
