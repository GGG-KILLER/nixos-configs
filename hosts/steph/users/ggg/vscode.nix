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
    "nix.serverSettings"."nixd"."formatting"."command" = [ (getExe pkgs.nixfmt) ];

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
        mutableExtensionsDir = true; # Needed for Copilot to work properly
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
              "dbaeumer.vscode-eslint"
              "eamodio.gitlens"
              "editorconfig.editorconfig"
              "foxundermoon.shell-format"
              "github.copilot-chat"
              "james-yu.latex-workshop"
              "jnoortheen.nix-ide"
              "ltex-plus.vscode-ltex-plus"
              "mhutchie.git-graph"
              "mikestead.dotenv"
              "mkhl.direnv"
              "ms-azuretools.vscode-docker"
              "ms-dotnettools.vscode-dotnet-runtime"
              "ms-python.python"
              "ms-vscode-remote.remote-containers"
              "ms-vscode.powershell"
              "oderwat.indent-rainbow"
              "pkief.material-icon-theme"
              "redhat.vscode-yaml"
              "tamasfe.even-better-toml"
              "timonwong.shellcheck"
            ];
          in
          (pkgs.nix4vscode.forVscodeExtVersionPrerelease (getDecorators names) package.version names)
          ++ [
            self.packages.${system}.ms-dotnettools-csharp
            self.packages.${system}.ms-dotnettools-csdevkit
          ];
      };

      home.packages = with pkgs; [
        shellcheck
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
