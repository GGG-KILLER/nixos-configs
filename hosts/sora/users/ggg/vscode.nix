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
      package = pkgs.vscode.overrideAttrs (finalAttrs: previousAttrs: {
        installPhase =
          previousAttrs.installPhase
          + ''
            chmod +x $out/lib/vscode/resources/app/node_modules/node-pty/build/Release/spawn-helper
            chmod +x $out/lib/vscode/resources/app/node_modules.asar.unpacked/node-pty/build/Release/spawn-helper
          '';
      });
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
            id = "tht13.html-preview-vscode";
            version = "0.2.5";
            sha256 = "22CeRp/pz0UicMgocfmkd4Tko9Avc96JR9jJ/+KO5Uw=";
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
            version = "2023.1.0";
            sha256 = "sha256-OiVb88BGvzsPTzKU1rGLGSMQSwKV4zI9FthOmutz34U=";
          })
          (vscodeExt {
            id = "ms-vscode-remote.remote-containers";
            version = "0.279.0";
            sha256 = "sha256-LlPeXeL+n9tGNeju+7FfZq96kn9Uj9V/5eRyg5av+oQ=";
          })
          (vscodeExt {
            id = "L13RARY.l13-diff";
            version = "1.0.3";
            sha256 = "sha256-dZAtNyMaVmBMGWCVpizK8JDZASzMo4AkIKkjPYWJn1U=";
          })
          (vscodeExt {
            id = "astro-build.astro-vscode";
            version = "0.29.5";
            sha256 = "sha256-DaXhnzAjVUhEMzcSa3+hY+aj7H6KgAqaHRlSkNH8oA8=";
          })
          (vscodeExt {
            id = "eamodio.gitlens";
            version = "2023.2.1204";
            sha256 = "sha256-FurYfkw+mOjyymR1VCGf0jJ2JCZJ8eGb1J7zD2peBjw=";
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
