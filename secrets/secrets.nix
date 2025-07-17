let
  ggg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn";
  sora = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6b2z/jMnPSYXSYYJ6NBY77m0bofpVceoArRzJHQ+Nc root@sora";
  shiro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyYTusgW/GPy8qYBaS4gq71MEGWEY+U+m7rSUzn/xc root@shiro";
  jibril = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxyqgY1bvf+PYelPm9Sz4f44g1Orp+/Bvz4v8N8MIV0 root@jibril";
in
{
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

  # Shared between home servers
  "home/backup_password.age".publicKeys = [
    ggg
    sora
    shiro
    jibril
  ];
  "home/backup_envfile.age".publicKeys = [
    ggg
    sora
    shiro
    jibril
  ];
  "home/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age".publicKeys = [
    ggg
    shiro
    jibril
  ];

  # Jibril
  "jibril/netprobe.env.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/glorp.env.age".publicKeys = [
    ggg
    jibril
  ];

  # Jibril - Wireguard
  "jibril/wireguard/private_key.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/wireguard/laptop_psk.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/wireguard/phone_psk.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/wireguard/coffee_psk.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/wireguard/coffee2_psk.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/wireguard/night_psk.age".publicKeys = [
    ggg
    jibril
  ];

  # Jibril - Step CA
  "jibril/stepca/intermediate_ca_key.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/stepca/keys_password.age".publicKeys = [
    ggg
    jibril
  ];

  # Jibril - PostgreSQL
  "jibril/pgsql/prd_pass.age".publicKeys = [
    ggg
    jibril
  ];

  # Jibril - Authentik
  "jibril/authentik/authentik.env.age".publicKeys = [
    ggg
    jibril
  ];

  # Jibril -  n8n
  "jibril/n8n/encryption_key.age".publicKeys = [
    ggg
    jibril
  ];
  "jibril/n8n/pgsql/password.age".publicKeys = [
    ggg
    jibril
  ];

  # Shiro
  "shiro/minio.env.age".publicKeys = [
    ggg
    shiro
  ];
  "shiro/danbooru.env.age".publicKeys = [
    ggg
    shiro
  ];

  # Shiro - VPN Gateway
  "shiro/vpn-gateway/mullvad_private_key.age".publicKeys = [
    ggg
    shiro
  ];
}
