{
  inputs,
  system,
  ...
}: let
  nixpkgs-stable = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
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
