{ ... }:
{
  ggg.caddy.enable = true;
  # Jellyfin serves plain HTTP; don't force-redirect to HTTPS.
  ggg.caddy.http-redirect = false;
}
