{
  self,
  system,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkMerge getExe;
  csdevkit-vscode-ext = self.packages.${system}."ms-dotnettools.csdevkit";
  csharp-vscode-ext = self.packages.${system}."ms-dotnettools.csharp";

  settings = {
    # Disable telemetry
    "dotnetAcquisitionExtension.enableTelemetry" = false;
    "gitlens.telemetry.enabled" = false;
    "redhat.telemetry.enabled" = false;

    # Set window options
    "window.titleBarStyle" = "custom";
    "workbench.colorCustomizations" = {
      "editorInlayHint.background" = "#ffffff00";
      "editorInlayHint.foreground" = "#f8f8f87e";
      "editorInlayHint.parameterBackground" = "#ffffff00";
      "editorInlayHint.parameterForeground" = "#f8f8f87e";
      "editorInlayHint.typeBackground" = "#ffffff00";
      "editorInlayHint.typeForeground" = "#f8f8f87e";
    };

    # Set powershell dynamic parts manually
    "powershell.powerShellAdditionalExePaths" = {
      "PowerShell Core 7 (x64)" = getExe pkgs.powershell;
    };
    "powershell.promptToUpdatePowerShell" = false;

    # Disable any type of auto-update
    "extensions.autoCheckUpdates" = false;
    "extensions.autoUpdate" = false;
    "update.mode" = "none";

    # Set nix dynamic stuff manually
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = getExe pkgs.nixd;
    "nix.formatterPath" = getExe pkgs.nixfmt-rfc-style;
    "nix.serverSettings"."nixd"."formatting"."command" = [ (getExe pkgs.nixfmt-rfc-style) ];

    # LTeX Language Client
    "ltex.ltex-ls.path" = toString (lib.getBin pkgs.ltex-ls-plus);
  };
in
{
  home-manager.users.ggg = mkMerge [
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;

        # Only install extensions through nix.
        mutableExtensionsDir = false;
        profiles.default.extensions =
          [
            # C# Development
            (csdevkit-vscode-ext.overrideAttrs (old: {
              inherit (pkgs.vscode-marketplace.ms-dotnettools.csdevkit) version src;
            }))
            (csharp-vscode-ext.overrideAttrs (old: {
              inherit (pkgs.vscode-marketplace.ms-dotnettools.csharp) version src;
            }))
          ]
          # Nixpkgs' vscode extensions tend to lag behind quite often, so we just use their build
          # script but with the auto-updated vscode marketplace sources and versions.
          ++ (
            let
              updateExt =
                getExt:
                ((getExt pkgs.vscode-extensions).overrideAttrs (old: {
                  inherit (getExt pkgs.vscode-marketplace) version src;
                }));
            in
            [
              (updateExt (exts: exts.dart-code.dart-code))
              (updateExt (exts: exts.dart-code.flutter))
              (updateExt (exts: exts.foxundermoon.shell-format))
              (updateExt (exts: exts.ms-dotnettools.vscode-dotnet-runtime))
              (updateExt (exts: exts.ms-toolsai.jupyter))
              (updateExt (exts: exts.ms-vscode-remote.remote-ssh))
              # (updateExt (exts: exts.rust-lang.rust-analyzer)) # TODO: Uncomment when NixOS/nixpkgs#383049 gets merged
              (updateExt (exts: exts.timonwong.shellcheck))
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
            ltex-plus.vscode-ltex-plus
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
        # rust-analyzer # TODO: Uncomment when NixOS/nixpkgs#383049 gets merged
        shellcheck
        nixfmt-rfc-style
      ];
    }
    # Update the settings.json (author: @Myaats)
    (
      { config, pkgs, ... }:
      {
        home.activation.update-code-settings = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          DIRNAME=$(dirname ~/.config/Code/User/settings.json)
          mkdir -p $DIRNAME
          if [ ! -f ~/.config/Code/User/settings.json ]
          then
              echo "{}" > ~/.config/Code/User/settings.json
          fi

          # Store it as a variable to avoid race condition
          UPDATED_JSON=$(${pkgs.jq}/bin/jq -s 'reduce .[] as $item ({}; . * $item)' ~/.config/Code/User/settings.json ${pkgs.writeText "updated.json" (builtins.toJSON settings)})
          echo "$UPDATED_JSON" > ~/.config/Code/User/settings.json
        '';
      }
    )
  ];
}
