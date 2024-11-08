{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv-unwrapped.wrapper {
        mpv = super.mpv-unwrapped;

        scripts = with super.mpvScripts; [
          mpris
          thumbnail
          thumbfast
          mpris
          inhibit-gnome
        ];
      };
    })
    (self: super: { lsp-plugins = super.lsp-plugins.override { php = self.php82; }; })
    (self: super: {
      python312 = super.python312.override {
        packageOverrides = python-self: python-super: {
          pywebview = python-super.pywebview.overridePythonAttrs (old: {
            checkPhase = ''
              # Cannot create directory /homeless-shelter/.... Error: FILE_ERROR_ACCESS_DENIED
              export HOME=$TMPDIR
              # QStandardPaths: XDG_RUNTIME_DIR not set
              export XDG_RUNTIME_DIR=$HOME/xdg-runtime-dir
              cat > tests/run.sh <<"END"
              #!/usr/bin/env bash
              export PYWEBVIEW_LOG=debug
              python3 -m pytest --deselect tests/test_js_api.py::test_concurrent
              END
              patchShebangs tests/run.sh
              wrapQtApp tests/run.sh
              xvfb-run -s '-screen 0 800x600x24' tests/run.sh
            '';
          });
        };
      };

      python312Packages = self.python312.pkgs;
    })
  ];
}
