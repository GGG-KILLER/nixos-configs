{ pkgs, ... }:
let
  mkPlugin =
    {
      name,
      version,
      hash,
      url ? "https://downloads.wordpress.org/plugin/${name}.${version}.zip",
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name version;
      src = pkgs.fetchzip {
        inherit url hash;
      };
      installPhase = "mkdir -p $out; cp -R * $out/";
    };
  disable-comments = mkPlugin {
    name = "disable-comments";
    version = "2.5.2";
    hash = "sha256-G/psFcoiLeGPCCqJi6J9+1/rsUmzUKNTnu5RmBH3y7U=";
  };
  disable-everything = mkPlugin {
    name = "disable-everything";
    version = "0.4.1";
    hash = "sha256-224ef9kTP/3dd3O1Ec+p75vZ+0AJWp62rbDvYw02VmA=";
  };
  two-factor = mkPlugin {
    name = "two-factor";
    version = "0.13.0";
    hash = "sha256-2CtIYOL9Hh992xsOn0wgI/VJzrW+5oefclqMx/D6eHA=";
  };
  # TODO: Enable?
  # dessky-cache = mkPlugin {
  #   name = "dessky-cache";
  #   version = "1.1";
  #   url = "https://downloads.wordpress.org/plugin/dessky-cache.zip";
  #   hash = "sha256-X9JefiNFOLoHa2RZBuKmGAj8nF8lJ0QgYT5kaV5pidQ=";
  # };
in
{
  services.wordpress.webserver = "nginx";
  services.wordpress.sites."40b8d0.4skins.studio" = {
    themes = {
      inherit (pkgs.wordpressPackages.themes) twentytwentyfive;
    };
    plugins = {
      inherit (pkgs.wordpressPackages.plugins)
        disable-xml-rpc
        ;
      inherit
        disable-comments
        disable-everything
        two-factor
        ;
    };

    settings = {
      WP_DEFAULT_THEME = "twentytwentyfive";
      WP_SITEURL = "https://40b8d0.4skins.studio";
      WP_HOME = "https://40b8d0.4skins.studio";

      WP_DEBUG = false;
      WP_DEBUG_DISPLAY = false;

      DISALLOW_FILE_MODS = true; # Themes and plugins are readonly
      FORCE_SSL_ADMIN = true;

      WP_HTTP_BLOCK_EXTERNAL = true;
      WP_ACCESSIBLE_HOSTS = "";

      AUTOMATIC_UPDATER_DISABLED = true;
      WP_AUTO_UPDATE_CORE = false;

      IMAGE_EDIT_OVERWRITE = true;
    };

    extraConfig = ''
      $_SERVER['HTTPS'] = 'on'; // SSL by Nginx + CF
    '';
  };

  modules.services.nginx.virtualHosts."40b8d0.4skins.studio" = {
    ssl = true;

    # Extra hardening settings.
    locations = {
      "~* /wp-content/.*\\.php$" = {
        priority = 900;
        extraConfig = "deny all;";
      };
      "~* /wp-includes/.*\\.php$" = {
        priority = 900;
        extraConfig = "deny all;";
      };
    };
  };

  security.acme.certs."40b8d0.4skins.studio" = {
    email = "gggkiller2@gmail.com";
    server = "https://acme-v02.api.letsencrypt.org/directory";
    renewInterval = "daily";
  };

  services.cloudflared.tunnels."3c1b8ea8-a43d-4a97-872c-37752de30b3f".ingress."40b8d0.4skins.studio" =
    "https://127.0.0.1";
}
