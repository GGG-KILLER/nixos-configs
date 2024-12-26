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

      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
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

      # Only install extensions through nix.
      mutableExtensionsDir = false;
      extensions =
        [
          # C# Development
          csdevkit-vscode-ext
          csharp-vscode-ext
        ]
        # Nixpkgs' vscode extensions tend to lag behind quite often, so we just use their build
        # script but with the auto-updated vscode marketplace sources and versions.
        ++ (
          let
            nixpkgsExtensionWithLatestVersion =
              getExt:
              ((getExt pkgs.vscode-extensions).overrideAttrs (old: {
                inherit (getExt pkgs.vscode-marketplace) version src;
              }));
          in
          [
            (nixpkgsExtensionWithLatestVersion (exts: exts.dart-code.dart-code))
            (nixpkgsExtensionWithLatestVersion (exts: exts.dart-code.flutter))
            (nixpkgsExtensionWithLatestVersion (exts: exts.foxundermoon.shell-format))
            (nixpkgsExtensionWithLatestVersion (exts: exts.ms-dotnettools.vscode-dotnet-runtime))
            (nixpkgsExtensionWithLatestVersion (exts: exts.ms-toolsai.jupyter))
            (nixpkgsExtensionWithLatestVersion (exts: exts.ms-vscode-remote.remote-ssh))
            (nixpkgsExtensionWithLatestVersion (exts: exts.rust-lang.rust-analyzer))
            (nixpkgsExtensionWithLatestVersion (exts: exts.timonwong.shellcheck))
            (nixpkgsExtensionWithLatestVersion (exts: exts.valentjn.vscode-ltex))
          ]
        )
        ++ (with pkgs.vscode-marketplace; [
          christopherstyles.html-entities
          cschlosser.doxdocgen
          dbaeumer.vscode-eslint
          eamodio.gitlens
          editorconfig.editorconfig
          james-yu.latex-workshop
          jashoo.dotnetinsights
          jnoortheen.nix-ide
          l13rary.l13-diff
          mhutchie.git-graph
          mikestead.dotenv
          mkhl.direnv
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-containers
          ms-vscode.powershell
          oderwat.indent-rainbow
          omkov.vscode-ebnf
          pkief.material-icon-theme
          redhat.vscode-yaml
          tamasfe.even-better-toml
          wix.vscode-import-cost
        ]);
    };

    home.packages = with pkgs; [
      rust-analyzer
      shellcheck
      nixfmt-rfc-style
    ];
  };
}
