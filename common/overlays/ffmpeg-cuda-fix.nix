{...}: {
  nixpkgs.overlays = [
    (self: super: {
      ffmpeg_5-full = super.ffmpeg_5-full.overrideAttrs (old: {
        postFixup = ''
          addOpenGLRunpath ${placeholder "lib"}/lib/libavcodec.so
          addOpenGLRunpath ${placeholder "lib"}/lib/libavutil.so
        '';
      });
    })
  ];
}
