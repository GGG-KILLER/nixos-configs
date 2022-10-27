{pkgs, ...}: {
  systemd.services.rustdesk = {
    description = "RustDesk";
    requires = ["network.target"];
    after = ["systemd-user-sessions.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
      PIDFile = "/var/run/rustdesk.pid";
      KillMode = "mixed";
      TimeoutStopSec = "30";
      User = "root";
      LimitNOFILE = "100000";
    };
  };
}
