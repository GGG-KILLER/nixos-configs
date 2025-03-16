{
  lib,
  pkgs,
  config,
  ...
}:
let
  base = 50;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules =
    {
      "${getSeq 0}-nix-allow-network" = {
        name = "${getSeq 0}-nix-allow-network";
        created = "1970-01-01T00:00:00Z";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              data = "${lib.getBin config.nix.package}/bin/nix";
            }
            {
              type = "simple";
              operand = "dest.port";
              data = "443";
            }
          ];
        };
      };
    }
    //

    # Just outright allow nixbld users to access these network services with any program.
    # It'd be too much of a pain to list every single program.
    lib.listToAttrs (
      builtins.genList (
        x:
        let
          user = "nixbld${toString (1 + x)}";
        in
        {
          name = "${getSeq (1 + x)}-nix-allow-${user}-network";
          value = {
            name = "${getSeq (1 + x)}-nix-allow-${user}-network";
            created = "1970-01-01T00:00:00Z";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "list";
              operand = "list";
              list = [
                {
                  type = "simple";
                  operand = "user.id";
                  data = config.users.users.${user}.uid;
                }
                {
                  type = "simple";
                  operand = "dest.port";
                  data = "443";
                }
              ];
            };
          };
        }
      ) config.nix.nrBuildUsers
    );
}
