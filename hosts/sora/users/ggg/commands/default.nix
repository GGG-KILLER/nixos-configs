{
  lib,
  pkgs,
  config,
  ...
}:
{
  home-manager.users.ggg.home.packages =
    let
      inherit (pkgs.pog) pog _;
    in
    [
      (pog {
        name = "batwhich";
        argumentCompletion = "executables";
        script = ''
          exec ${_.bat} "$(${_.which} "$1")"
        '';
      })
      (pog {
        name = "restic-b2";
        description = "Runs restic with the B2 configurations for a given host's backup settings";

        arguments = [ { name = "...RESTIC-ARGS"; } ];
        flags = [
          {
            name = "host";
            short = "";
            argument = "HOST";
            description = "The host whose configs will be loaded.";
            required = true;
            completion = "echo 'shiro sora jibril'";
          }
        ];
        showDefaultFlags = true;

        strict = true;
        script =
          helpers: with helpers; ''
            if [[ $EUID -ne 0 ]]; then
                die "error: please run as root"
            fi

            RESTIC_REPOSITORY=
            RESTIC_ENV_FILE=
            RESTIC_ARGS=("$@")
            RESTIC_ENV_VARS=()

            case "$host" in
            sora)
              RESTIC_REPOSITORY="rclone:b2:ggg-backups-sora";
              RESTIC_ENV_VARS+=("RESTIC_PASSWORD_FILE=${config.age.secrets.backup-password.path}");
              RESTIC_ENV_FILE="${config.age.secrets.backup-envfile.path}"
              ;;
            shiro|jibril)
              RESTIC_REPOSITORY="rclone:b2:ggg-backups-shiro";
              RESTIC_ENV_VARS+=("RESTIC_PASSWORD_FILE=${config.age.secrets.shiro-backup-password.path}");
              RESTIC_ENV_FILE="${config.age.secrets.shiro-backup-envfile.path}"
              ;;
            *)
              die "error: unknown host '$host'. Available hosts are: sora, shiro, jibril."
              ;;
            esac;

            if ${file.notExists "RESTIC_ENV_FILE"}; then
                die "error: the environment file '$RESTIC_ENV_FILE' does not exist."
            fi

            RESTIC_ENV_VARS+=("RESTIC_REPOSITORY=$RESTIC_REPOSITORY");
            RESTIC_ENV_VARS+=("RCLONE_CONFIG_B2_TYPE=b2");
            RESTIC_ENV_VARS+=("RCLONE_CONFIG_B2_HARD_DELETE=true");
            readarray -t ENV_FILE_VARS < "$RESTIC_ENV_FILE";
            RESTIC_ENV_VARS+=("''${ENV_FILE_VARS[@]}");

            if ${flag "VERBOSE"}; then
                echo "Env Vars:" >&2
                printf '  %s\n' "''${RESTIC_ENV_VARS[@]}" >&2
                echo "Args:" >&2
                printf '  %s\n' "''${RESTIC_ARGS[@]}" >&2
            fi

            env "''${RESTIC_ENV_VARS[@]}" ${lib.getExe pkgs.restic} "''${RESTIC_ARGS[@]}"
          '';
      })
      (pog {
        name = "dl-twitch-stream";
        description = "Download a Twitch stream using streamlink";

        arguments = [
          { name = "streamer-username"; }
          { name = "stream-name"; }
        ];
        flags = [
          {
            name = "token";
            argument = "TOKEN";
            description = "The Twitch OAuth token to use to download the stream with.";
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
            run ${lib.getExe pkgs.streamlink} \
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
      })
    ];
}
