{ pkgs, ... }:
{
  home-manager.users.ggg = {
    home.packages = [
      (pkgs.pog.pog {
        name = "gallery-dl-extract";
        description = "Extracts the provided archive into a directory named after the archive (without extension)";
        runtimeInputs = [
          pkgs.coreutils
          (pkgs.ouch.override {
            enableUnfree = true;
          })
        ];
        arguments = [
          {
            name = "OUTPUT_PATH";
            required = true;
          }
          {
            name = "SOURCE_ARCHIVE";
            required = true;
          }
        ];
        strict = true;
        script = ''
          shopt -s nullglob globstar

          if [[ $# -lt 2 ]]; then
            die "usage: $0 OUTPUT_PATH SOURCE_ARCHIVE"
          fi

          OUTPUT_PATH="$(realpath "$1")"
          SOURCE_ARCHIVE="$2"

          # Remove archive extension(s) to form base name
          fname=$(basename -- "$SOURCE_ARCHIVE")
          fname_lc=$(printf '%s' "$fname" | tr '[:upper:]' '[:lower:]')
          case "$fname_lc" in # compare using lowercase to prevent issues
            *.tar.gz|*.tar.bz2|*.tar.xz|*.tar.zst|*.tar.lz|*.tar.lzo|*.tar.lrz|*.tar.z)
              base="''${fname%.*}"
              base="''${base%.*}"
              ;;
            *)
              base="''${fname%.*}"
              ;;
          esac

          # Safety: base must not be empty
          if [[ -z "$base" || "$base" == "." || "$base" == ".." || "$base" == */* ]]; then
            die "error: empty archive base name"
          fi

          # Safety: must not collapse to OUTPUT_PATH itself
          OUTPUT_DIR="$OUTPUT_PATH/''${base}"
          if [[ "$OUTPUT_DIR" == "$OUTPUT_PATH" || "$OUTPUT_DIR" == "$OUTPUT_PATH/" ]]; then
            die "error: refusing to extract into output root"
          fi

          # Prepare an empty output directory
          rm -rf -- "$OUTPUT_DIR" >/dev/null ||:
          mkdir -p -- "$OUTPUT_DIR"

          # Extract using ouch while cleaning up on failure
          if ! ouch decompress --yes --dir "$OUTPUT_DIR" --remove "$SOURCE_ARCHIVE"; then
            if ! rm -rf -- "$OUTPUT_DIR"; then
              die "error: failed to decompress $SOURCE_ARCHIVE **AND** cleanup of $OUTPUT_DIR failed"
            fi
            die "error: failed to decompress $SOURCE_ARCHIVE"
          fi

          # Remove sketch/WIP by filename
          find "$OUTPUT_DIR" -type f \
            \( -iname '*sketch*' -o -iname '*draft*' -o -iname '*wip*' \) \
            -delete

          # Remove all files that are NOT in the allowed image/video extension list
          find "$OUTPUT_DIR" -type f \
            ! -iregex '.*\.\(jpg\|jpeg\|png\|gif\|bmp\|svg\|webp\|avif\|heic\|heif\|ico\|flv\|ogv\|avi\|mp4\|mpg\|mpeg\|3gp\|mkv\|webm\|vob\|wmv\|m4v\|mov\)$' \
            -delete

          # Remove empty directories
          find "$OUTPUT_DIR" -type d -empty -delete

          # Move files to the right places
          PICTURES="$(realpath "$OUTPUT_PATH/../Pictures/")"
          VIDEO="$(realpath "$OUTPUT_PATH/../Video/")"
          for file in "$OUTPUT_DIR"/**/*; do
              file_rel="$(realpath --relative-to="$OUTPUT_PATH" -- "$file")"
              case "$file" in
                  *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.svg|*.webp|*.avif|*.heic|*.heif|*.ico|*.psd)
                      mv -v -- "$file" "$PICTURES/''${file_rel//\//_}"
                      ;;
                  *.flv|*.ogv|*.avi|*.mp4|*.mpg|*.mpeg|*.3gp|*.mkv|*.webm|*.vob|*.wmv|*.m4v|*.mov)
                      mv -v -- "$file" "$VIDEO/''${file_rel//\//_}"
                      ;;
              esac
          done
          rm -r "$OUTPUT_DIR"
        '';
      })
    ];
  };
}
