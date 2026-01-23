{ pog }:
let
  inherit (pog) _;
in
pog.pog {
  name = "batwhich";
  argumentCompletion = "executables";
  script = ''
    exec ${_.bat} "$(${_.which} "$1")"
  '';
}
