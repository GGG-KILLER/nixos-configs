{ ... }:
{
  services.redis.servers.workvm = {
    enable = true;

    bind = "192.168.122.1";
    port = 6379;

    settings = {
      # enable no loads refused mode
      protected-mode = "no";
    };
  };
}
