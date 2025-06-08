{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      libplacebo =
        assert prev.shaderc.version == "2024.0";
        prev.libplacebo.overrideAttrs (old: {
          patches = [
            # Breaks mpv vulkan shaders:
            #   https://code.videolan.org/videolan/libplacebo/-/issues/335
            (final.fetchpatch {
              name = "fix-shaders.patch";
              url = "https://github.com/haasn/libplacebo/commit/4c6d99edee23284f93b07f0f045cd660327465eb.patch";
              revert = true;
              hash = "sha256-zoCgd9POlhFTEOzQmSHFZmJXgO8Zg/f9LtSTSQq5nUA=";
            })
          ];
        });
    })
  ];
}
