{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "openspeedtest";
    repo = "Speed-Test";
    rev = "704aec0e5deb54be4588dbebe6b7424216d5e146";
    hash = "sha256-SXwJScm8u6BZiEO3STqVDkecCr7XBSEmq9lR9c0ljeA=";
  };
in {
  modules.services.nginx.virtualHosts."speed.shiro.lan" = {
    ssl = true;

    root = src;
    extraConfig = ''
      # SSL cache
      ssl_session_cache shared:SpeedTestSSL:100m;
      ssl_session_timeout 1d;
      ssl_session_tickets on;

      client_max_body_size 35m;
      error_page 405 =200 $uri;

      # No logs.
      access_log off;
      log_not_found off;
      error_log /dev/null; #Disable this for Windows Nginx.

      # No compression.
      gzip off;
      zstd off;
      brotli off;

      fastcgi_read_timeout 999;
      server_tokens off;

      # Cache all files for SPEED
      open_file_cache max=200000 inactive=20s;
      open_file_cache_valid 30s;
      open_file_cache_min_uses 2;
      open_file_cache_errors off;

    '';

    locations."/" = {
      extraConfig = ''
        add_header 'Access-Control-Allow-Credentials' "true";
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Origin' "*" always;
        add_header Cache-Control 'no-store, no-cache, max-age=0, no-transform';
        add_header Last-Modified $date_gmt;
        if_modified_since off;
        expires off;
        etag off;

        if ($request_method = OPTIONS) {
            return 200;
        }
      '';
    };

    # Static File Caching
    locations."~* ^.+\.(?:css|cur|js|jpe?g|gif|htc|ico|png|html|xml|otf|ttf|eot|woff|woff2|svg)$" = {
      extraConfig = ''
        expires 365d;
        add_header Cache-Control public;
        add_header Vary Accept-Encoding;
        tcp_nodelay off;

        # Cache everything in memory.
        open_file_cache max=3000 inactive=120s;
        open_file_cache_valid 45s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;

        # Enable Cache
        gzip off;
        zstd off;
        brotli off;
      '';
    };

    # HTTP 2 and 3 fixes as they don't wait for body to return.
    locations."= /upload" = {
      proxyPass = "http://speed.shiro.lan/dev-null";
    };
    locations."= /dev-null" = {
      return = 200;
    };
  };
}
