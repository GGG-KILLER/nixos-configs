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
  ];
}
