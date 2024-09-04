{ ... }:
{
  services.redis.servers.workvm = {
    enable = true;

    bind = "0.0.0.0";
    port = 6379;

    settings = {
      # enable no loads refused mode
      protected-mode = "no";
    };
  };
}
