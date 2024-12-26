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
    # Set nix file settings
    "[nix]" = {
      "editor.insertSpaces" = true;
      "editor.tabSize" = 2;
    };

    # Set editor settings
    "editor.acceptSuggestionOnCommitCharacter" = false;
    "editor.detectIndentation" = false;
    "editor.fontFamily" = "'Cascadia Code'";
    "editor.fontLigatures" = true;
    "editor.formatOnPaste" = true;
    "editor.formatOnSave" = true;
    "editor.formatOnSaveMode" = "modificationsIfAvailable";
    "editor.formatOnType" = true;
    "editor.guides.bracketPairs" = "active";
    "editor.largeFileOptimizations" = false;
    "editor.linkedEditing" = true;
    "editor.maxTokenizationLineLength" = 50000;
    "editor.minimap.enabled" = false;
    "editor.mouseWheelScrollSensitivity" = 1.5;
    "editor.renderWhitespace" = "boundary";
    "editor.smoothScrolling" = true;
    "editor.snippetSuggestions" = "bottom";
    "editor.suggest.preview" = true;
    "editor.suggestSelection" = "recentlyUsedByPrefix";
    "editor.wordBasedSuggestions" = "off";
    "editor.wordWrap" = "on";
    "editor.wrappingIndent" = "same";

    # Disable telemetry
    "dotnetAcquisitionExtension.enableTelemetry" = false;
    "gitlens.telemetry.enabled" = false;
    "redhat.telemetry.enabled" = false;

    # Set file explorer settings
    "explorer.autoReveal" = "focusNoScroll";
    "explorer.confirmDelete" = false;
    "explorer.confirmPasteNative" = false;
    "explorer.copyRelativePathSeparator" = "/";

    # Enable file nesting in explorer
    "explorer.fileNesting.enabled" = true;
    "explorer.fileNesting.patterns" = {
      "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
      "*.jsx" = "\${capture}.js";
      "*.ts" = "\${capture}.js";
      "*.tsx" = "\${capture}.ts";
      "Cargo.toml" = "Cargo.lock";
      "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
      "settings.json" = "settings.*.json";
      "tsconfig.json" = "tsconfig.*.json";
    };

    "files.autoGuessEncoding" = true;
    "files.autoSave" = "onWindowChange";
    "files.exclude" = {
      "**/.classpath" = true;
      "**/.factorypath" = true;
      "**/.project" = true;
      "**/.settings" = true;
    };
    "files.insertFinalNewline" = true;
    "files.readonlyFromPermissions" = true;
    "files.simpleDialog.enable" = true;
    "files.trimTrailingWhitespace" = true;

    # Git settings
    "git.allowForcePush" = true;
    "git.autofetch" = true;
    "git.closeDiffOnOperation" = true;
    "git.confirmSync" = false;
    "git.enableSmartCommit" = false;
    "git.fetchOnPull" = true;
    "git.pullBeforeCheckout" = true;
    "git.rebaseWhenSync" = true;
    "git.terminalGitEditor" = true;
    "git.useCommitInputAsStashMessage" = true;

    # Use tree view for everything
    "scm.defaultViewMode" = "tree";
    "search.defaultViewMode" = "tree";

    # Set terminal settings
    "terminal.external.linuxExec" = "zsh";
    "terminal.integrated.defaultProfile.linux" = "zsh";
    "terminal.integrated.fontFamily" = "'Cascadia Code'";
    "terminal.integrated.rightClickBehavior" = "copyPaste";

    # Set window options
    "window.title" = "\${dirty}\${activeEditorMedium}\${separator}\${rootName}";
    "window.titleBarStyle" = "custom";
    "workbench.colorCustomizations" = {
      "editorInlayHint.background" = "#ffffff00";
      "editorInlayHint.foreground" = "#f8f8f87e";
      "editorInlayHint.parameterBackground" = "#ffffff00";
      "editorInlayHint.parameterForeground" = "#f8f8f87e";
      "editorInlayHint.typeBackground" = "#ffffff00";
      "editorInlayHint.typeForeground" = "#f8f8f87e";
    };
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.list.smoothScrolling" = true;

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

    # Misc
    "notebook.lineNumbers" = "on";
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
