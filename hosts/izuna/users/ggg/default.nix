{ pkgs, ... }:
{
  imports = [ ./commands ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      tmux
    ];
  };
}
