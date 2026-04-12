{ lib, dotnetCorePackages }:
(
  with dotnetCorePackages;
  combinePackages [
    sdk_11_0-bin
    sdk_10_0-bin
    sdk_9_0-bin
    sdk_8_0-bin
  ]
).overrideAttrs
  (prev: {
    postInstall =
      prev.postInstall or ""
      + ''
        # Un-link things to avoid problems
        find "$out" -type l -exec sh -c 'PREV=$(realpath -- "$1") && echo "  $PREV -> $1" && rm -- "$1" && cp --archive --dereference --recursive -- "$PREV" "$1"' resolver {} \;

        # Fix dotnet not finding host/fxr
        rm "$out"/bin/dotnet
        ln -s "$out"/share/dotnet/dotnet "$out"/bin/dotnet
      ''
      + lib.optionalString (prev.src ? man) ''
        # Un-link things to avoid problems
        find "$man" -type l -exec sh -c 'PREV=$(realpath -- "$1") && echo "  $PREV -> $1" && rm -- "$1" && cp --archive --dereference --recursive -- "$PREV" "$1"' resolver {} \;
      '';
  })
