{
  lib,
  pog,
  streamlink,
}:
let
  inherit (pog) _;
in
pog.pog {
  name = "dl-twitch-stream";
  description = "Download a Twitch stream using streamlink";

  arguments = [
    { name = "streamer-username"; }
    { name = "stream-name"; }
    { name = "--"; }
    { name = "[...STREAMLINK-ARGS]"; }
  ];
  flags = [
    {
      name = "token";
      argument = "TOKEN";
      description = ''
        Sets the twitch OAuth token, in case you have Twitch Turbo or a Subscription.
                              Obtain by running the following snippet in the Browser JavaScript Console:
                                  document.cookie.split("; ").find(item=>item.startsWith("auth-token="))?.split("=")[1]
      '';
      required = true;
      envVar = "TWITCH_OAUTH_TOKEN";
    }
  ];

  strict = true;
  script =
    helpers: with helpers; ''
      function run() {
        echo "$ $*"
        exec "$@"
      }

      TWITCH_BROADCASTER=
      TWITCH_STREAM_NAME=
      STREAMLINK_EXTRA_ARGS=()

      while [ "$#" -gt 0 ]; do
        case $1 in
        --)
          shift # Skip --
          STREAMLINK_EXTRA_ARGS=("$@")
          ;;
        *)
          if [[ -n "$TWITCH_BROADCASTER" && -n "$TWITCH_STREAM_NAME" ]]; then
            STREAMLINK_EXTRA_ARGS=("$@")
          elif [[ -z "$TWITCH_BROADCASTER" ]]; then
            TWITCH_BROADCASTER="$1"
          else
            TWITCH_STREAM_NAME="$1"
          fi
          ;;
        esac
        shift
      done

      if ${var.empty "TWITCH_BROADCASTER"}; then
        help
        die 'error: no streamer username provided.'
      fi

      if ${var.empty "TWITCH_STREAM_NAME"}; then
        help
        die 'error: no stream name provided.'
      fi

      if ${var.notEmpty "token"}; then
        STREAMLINK_EXTRA_ARGS+=(--twitch-api-header "Authorization=OAuth $token")
      fi

      TWITCH_STREAM_NAME="$(${_.sed} -e 's/:/ -/g; s/[^[:alnum:][:blank:]#$%()*+,.=_-]//g; s/^[[:space:]]*//; s/[[:space:]]*$//' <<<"$TWITCH_STREAM_NAME")"
      run ${lib.getExe streamlink} \
        --hls-live-edge 99999 \
        --stream-timeout 200 \
        --stream-segment-timeout 200 \
        --stream-segment-threads 5 \
        --ffmpeg-fout matroska \
        --ffmpeg-video-transcode av1 \
        --ffmpeg-audio-transcode opus \
        --twitch-disable-ads \
        --retry-streams 10 \
        --retry-max 5 \
        -o "$TWITCH_STREAM_NAME".mkv \
        --url https://www.twitch.tv/"$TWITCH_BROADCASTER" \
        --default-stream 1080p60,best \
        "''${STREAMLINK_EXTRA_ARGS[@]}"
    '';
}
