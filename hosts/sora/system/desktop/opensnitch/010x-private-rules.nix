{
  system,
  lib,
  self,
  config,
  ...
}:
let
  base = 100;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules."${getSeq 0}-kemono-allow-network" = {
    name = "${getSeq 0}-kemono-allow-network";
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
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin self.packages.${system}.kemono-dl}/lib/kemono-dl/kemono-dl";
        }
        {
          type = "regexp";
          operand = "dest.host";
          data = "^(${
            lib.concatStringsSep "|" (
              map lib.escapeRegex [
                "n1.coomer.su"
                "n2.coomer.su"
                "n3.coomer.su"
                "n4.coomer.su"
                "n1.kemono.su"
                "n2.kemono.su"
                "n3.kemono.su"
                "n4.kemono.su"
              ]
            )
          })$";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 1}-mullvad-allow-network-idk" = {
    name = "${getSeq 1}-mullvad-allow-network-idk";
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
          operand = "dest.ip";
          data = "45.83.223.196";
        }
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = "0";
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin config.services.mullvad-vpn.package}/bin/mullvad-daemon";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 2}-mullvad-allow-network-dnsoverhttp" = {
    name = "${getSeq 2}-mullvad-allow-network-dnsoverhttp";
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
          operand = "dest.ip";
          data = "8.8.4.4";
        }
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = "0";
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin config.services.mullvad-vpn.package}/bin/mullvad-daemon";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 3}-mullvad-allow-connect-check" = {
    name = "${getSeq 3}-mullvad-allow-connect-check";
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
          operand = "dest.host";
          data = "ipv4.am.i.mullvad.net";
        }
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = "0";
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin config.services.mullvad-vpn.package}/bin/mullvad-daemon";
        }
      ];
    };
  };
}
