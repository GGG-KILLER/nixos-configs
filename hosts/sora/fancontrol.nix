{...}: {
  hardware.fancontrol = {
    enable = true;
    config = builtins.readFile ./fancontrol;
  };

  systemd.services.fancontrol-restart = {
    description = "Restart of fancontrol.service after suspend";
    after = ["hibernate.target" "suspend.target"];
    wantedBy = ["hibernate.target" "suspend.target"];

    serviceConfig = {
      ExecStart = "systemctl restart fancontrol.service";

      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
