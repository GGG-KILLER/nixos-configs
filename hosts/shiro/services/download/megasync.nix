{
  self,
  lib,
  system,
  ...
}: let
  inherit (lib) getExe;
in {
  systemd.services.megasync = {
    wantedBy = ["network-online.target"];
    script = getExe self.packages.${system}.mega-sync;
    environment = {
    };
  };
}
