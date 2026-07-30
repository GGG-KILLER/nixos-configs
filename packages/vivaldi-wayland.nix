{
  vivaldi,
  vivaldi-ffmpeg-codecs,
  widevine-cdm,
  binutils,
}:
(vivaldi.override {
  proprietaryCodecs = true;
  inherit vivaldi-ffmpeg-codecs;
  enableWidevine = true;
  inherit widevine-cdm;
  commandLineArgs = "--ozone-platform=wayland --enable-features=UseOzonePlatform";
}).overrideAttrs
  (old: {
    # nixpkgs' vivaldi-ffmpeg-codecs is stale (pinned to an old Chromium snap
    # build) and routinely lags behind Vivaldi's own ffmpeg symbol
    # requirements, causing "undefined symbol" crashes at launch. Vivaldi's
    # own launcher script (opt/vivaldi/vivaldi) prefers this symlink over its
    # built-in self-healing `update-ffmpeg` mechanism, which fetches a
    # correctly matched build straight from Vivaldi on first run. Dropping
    # the symlink lets that mechanism take over instead.
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ binutils ];
    postInstall = (old.postInstall or "") + ''
      # If nixpkgs ever ships a vivaldi-ffmpeg-codecs new enough to provide
      # this symbol, the workaround above is likely no longer needed --
      # fail loudly instead of silently keeping dead workaround code.
      if nm -D --defined-only ${vivaldi-ffmpeg-codecs}/lib/libffmpeg.so \
          | grep -q ' av_dynamic_hdr_smpte2094_app5_to_t35$'; then
        echo "vivaldi-ffmpeg-codecs now provides av_dynamic_hdr_smpte2094_app5_to_t35 -- re-check whether packages/vivaldi-wayland.nix's libffmpeg.so workaround is still needed" >&2
        exit 1
      fi
      rm -f "$out/opt/vivaldi/libffmpeg.so."*
    '';
  })
