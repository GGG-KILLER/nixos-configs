{
  self,
  system,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.jdownloader = rec {
    imageFile = self.packages.${system}.docker-images."jlesage/jdownloader-2:latest";
    image = imageFile.destNameTag;
    ports = [ "${toString config.shiro.ports.jdownloader}:5800" ];
    volumes = [
      "/var/lib/jdownloader2:/config"
      "/storage/animu:/mnt/animu"
      "/storage/h/Playlists:/output/h/Playlists"
      "/storage/h/Others:/output/h/Others"
    ];
    environment = {
      USER_ID = toString config.users.users.downloader.uid;
      GROUP_ID = toString config.users.groups.data-members.gid;
      TZ = config.time.timeZone;
      # When set to 1, the application is automatically restarted if it crashes or terminates.
      KEEP_APP_RUNNING = "1";
      # Resolution
      DISPLAY_WIDTH = "1280";
      DISPLAY_HEIGHT = "720";
      # When set to 1, enables the web notification service, allowing the browser to display desktop notifications from the application.
      WEB_NOTIFICATION = "1";
      # Port used by the VNC server to serve the application's GUI. NOTE: A value of -1 disables VNC access to the application's GUI.
      VNC_LISTENING_PORT = "-1";
      # When set to 1, installs the open-source font WenQuanYi Zen Hei, supporting a wide range of Chinese/Japanese/Korean characters.
      ENABLE_CJK_FONT = "1";
      # When set to 1, uses an encrypted connection to access the application's GUI (via web browser or VNC client).
      SECURE_CONNECTION = "1";
      # Maximum amount of memory JDownloader is allowed to use. One of the following memory unit (case insensitive) should be added as a suffix to the size: G, M or K. When this variable is not set, the limit is automatically calculated based on the amount of RAM of the system.
      JDOWNLOADER_MAX_MEM = "1G";
    };
    extraOptions = [
      "--dns=${config.home.addrs.router}"
      "--ipc=none"
    ];
  };

  security.acme.certs."jd.${config.networking.fqdn}" = {
    email = "jd@${config.networking.fqdn}";
    postRun = ''
      cp fullchain.pem /var/lib/jdownloader2/certs/web-fullchain.pem
      cp key.pem /var/lib/jdownloader2/certs/web-privkey.pem

      chown downloader:data-members /var/lib/jdownloader2/certs/web-{fullchain,privkey}.pem
      chmod a=r,u+w /var/lib/jdownloader2/certs/web-fullchain.pem
      chmod a=,u=r /var/lib/jdownloader2/certs/web-privkey.pem
    '';
  };

  modules.services.nginx.virtualHosts."jd.${config.networking.fqdn}" = {
    ssl = true;

    locations."/" = {
      proxyPass = "https://127.0.0.1:${toString config.shiro.ports.jdownloader}/";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
      '';
    };
  };
}
