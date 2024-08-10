{ config, pkgs, ... }:
{
  imports = [ ./nixpkgs.nix ];

  modules.services.nginx.virtualHosts."nixpkgs.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://unix:/run/pr-tracker.sock:/";
      extraConfig = ''
        proxy_http_version 1.1;
      '';
    };
  };

  systemd.services.pr-tracker = {
    requires = [ "pr-tracker.socket" ];
    path = [ pkgs.gitMinimal ];
    serviceConfig = {
      DynamicUser = true;
      SupplementaryGroups = "nixpkgs";
      UMask = "0002";

      ReadWritePaths = "/var/lib/git/nixpkgs.git";
      StandardInput = "file:${config.age.secrets.pr-tracker-token.path}";

      ExecStart = "${pkgs.pr-tracker}/bin/pr-tracker --path /var/lib/git/nixpkgs.git --remote origin --user-agent 'pr-tracker (GGG-KILLER)' --source-url https://git.qyliss.net/pr-tracker";
    };
  };

  systemd.sockets.pr-tracker = {
    wantedBy = [ "sockets.target" ];
    before = [ "nginx.service" ];
    socketConfig.ListenStream = "/run/pr-tracker.sock";
  };
}
