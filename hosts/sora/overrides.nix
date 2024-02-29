{...}: {
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.wrapMpv super.mpv-unwrapped {
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
