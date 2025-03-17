{ ... }:
{
  imports = [
    ./000x-base-rules.nix
    ./001x-block-rules.nix
    ./002x-vivaldi-rules.nix
    ./003x-backup-rules.nix
    ./004x-vscode-rules.nix
    ./005x-nix-rules.nix
    ./010x-private-rules.nix
  ];

  services.opensnitch.enable = false; # TODO: Enable when I have patience to deal with it.
  services.opensnitch.settings.ProcMonitorMethod = "ebpf";
  services.opensnitch.settings.Firewall = "iptables";
  services.opensnitch.settings.LogLevel = 0;
}
