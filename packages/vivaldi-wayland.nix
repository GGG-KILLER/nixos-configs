{
  lib,
  vivaldi,
  vivaldi-ffmpeg-codecs,
  widevine-cdm,
  fetchurl,
}:
let
  # nixpkgs' vivaldi-ffmpeg-codecs is stuck on Chromium snap build 123075,
  # which lacks av_dynamic_hdr_smpte2094_app5_to_t35 and crashes Vivaldi at
  # launch with "undefined symbol". nixpkgs#540805 fixed this for Vivaldi
  # 8.1.4087.48 by pointing at snap revision _117 (2026-07-11), but nixpkgs'
  # own update.sh-driven auto-update reverted it back to 123075 three days
  # later (commit 8ecbac7ad252, 2026-07-24) -- so this isn't just "not yet
  # in our pin", it's actively being clobbered upstream and waiting won't
  # help. Bump it locally to the same fixed snap revision/build. Guarded by
  # the assert below so this override stops silently once nixpkgs' version
  # actually moves (in either direction).
  knownBrokenVersion = "123075";
  fixedVivaldiFfmpegCodecs = vivaldi-ffmpeg-codecs.overrideAttrs (old: {
    version = "2026-05-18";
    src = fetchurl {
      url = "https://api.snapcraft.io/api/v1/snaps/download/XXzVIXswXKHqlUATPqGCj2w2l7BxosS8_117.snap";
      hash = "sha256-YEE7oF8NLGDCQ3gpY5z6B+7xDxcOumjOzwUztJUM+/s=";
    };
    installPhase = ''
      install -vD chromium-ffmpeg-git-2026-05-18/chromium-ffmpeg/libffmpeg.so $out/lib/libffmpeg.so
    '';
  });
in
assert lib.assertMsg (vivaldi-ffmpeg-codecs.version == knownBrokenVersion)
  "vivaldi-ffmpeg-codecs was bumped in nixpkgs (now version ${vivaldi-ffmpeg-codecs.version}) -- re-check whether the local override in packages/vivaldi-wayland.nix is still needed";
vivaldi.override {
  proprietaryCodecs = true;
  vivaldi-ffmpeg-codecs = fixedVivaldiFfmpegCodecs;
  enableWidevine = true;
  inherit widevine-cdm;
  commandLineArgs = "--ozone-platform=wayland --enable-features=UseOzonePlatform";
}
