{
  pkgs,
  config,
  lib,
  ...
}: {
  home-manager.users.ggg = let
    backup-command = with pkgs;
      writeScriptBin "restic-b2" ''
        #! ${bash}${bash.shellPath}

        if [[ $EUID -ne 0 ]]; then
          echo "Please run as root" >&2
          exit
        fi

        DEBUG_MODE=false
        RESTIC_REPOSITORY=
        RESTIC_PASSWORD_FILE=
        RESTIC_ENV_FILE=
        RESTIC_ARGS=()
        RESTIC_ENV_VARS=()

        for i in "$@"; do
          case $1 in
            -h|--host)
              case $2 in
                sora)
                  RESTIC_REPOSITORY="rclone:b2:ggg-backups-sora";
                  RESTIC_ENV_VARS+=("RESTIC_PASSWORD_FILE=${config.age.secrets.backup-password.path}");
                  RESTIC_ENV_FILE="${config.age.secrets.backup-envfile.path}"
                  ;;
                shiro)
                  RESTIC_REPOSITORY="rclone:b2:ggg-backups-shiro";
                  RESTIC_ENV_VARS+=("RESTIC_PASSWORD_FILE=${config.age.secrets.shiro-backup-password.path}");
                  RESTIC_ENV_FILE="${config.age.secrets.shiro-backup-envfile.path}"
                  ;;
                *)
                  echo "Unknown host '$2'. Available hosts are: sora, shiro." >&2
                  exit 2
                  ;;
              esac;
              shift
              ;;
            -d|--debug) DEBUG_MODE=true; ;;
            --) shift; RESTIC_ARGS+=("$@"); break ;;
            "") ;;
            *) RESTIC_ARGS+=("$1") ;;
          esac
          shift
        done

        if [ -z "$RESTIC_REPOSITORY" ]; then
          echo "Please provide a host using --host." >&2
          exit 1
        fi

        if [ ! -f "$RESTIC_ENV_FILE" ]; then
          echo "The environment file does not exist." >&2
          exit 2
        fi

        RESTIC_ENV_VARS+=("RESTIC_REPOSITORY=$RESTIC_REPOSITORY");
        RESTIC_ENV_VARS+=("RCLONE_CONFIG_B2_TYPE=b2");
        RESTIC_ENV_VARS+=("RCLONE_CONFIG_B2_HARD_DELETE=true");
        readarray -t ENV_FILE_VARS < "$RESTIC_ENV_FILE";
        RESTIC_ENV_VARS+=("''${ENV_FILE_VARS[@]}");

        if [ "$DEBUG_MODE" = "true" ]; then
          echo "Env Vars:" >&2
          printf '  %s\n' "''${RESTIC_ENV_VARS[@]}" >&2
          echo "Args:" >&2
          printf '  %s\n' "''${RESTIC_ARGS[@]}" >&2
        fi

        env "''${RESTIC_ENV_VARS[@]}" ${restic}/bin/restic "''${RESTIC_ARGS[@]}"
      '';
  in {
    home.packages = [backup-command];
  };
}
