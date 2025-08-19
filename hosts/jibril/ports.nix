# Port Registry
#
# Here basically are registered all ports used across this server
# including containers and ports only used internally.
{ config, lib, ... }:
{
  options.jibril.ports = lib.mkOption {
    internal = true;
    description = "Ports of services used in this server.";
    type = with lib.types; attrsOf port;
    readOnly = true;
  };
  options.jibril.dynamic-ports = lib.mkOption {
    internal = true;
    description = "Ports of services used in this server.";
    type = with lib.types; listOf singleLineStr;
  };

  config.jibril.ports = {
    # NOTE: Cannot be a dynamic port since it has an external dependency.
    dns = 53;
    http = 80;
    https = 443;
    dns-over-tls = 853;

    # NOTE: Cannot be a dynamic port since it has an external dependency.
    postgres = 5432;

    # Fixed ports: 0-1024,60000-655

    # RESERVED: Games (60000-60999)

    # NOTE: Needs to be a fixed port since we can't statically configure this through nix
    mqtt = 61001;

    # NOTE: Cannot be a dynamic port since it has an external dependency.
    wireguard = 61235;
  }
  // (
    let
      inherit (lib)
        listToAttrs
        genList
        elemAt
        length
        ;
    in
    listToAttrs (
      genList (index: {
        name = elemAt config.jibril.dynamic-ports index;
        value = 1024 + index;
      }) (length config.jibril.dynamic-ports)
    )
  );
}
