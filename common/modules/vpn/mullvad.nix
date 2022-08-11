# Thanks to @myaats for providing this to me
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  mullvadConfig = config.modules.vpn.mullvad;
  TALPID_NET_CLS_MOUNT_DIR = "/tmp/net_cls";
in {
  options.modules.vpn = {
    mullvad = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable the mullvad vpn client";
      };
      alwaysRequireVpn = mkOption {
        type = types.bool;
        default = false;
        description = "block the internet when not connected to the vpn";
      };
      autoConnect = mkOption {
        type = types.bool;
        default = false;
        description = "auto connect mullvad on startup";
      };
      emergencyOnFail = mkOption {
        type = types.bool;
        default = false;
        description = "go into emergency on start fail";
      };
      allowLan = mkOption {
        type = types.bool;
        default = false;
        description = "allow lan connections";
      };
      tunnelProtocol = mkOption {
        type = types.enum ["wireguard" "openvpn"];
        default = "wireguard";
        description = "tunnel protocol";
      };
      location = mkOption {
        type = types.nullOr (types.enum ["de" "no" "br"]);
        default = "br";
        description = "default location";
      };
      nameservers = mkOption {
        type = with types; listOf str;
        default = [];
        description = "nameservers to use";
      };
      setCheckReversePath = mkOption {
        type = types.bool;
        default = true;
        description = "whether to set the networking.firewall.checkReversePath setting";
      };
    };
  };

  config = mkIf mullvadConfig.enable {
    boot.kernelModules = ["tun"];

    # mullvad-daemon writes to /etc/iproute2/rt_tables
    networking.iproute2.enable = true;

    # See https://github.com/NixOS/nixpkgs/issues/113589
    networking.firewall.checkReversePath = mkIf mullvadConfig.setCheckReversePath "loose";

    environment.systemPackages = with pkgs; [
      mullvad-vpn
    ];

    systemd.tmpfiles.rules = [
      "d '${TALPID_NET_CLS_MOUNT_DIR}' 0755 root root"
    ];

    systemd.services.mullvad = {
      description = "Mullvad VPN daemon";
      wantedBy = ["multi-user.target"];
      wants = ["network.target"];
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];
      path = [
        pkgs.iproute2
        # Needed for ping
        "/run/wrappers"
      ];
      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      environment = {
        inherit TALPID_NET_CLS_MOUNT_DIR;
      };
      serviceConfig = let
        mullvad = "${pkgs.mullvad-vpn}/bin/mullvad";
      in
        {
          ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad-daemon -v --disable-stdout-timestamps";
          ExecStartPost = pkgs.writeShellScript "mullvad_setup" ''
            ${mullvad} lan set ${
              if mullvadConfig.allowLan
              then "allow"
              else "block"
            }

            ${mullvad} relay set tunnel-protocol ${mullvadConfig.tunnelProtocol}
            ${optionalString (mullvadConfig.location != null) "${mullvad} relay set location ${mullvadConfig.location}"}
            ${optionalString mullvadConfig.autoConnect "${mullvad} connect"}
            ${mullvad} always-require-vpn set ${
              if mullvadConfig.alwaysRequireVpn
              then "on"
              else "off"
            }
            ${mullvad} auto-connect set ${
              if mullvadConfig.autoConnect
              then "on"
              else "off"
            }
            ${optionalString (mullvadConfig.nameservers != []) "${mullvad} dns set custom ${concatStringsSep " " mullvadConfig.nameservers}"}

            ${optionalString (config.my.secrets.vpn.mullvad != null) "${mullvad} account login \"${builtins.replaceStrings [" "] [""] config.my.secrets.vpn.mullvad.account}\""}
          '';
          Restart = "always";
          RestartSec = "5s";
        }
        // (
          if mullvadConfig.emergencyOnFail
          then {
            OnFailure = "emergency.target";
            OnFailureJobMode = "replace-irreversibly";
          }
          else {}
        );
    };
  };
}
