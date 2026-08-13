{
  vivaldi,
  vivaldi-ffmpeg-codecs,
  widevine-cdm,
}:
vivaldi.override {
  proprietaryCodecs = true;
  inherit vivaldi-ffmpeg-codecs;
  enableWidevine = true;
  inherit widevine-cdm;
  commandLineArgs = "--ozone-platform=wayland --enable-features=UseOzonePlatform";
}
