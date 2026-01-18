{ ... }:
{
  home-manager.users.ggg =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      associateApp = app: mimes: lib.genAttrs mimes (_: app);
      dolphinAssociations = associateApp "org.kde.dolphin.desktop" [
        "inode/directory"
      ];
      browserAssociations = associateApp "vivaldi-stable.desktop" [
        "application/atom+xml"
        "application/pdf"
        "application/rdf+xml"
        "application/rss+xml"
        "application/xhtml_xml"
        "application/xhtml+xml"
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/mailto"
        "x-scheme-handler/tel"
      ];
      vscodeAssociations = associateApp "code.desktop" [
        "application/javascript"
        "application/json"
        "application/octet-stream"
        "application/ovf"
        "application/toml"
        "application/x-docbook+xml"
        "application/x-shellscript"
        "application/x-wine-extension-ini"
        "application/x-yaml"
        "application/xml"
        "text/markdown"
        "text/plain"
        "text/x-cmake"
        "text/x-csharp"
        "text/x-log"
        "text/x-matlab"
      ];
      readerAssociations = associateApp "org.kde.okular.desktop" [
        # PDF moved to browser since it handles it better somehow
        "application/vnd.comicbook+zip"
        "application/vnd.kde.okular-archive"
      ];
      imageAssociations = associateApp "org.kde.gwenview.desktop" [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heic"
        "image/heif"
        "image/jpeg"
        "image/jpg"
        "image/jxl"
        "image/pjpeg"
        "image/png"
        "image/svg+xml-compressed"
        "image/svg+xml"
        "image/tiff"
        "image/vnd-ms.dds"
        "image/vnd.microsoft.icon"
        "image/vnd.radiance"
        "image/vnd.wap.wbmp"
        "image/webp"
        "image/x-bmp"
        "image/x-dds"
        "image/x-eps"
        "image/x-exr"
        "image/x-gray"
        "image/x-icb"
        "image/x-icns"
        "image/x-ico"
        "image/x-pcx"
        "image/x-png"
        "image/x-portable-anymap"
        "image/x-portable-bitmap"
        "image/x-portable-graymap"
        "image/x-portable-pixmap"
        "image/x-psd"
        "image/x-qoi"
        "image/x-tga"
        "image/x-webp"
        "image/x-xbitmap"
        "image/x-xcf"
        "image/x-xpixmap"
      ];
      videoAssociations = associateApp "mpv.desktop" [
        "application/mxf"
        "application/ogg"
        "application/sdp"
        "application/smil"
        "application/streamingmedia"
        "application/vnd.apple.mpegurl"
        "application/vnd.ms-asf"
        "application/vnd.rn-realmedia-vbr"
        "application/vnd.rn-realmedia"
        "application/x-cue"
        "application/x-extension-m4a"
        "application/x-extension-mp4"
        "application/x-matroska"
        "application/x-mpegurl"
        "application/x-ogg"
        "application/x-ogm-audio"
        "application/x-ogm-video"
        "application/x-ogm"
        "application/x-shorten"
        "application/x-smil"
        "application/x-streamingmedia"
        "audio/3gpp"
        "audio/3gpp2"
        "audio/aac"
        "audio/ac3"
        "audio/aiff"
        "audio/amr-wb"
        "audio/AMR"
        "audio/dv"
        "audio/eac3"
        "audio/flac"
        "audio/m3u"
        "audio/m4a"
        "audio/mp1"
        "audio/mp2"
        "audio/mp3"
        "audio/mp4"
        "audio/mpeg"
        "audio/mpeg2"
        "audio/mpeg3"
        "audio/mpegurl"
        "audio/mpg"
        "audio/musepack"
        "audio/ogg"
        "audio/opus"
        "audio/rn-mpeg"
        "audio/scpls"
        "audio/vnd.dolby.heaac.1"
        "audio/vnd.dolby.heaac.2"
        "audio/vnd.dts.hd"
        "audio/vnd.dts"
        "audio/vnd.rn-realaudio"
        "audio/vnd.wave"
        "audio/vorbis"
        "audio/wav"
        "audio/webm"
        "audio/x-aac"
        "audio/x-adpcm"
        "audio/x-aiff"
        "audio/x-ape"
        "audio/x-m4a"
        "audio/x-matroska"
        "audio/x-mp1"
        "audio/x-mp2"
        "audio/x-mp3"
        "audio/x-mpegurl"
        "audio/x-mpg"
        "audio/x-ms-asf"
        "audio/x-ms-wma"
        "audio/x-musepack"
        "audio/x-pls"
        "audio/x-pn-au"
        "audio/x-pn-realaudio"
        "audio/x-pn-wav"
        "audio/x-pn-windows-pcm"
        "audio/x-realaudio"
        "audio/x-scpls"
        "audio/x-shorten"
        "audio/x-tta"
        "audio/x-vorbis"
        "audio/x-vorbis+ogg"
        "audio/x-wav"
        "audio/x-wavpack"
        "video/3gp"
        "video/3gpp"
        "video/3gpp2"
        "video/avi"
        "video/divx"
        "video/dv"
        "video/fli"
        "video/flv"
        "video/mkv"
        "video/mp2t"
        "video/mp4"
        "video/mp4v-es"
        "video/mpeg"
        "video/msvideo"
        "video/ogg"
        "video/quicktime"
        "video/vnd.avi"
        "video/vnd.divx"
        "video/vnd.mpegurl"
        "video/vnd.rn-realvideo"
        "video/webm"
        "video/x-avi"
        "video/x-flc"
        "video/x-flic"
        "video/x-flv"
        "video/x-m4v"
        "video/x-matroska"
        "video/x-mpeg2"
        "video/x-mpeg3"
        "video/x-ms-afs"
        "video/x-ms-asf"
        "video/x-ms-wmv"
        "video/x-ms-wmx"
        "video/x-ms-wvxvideo"
        "video/x-msvideo"
        "video/x-ogm"
        "video/x-ogm+ogg"
        "video/x-theora"
        "video/x-theora+ogg"
      ];
      archiveAssociations = associateApp "org.kde.ark.desktop" [
        "application/arj"
        "application/gzip"
        "application/vnd.debian.binary-package"
        "application/vnd.efi.iso"
        "application/vnd.ms-cab-compressed"
        "application/vnd.rar"
        "application/x-7z-compressed"
        "application/x-archive"
        "application/x-arj"
        "application/x-bcpio"
        "application/x-bzip-compressed-tar"
        "application/x-bzip"
        "application/x-bzip2-compressed-tar"
        "application/x-bzip2"
        "application/x-cd-image"
        "application/x-compress"
        "application/x-compressed-tar"
        "application/x-cpio-compressed"
        "application/x-cpio"
        "application/x-deb"
        "application/x-iso9660-appimage"
        "application/x-java-archive"
        "application/x-lha"
        "application/x-lrzip-compressed-tar"
        "application/x-lrzip"
        "application/x-lz4-compressed-tar"
        "application/x-lz4"
        "application/x-lzip-compressed-tar"
        "application/x-lzip"
        "application/x-lzma-compressed-tar"
        "application/x-lzma"
        "application/x-lzop"
        "application/x-rar"
        "application/x-rpm"
        "application/x-source-rpm"
        "application/x-stuffit"
        "application/x-sv4cpio"
        "application/x-sv4crc"
        "application/x-tar"
        "application/x-tarz"
        "application/x-tzo"
        "application/x-xar"
        "application/x-xz-compressed-tar"
        "application/x-xz"
        "application/x-zstd-compressed-tar"
        "application/zip"
        "application/zlib"
        "application/zstd"
      ];
      miscAssociations = { };
      defaultAssociations =
        dolphinAssociations
        // browserAssociations
        // vscodeAssociations
        // readerAssociations
        // imageAssociations
        // videoAssociations
        // archiveAssociations
        // miscAssociations;

      addedAssociations = defaultAssociations // {
        "inode/directory" = [
          "org.kde.dolphin.desktop" # duplicated here because we override it with the merge operator
          "code.desktop"
          "mpv.desktop"
        ];
      };

      mkIniValue =
        v:
        let
          default = lib.generators.mkValueStringDefault { };
        in
        if lib.isList v then lib.concatStringsSep ";" (lib.map default v) else default v;

      iniFile = pkgs.writeText "default-mimeapps.list" (
        lib.generators.toINI
          {
            mkKeyValue = lib.generators.mkKeyValueDefault {
              mkValueString = mkIniValue;
            } "=";
          }
          {
            "Added Associations" = addedAssociations;
            "Default Applications" = defaultAssociations;
          }
      );
      initool = lib.getExe pkgs.initool;
    in
    {
      home.activation.update-mimeapps-list = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        MIMEAPPS=~/.config/mimeapps.list
        if [[ -f $MIMEAPPS ]]; then
          (
            set -o pipefail
            MIMEAPPS_CONTENT=$(cat $MIMEAPPS \
              | ${
                lib.concatStringsSep " \\\n      | " (
                  lib.flatten (
                    lib.mapAttrsToList (
                      mime: app:
                      let
                        args = lib.escapeShellArgs [
                          (mkIniValue mime)
                          (mkIniValue app)
                        ];
                      in
                      [
                        "${initool} set - 'Added Associations' ${args}"
                      ]
                    ) addedAssociations
                  )
                )
              } \
              | ${
                lib.concatStringsSep " \\\n      | " (
                  lib.flatten (
                    lib.mapAttrsToList (
                      mime: app:
                      let
                        args = lib.escapeShellArgs [
                          (mkIniValue mime)
                          (mkIniValue app)
                        ];
                      in
                      [
                        "${initool} set - 'Default Applications' ${args}"
                      ]
                    ) defaultAssociations
                  )
                )
              })
            [[ ! -v DRY_RUN ]] && printf '%s' "$MIMEAPPS_CONTENT" > "$MIMEAPPS"
            unset MIMEAPPS_CONTENT
          )
        else
          run cp ${toString iniFile} $MIMEAPPS
          run chmod a=,u=rw $MIMEAPPS
        fi
        unset MIMEAPPS
      '';
    };
}
