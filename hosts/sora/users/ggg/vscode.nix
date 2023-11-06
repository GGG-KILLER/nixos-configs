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
      package = pkgs.vscode;
      userSettings =
        settings
        // {
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
          # eamodio.gitlens
          arrterian.nix-env-selector
          dbaeumer.vscode-eslint
          editorconfig.editorconfig
          foxundermoon.shell-format
          james-yu.latex-workshop
          jnoortheen.nix-ide
          kamadorueda.alejandra
          matklad.rust-analyzer
          mhutchie.git-graph
          mikestead.dotenv
          ms-azuretools.vscode-docker
          ms-python.python
          ms-toolsai.jupyter
          ms-vscode-remote.remote-ssh
          # octref.vetur
          oderwat.indent-rainbow
          pkief.material-icon-theme
          # redhat.java
          redhat.vscode-yaml
          # svelte.svelte-vscode
          timonwong.shellcheck
          valentjn.vscode-ltex
          wix.vscode-import-cost

          # C# Development
          pkgs.local.csdevkit-vscode-ext
          pkgs.local.csharp-vscode-ext
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
            id = "christopherstyles.html-entities";
            version = "1.1.2";
            sha256 = "P+IKHH9DDAgvU4Gfsc7c7QYZBE4QPooIteFSzoSoMzw=";
          })
          (vscodeExt {
            id = "ms-vscode.powershell";
            version = "2023.9.2";
            sha256 = "sha256-0Qs1SXVPcxI8NKhnCk94Kcl27rMYz9npTrxsnFu4VXk=";
          })
          (vscodeExt {
            id = "ms-vscode-remote.remote-containers";
            version = "0.315.1";
            sha256 = "sha256-esDIiSI/g/1Si8WiT9jkxM6dmSCxIhS3uzaxcc0QBj4=";
          })
          (vscodeExt {
            id = "L13RARY.l13-diff";
            version = "1.3.4";
            sha256 = "sha256-6fAtYsGTJBVgZGWXm12Tz1KBo2fFuirfzr/XJNhQ2vo=";
          })
          (vscodeExt {
            id = "eamodio.gitlens";
            version = "2023.11.504";
            sha256 = "sha256-gZco6ZXj2mkWn0llw88344NR2Ez039jcXQkSsTa5KdM=";
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
