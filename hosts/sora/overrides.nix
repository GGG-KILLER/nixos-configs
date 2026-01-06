{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = with super.mpvScripts; [
          mpris
          thumbnail
          thumbfast
          mpris
          inhibit-gnome
        ];
      };
    })
  ];
}
