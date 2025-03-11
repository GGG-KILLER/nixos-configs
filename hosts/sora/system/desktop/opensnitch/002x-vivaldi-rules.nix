{
  lib,
  pkgs,
  config,
  ...
}:
let
  replaceStringsEnsuringReplaced =
    needles: replacements: haystack:
    let
      result = lib.replaceStrings needles replacements haystack;
    in
    assert result != haystack;
    result;
  vivaldi = (
    (pkgs.vivaldi.overrideAttrs (oldAttrs: {
      buildPhase =
        replaceStringsEnsuringReplaced
          [ "for f in libGLESv2.so libqt5_shim.so ; do" ]
          [ "for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do" ]
          oldAttrs.buildPhase;
    })).override
      {
        qt5 = pkgs.qt6;
        commandLineArgs = [ "--ozone-platform=wayland" ];
        # The following two are just my preference, feel free to leave them out
        proprietaryCodecs = true;
        enableWidevine = true;
      }
  );

  base = 20;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{

  services.opensnitch.rules."${getSeq 0}-vivaldi-reject-telemetry" = {
    name = "${getSeq 0}-vivaldi-reject-telemetry";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "reject";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
        {
          type = "regexp";
          sensitive = false;
          operand = "dest.host";
          data = "^(${lib.concatStringsSep "|" (lib.map lib.escapeRegex [ "stream.vivaldi.com" ])})$";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 1}-vivaldi-allow-http" = {
    name = "${getSeq 1}-vivaldi-allow-http";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "80";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 2}-vivaldi-allow-https" = {
    name = "${getSeq 2}-vivaldi-allow-https";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
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
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 3}-vivaldi-allow-ssdp" = {
    name = "${getSeq 3}-vivaldi-allow-ssdp";
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
          data = "1900";
        }
        {
          type = "simple";
          operand = "dest.ip";
          data = "239.255.255.250";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 4}-vivaldi-allow-mdns" = {
    name = "${getSeq 4}-vivaldi-allow-mdns";
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
          data = "5353";
        }
        {
          type = "simple";
          operand = "dest.ip";
          data = "224.0.0.251";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 5}-vivaldi-allow-whatsapp-web" = {
    name = "${getSeq 5}-vivaldi-allow-whatsapp-web";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "5222";
        }
        {
          type = "simple";
          operand = "dest.host";
          data = "web.whatsapp.com";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin vivaldi}/opt/vivaldi/vivaldi-bin";
        }
      ];
    };
  };
}
