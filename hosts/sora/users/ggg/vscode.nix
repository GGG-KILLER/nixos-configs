{ system, nixpkgs-stable, pkgs, ... }:

let
  inherit (builtins) fromJSON readFile map filter;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./configs/settings.json;
  keybindings = readJSON ./configs/keybindings.json;
  inherit (pkgs.vscode-utils) extensionsFromVscodeMarketplace;
  # stablePkgs = import nixpkgs-stable { inherit system; };
  # omnisharp-roslyn = stablePkgs.omnisharp-roslyn;
in
{
  home-manager.users.ggg = {
    programs.vscode = {
      enable = true;
      userSettings =
        settings //
        {
          "omnisharp.path" = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
          # "omnisharp.loggingLevel" = "trace";
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
        matklad.rust-analyzer
        ms-vscode-remote.remote-ssh
      ] ++ extensionsFromVscodeMarketplace [
        {
          publisher = "vscjava";
          name = "vscode-java-debug";
          version = "0.40.2022041411";
          sha256 = "DMProUHtP9XtWddm5zq2lm3HaZ2FQf8pmi+2PYLY320=";
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
          version = "2022.5.1";
          sha256 = "SY6otM+g4ITOwTqb4N/aMkGrbuoNG1q4CS2BSvS88VE=";
        }
        {
          publisher = "ms-vscode-remote";
          name = "remote-containers";
          version = "0.235.0";
          sha256 = "5J9+/YCMn6fRTgPmVbvd3k5VaYXBUVkKupWPhJsL6Y0=";
        }
      ];
    };

    home.packages = [
      pkgs.omnisharp-roslyn
      pkgs.rust-analyzer
    ];
  };
}
