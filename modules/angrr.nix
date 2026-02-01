{ lib, config, ... }:
{
  options.ggg.angrr = {
    enable = lib.mkEnableOption "pre-configured angrr";
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "03:00";
    };
  };

  config = lib.mkIf config.ggg.angrr.enable {
    services.angrr = {
      enable = true;
      timer.enable = true;
      timer.dates = config.ggg.angrr.schedule;
      settings = {
        temporary-root-policies = {
          direnv = {
            path-regex = "/\\.direnv/";
            period = "14d";
          };
          result = {
            path-regex = "/result[^/]*$";
            period = "3d";
          };
        };
        profile-policies = {
          system = {
            profile-paths = [ "/nix/var/nix/profiles/system" ];
            keep-since = "7d";
            keep-latest-n = 2;
            keep-booted-system = true;
            keep-current-system = true;
          };
          user = {
            profile-paths = [
              # `~` at the beginning will be expanded to the home directory of each discovered user
              "~/.local/state/nix/profiles/profile"
              "/nix/var/nix/profiles/per-user/root/profile"
            ];
            keep-since = "1d";
            keep-latest-n = 1;
          };
        };
      };
    };
  };
}
