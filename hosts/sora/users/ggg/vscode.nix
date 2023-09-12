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
          # eamodio.gitlens
          arrterian.nix-env-selector
          dbaeumer.vscode-eslint
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
          ms-python.python
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
          #ms-dotnettools.csharp
          pkgs.local.csdevkit-vscode-ext
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
            version = "2.5.3";
            sha256 = "sha256-evKJvE7YxJImGg2+zW1QC5JTEQL5fqbAjffMWKorsdI=";
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
            version = "2023.6.0";
            sha256 = "sha256-GRUU85WXLNsUU1NGwY17sKiBeehYfpUEKLX+uRom1aQ=";
          })
          (vscodeExt {
            id = "ms-vscode-remote.remote-containers";
            version = "0.304.0";
            sha256 = "sha256-I7jaHIPpN2UDwqBQqrb9A3fVgxpsJdi94wkovp4I0uw=";
          })
          (vscodeExt {
            id = "L13RARY.l13-diff";
            version = "1.3.2";
            sha256 = "sha256-cfvV8wfbUgCbtMqrmEqBEuudlWOhCoghIJTPKOfDUI8=";
          })
          (vscodeExt {
            id = "astro-build.astro-vscode";
            version = "2.3.3";
            sha256 = "sha256-OaTS8iwwR0SMzKt8ZtoHKs5M9PhpoUd1vDgNXmZlYrA=";
          })
          (vscodeExt {
            id = "eamodio.gitlens";
            version = "2023.6.905";
            sha256 = "sha256-00FpZleOSUCKgWELbiUYbmzRkTDq6KKkN0mmsI/OUzs=";
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
