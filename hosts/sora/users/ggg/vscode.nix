{
  self,
  system,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;

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
  # Load nix4vscode
  nixpkgs.overlays = [ self.inputs.nix4vscode.overlays.forVscode ];

  home-manager.users.ggg = lib.mkMerge [
    {
      programs.vscode = rec {
        enable = true;
        package = pkgs.vscode;

        # Only install extensions through nix.
        mutableExtensionsDir = false;
        profiles.default.extensions =
          let
            mkOverride =
              name:
              let
                nixpkgs-ext = lib.attrByPath (lib.splitString "." name) null pkgs.vscode-extensions;
              in
              if nixpkgs-ext == null then
                null
              else
                {
                  inherit name;
                  value = lib.filterAttrs (
                    n: _:
                    lib.elem n [
                      "buildInputs"
                      "dontAutoPatchelf"
                      "nativeBuildInputs"
                      "patches"
                      "postConfigure"
                      "postFixup"
                      "postInstall"
                      "postPatch"
                      "preConfigure"
                      "preFixup"
                      "preInstall"
                      "prePatch"
                      "propagatedBuildInputs"
                      "sourceRoot"
                      "strictDeps"
                    ]
                  ) nixpkgs-ext;
                };
            getDecorators =
              exts-names: lib.listToAttrs (lib.filter (x: x != null) (lib.map mkOverride exts-names));

            names = [
              "avaloniateam.vscode-avalonia"
              "christopherstyles.html-entities"
              # "Continue.continue"
              "cschlosser.doxdocgen"
              "dart-code.dart-code"
              "dart-code.flutter"
              "dbaeumer.vscode-eslint"
              "denoland.vscode-deno"
              "eamodio.gitlens"
              "editorconfig.editorconfig"
              "foxundermoon.shell-format"
              "foxundermoon.shell-format"
              "james-yu.latex-workshop"
              "jashoo.dotnetinsights"
              "jnoortheen.nix-ide"
              "l13rary.l13-diff"
              "ltex-plus.vscode-ltex-plus"
              "mhutchie.git-graph"
              "mikestead.dotenv"
              "mkhl.direnv"
              "ms-azuretools.vscode-docker"
              "ms-dotnettools.csdevkit"
              # "ms-dotnettools.csharp"
              "ms-dotnettools.vscode-dotnet-runtime"
              "ms-python.python"
              "ms-toolsai.jupyter"
              "ms-vscode-remote.remote-containers"
              "ms-vscode-remote.remote-ssh"
              "ms-vscode.powershell"
              "oderwat.indent-rainbow"
              "omkov.vscode-ebnf"
              "pkief.material-icon-theme"
              "redhat.vscode-yaml"
              "rust-lang.rust-analyzer"
              "tamasfe.even-better-toml"
              "timonwong.shellcheck"
              "wix.vscode-import-cost"
            ];
          in
          (pkgs.nix4vscode.forVscodeExtVersionPrerelease (getDecorators names) package.version names)
          ++ [ self.packages.${system}."ms-dotnettools.csharp" ];
      };

      home.packages = with pkgs; [
        rust-analyzer
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
