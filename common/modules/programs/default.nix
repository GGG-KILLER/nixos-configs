{ lib, ... }:
{
  imports =
    let
      inherit (lib)
        flatten
        mapAttrsToList
        filterAttrs
        hasSuffix
        ;
      inherit (lib.path) append;

      listFiles =
        path:
        flatten (
          mapAttrsToList (
            name: type: if type == "regular" then append path name else listFiles (append path name)
          ) (filterAttrs (name: _: hasSuffix ".nix" name && name != "default.nix") (builtins.readDir path))
        );
    in
    listFiles ./.;
}
