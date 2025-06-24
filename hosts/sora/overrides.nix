{ lib, ... }:
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
    # TODO: Remove when NixOS/nixpkgs#419069 hits unstable. https://nixpkgs-tracker.ocfox.me/?pr=419069
    (final: prev: {
      vscode-extensions = lib.recursiveUpdate prev.vscode-extensions {
        ms-dotnettools.csdevkit = prev.vscode-extensions.ms-dotnettools.csdevkit.overrideAttrs (prev: {
          preFixup =
            prev.preFixup
            + ''
              # Fix libxml2 breakage. See https://github.com/NixOS/nixpkgs/pull/396195#issuecomment-2881757108
              mkdir -p "$out/lib"
              ln -s "${lib.getLib final.libxml2}/lib/libxml2.so" "$out/lib/libxml2.so.2"
            '';
        });
      };
    })
  ];
}
