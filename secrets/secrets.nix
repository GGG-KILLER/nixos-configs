let
  ggg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn";
  users = [ ggg ];

  sora = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6b2z/jMnPSYXSYYJ6NBY77m0bofpVceoArRzJHQ+Nc";
  shiro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyYTusgW/GPy8qYBaS4gq71MEGWEY+U+m7rSUzn/xc";
  f-ggg-dev = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ527bVSbg3fMxUIyMrXhmyo0A/motmI3SZY6sMLk7C0";
  systems = [
    sora
    shiro
    f-ggg-dev
  ];

  all = users ++ systems;
in
{
  "foldingathome.xml.age".publicKeys = all;

  # Sora
  "sora/backup_password.age".publicKeys = [
    ggg
    sora
  ];
  "sora/backup_envfile.age".publicKeys = [
    ggg
    sora
  ];
  "sora/nix-github-token.age".publicKeys = [
    ggg
    sora
  ];

  # Shiro
  "shiro/backup_password.age".publicKeys = [
    ggg
    sora
    shiro
  ];
  "shiro/backup_envfile.age".publicKeys = [
    ggg
    sora
    shiro
  ];
  "shiro/minio.env.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/netprobe.env.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/pr-tracker-token.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/danbooru.env.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/glorp.env.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - Wireguard
  "shiro/wireguard/private_key.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/wireguard/laptop_psk.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/wireguard/phone_psk.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/wireguard/coffee_psk.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/wireguard/coffee2_psk.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/wireguard/night_psk.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - Step CA
  "shiro/stepca/intermediate_ca_key.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/stepca/keys_password.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - VPN Gateway
  "shiro/vpn-gateway/mullvad_private_key.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - PostgreSQL
  "shiro/pgsql/dev_pass.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/pgsql/prd_pass.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - Authentik
  "shiro/authentik/authentik.env.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - Cloudflared
  "shiro/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age".publicKeys = [
    ggg
    shiro
  ];
}
