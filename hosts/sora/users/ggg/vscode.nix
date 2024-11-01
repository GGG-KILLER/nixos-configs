{
  self,
  system,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) fromJSON readFile;
  inherit (lib) getExe;
  readJSON = path: fromJSON (readFile path);
  settings = readJSON ./vscode/settings.json;
  csdevkit-vscode-ext = self.packages.${system}."ms-dotnettools.csdevkit";
  csharp-vscode-ext = self.packages.${system}."ms-dotnettools.csharp";
in
{
  home-manager.users.ggg = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      userSettings = settings // {
        "powershell.powerShellAdditionalExePaths" = {
          "PowerShell Core 7 (x64)" = getExe pkgs.powershell;
        };
        "powershell.promptToUpdatePowerShell" = false;

        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "update.mode" = "none";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = getExe pkgs.nixd;
        "nix.formatterPath" = getExe pkgs.nixfmt-rfc-style;
        "nix.serverSettings"."nixd"."formatting"."command" = [ (getExe pkgs.nixfmt-rfc-style) ];
      };
      extensions =
        [
          # C# Development
          csdevkit-vscode-ext
          csharp-vscode-ext
        ]
        ++ (with pkgs.vscode-extensions; [
          foxundermoon.shell-format
          rust-lang.rust-analyzer
          # ms-python.python # TODO: Add again once hash mismatch gets fixed.
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
          jashoo.dotnetinsights
          tamasfe.even-better-toml
        ]);
    };

    home.packages = with pkgs; [
      rust-analyzer
      shellcheck
      nixfmt-rfc-style
    ];
  };
}
