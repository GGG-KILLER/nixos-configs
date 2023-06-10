{
  system,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  inherit (builtins) fromJSON readFile map filter;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./configs/settings.json;
  inherit (pkgs.vscode-utils) extensionsFromVscodeMarketplace;
  vscodeExt = {
    id,
    version,
    sha256,
  }: let
    parts = splitString "." id;
    publisher = last (take 1 parts);
    name = last parts;
  in {inherit publisher name version sha256;};
in {
  home-manager.users.ggg = {
    programs.vscode = {
      enable = true;
      # TODO: Undo when NixOS/nixpkgs#214617 gets fixed.
      package = pkgs.vscode;
      userSettings =
        settings
        // {
          # "omnisharp.dotnetPath" = "/dev/null";
          # "omnisharp.path" = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";

          "powershell.powerShellAdditionalExePaths" = {
            "PowerShell Core 7 (x64)" = "${pkgs.powershell}${pkgs.powershell.shellPath}";
          };
          "powershell.promptToUpdatePowerShell" = false;

          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
          "update.mode" = "none";
        };
      extensions = with pkgs.vscode-extensions;
        [
          dbaeumer.vscode-eslint
          # eamodio.gitlens
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

          # C# Development
          pkgs.local.csdevkit-vscode-ext
          #ms-dotnettools.csharp
          pkgs.local.csharp-vscode-ext
          # pkgs.local.vscodeintellicode-csharp-vscode-ext
        ]
        ++ extensionsFromVscodeMarketplace [
          (vscodeExt {
            id = "cschlosser.doxdocgen";
            version = "1.4.0";
            sha256 = "InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
          })
          (vscodeExt {
            id = "omkov.vscode-ebnf";
            version = "1.0.5";
            sha256 = "sha256-TIh8W05pe7/8wo/rFH79uOXOf1mlEXDoNdfuKhHtS1E=";
          })
          (vscodeExt {
            id = "venner.vscode-glua-enhanced";
            version = "2.5.1";
            sha256 = "QLHUFCepddhlsPMrKhxoeI/a6kdHWPCg+BPO2fBu6K4=";
          })
          (vscodeExt {
            id = "kumar-harsh.graphql-for-vscode";
            version = "1.15.3";
            sha256 = "0Al+69quQXPdFBMsSDWXjITJiux+OQSzQ7i/pgnlm/Q=";
          })
          (vscodeExt {
            id = "christopherstyles.html-entities";
            version = "1.1.2";
            sha256 = "P+IKHH9DDAgvU4Gfsc7c7QYZBE4QPooIteFSzoSoMzw=";
          })
          (vscodeExt {
            id = "visualstudioexptteam.vscodeintellicode";
            version = "1.2.30";
            sha256 = "sha256-f2Gn+W0QHN8jD5aCG+P93Y+JDr/vs2ldGL7uQwBK4lE=";
          })
          (vscodeExt {
            id = "ms-vscode.powershell";
            version = "2023.5.3";
            sha256 = "sha256-Q8DNh46FkG8X6+PGsoDoH73883GCfAgFR/QMNTn6B1o=";
          })
          (vscodeExt {
            id = "ms-vscode-remote.remote-containers";
            version = "0.294.0";
            sha256 = "sha256-Lnwan4jT5cQ/0ymd3skxS3cAhXZdwvKDRjzheX1Hqf4=";
          })
          (vscodeExt {
            id = "L13RARY.l13-diff";
            version = "1.3.2";
            sha256 = "sha256-cfvV8wfbUgCbtMqrmEqBEuudlWOhCoghIJTPKOfDUI8=";
          })
          (vscodeExt {
            id = "astro-build.astro-vscode";
            version = "2.0.7";
            sha256 = "sha256-3UGSJZFx4OdozRZe8dLkLxUXPvmGWqsmM/cW1TPzHlw=";
          })
          (vscodeExt {
            id = "eamodio.gitlens";
            version = "2023.5.2505";
            sha256 = "sha256-qqof6WdiRzrNUJQ+y9OR1QvdK98tC8oYbCSHJZekIlY=";
          })
        ];
    };

    home.packages = with pkgs; [
      rust-analyzer
      shellcheck
      inputs.alejandra.defaultPackage.${system}
    ];
  };
}
