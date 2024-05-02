let
  ggg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn";
  users = [ggg];

  sora = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6b2z/jMnPSYXSYYJ6NBY77m0bofpVceoArRzJHQ+Nc";
  shiro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyYTusgW/GPy8qYBaS4gq71MEGWEY+U+m7rSUzn/xc";
  vpn-proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXJsB3idnONLnk1X/Ga2V0HHCJhjqptMbvdZVJji3F/";
  f-ggg-dev = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ527bVSbg3fMxUIyMrXhmyo0A/motmI3SZY6sMLk7C0";
  systems = [sora shiro vpn-proxy f-ggg-dev];

  all = users ++ systems;
in {
  "foldingathome.xml.age".publicKeys = all;

  # Sora
  "sora/backup_password.age".publicKeys = [ggg sora];
  "sora/backup_envfile.age".publicKeys = [ggg sora];

  # Shiro
  "shiro/backup_password.age".publicKeys = [ggg sora shiro];
  "shiro/backup_envfile.age".publicKeys = [ggg sora shiro];
  "shiro/mnn-server.env.age".publicKeys = [ggg shiro];
  "shiro/valheim-server.env.age".publicKeys = [ggg shiro];
  "shiro/minio.env.age".publicKeys = [ggg shiro];
  "shiro/statping.env.age".publicKeys = [ggg shiro];
  "shiro/netprobe.env.age".publicKeys = [ggg shiro];

  # Shiro - Wireguard
  "shiro/wireguard/private_key.age".publicKeys = [ggg shiro];
  "shiro/wireguard/laptop_psk.age".publicKeys = [ggg shiro];
  "shiro/wireguard/phone_psk.age".publicKeys = [ggg shiro];
  "shiro/wireguard/coffee_psk.age".publicKeys = [ggg shiro];
  "shiro/wireguard/coffee2_psk.age".publicKeys = [ggg shiro];
  "shiro/wireguard/night_psk.age".publicKeys = [ggg shiro];

  # Shiro - Step CA
  "shiro/stepca/intermediate_ca_key.age".publicKeys = [ggg shiro];
  "shiro/stepca/keys_password.age".publicKeys = [ggg shiro];

  # Shiro - VPN Gateway
  "shiro/vpn-gateway/mullvad_private_key.age".publicKeys = [ggg shiro];

  # Shiro - PostgreSQL
  "shiro/pgsql/dev_pass.age".publicKeys = [ggg shiro];
  "shiro/pgsql/prd_pass.age".publicKeys = [ggg shiro];

  # Shiro - Pterodactyl
  "shiro/pterodactyl/db.env.age".publicKeys = [ggg shiro];
  "shiro/pterodactyl/panel.env.age".publicKeys = [ggg shiro];

  # Shiro - Authentik
  "shiro/authentik/authentik.env.age".publicKeys = [ggg shiro];
  "shiro/authentik/ldap-outpost.env.age".publicKeys = [ggg shiro];
  "shiro/authentik/radius-outpost.env.age".publicKeys = [ggg shiro];

  # VPN Proxy
  "vpn-proxy/wireguard/private_key.age".publicKeys = [ggg vpn-proxy];
  "vpn-proxy/wireguard/wing_psk.age".publicKeys = [ggg vpn-proxy];
  "vpn-proxy/wireguard/ggg_psk.age".publicKeys = [ggg vpn-proxy];
  "vpn-proxy/wireguard/spar_ios_psk.age".publicKeys = [ggg vpn-proxy];
  "vpn-proxy/wireguard/spar_pc1_psk.age".publicKeys = [ggg vpn-proxy];
}
