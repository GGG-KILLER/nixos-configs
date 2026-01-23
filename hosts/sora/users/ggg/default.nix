{ self, system, ... }:
{
  # Configurations left for ssh access usage (as a midpoint between steph and shiro)
  home-manager.users.ggg = {
    home.packages = with self.packages.${system}; [
      dl-twitch-stream
      batwhich
    ];

    programs.tealdeer = {
      enable = true;
      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 72;
      };
    };
  };
}
