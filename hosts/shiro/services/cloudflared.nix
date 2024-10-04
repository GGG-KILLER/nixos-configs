{ config, ... }:
{
  services.cloudflared = {
    enable = true;

    tunnels."3c1b8ea8-a43d-4a97-872c-37752de30b3f" = {
      credentialsFile = config.age.secrets."cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json".path;
      default = "http_status:404";
      originRequest.noTLSVerify = true;
    };
  };
}
