let
  ggg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn";
  users = [ ggg ];

  sora = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6b2z/jMnPSYXSYYJ6NBY77m0bofpVceoArRzJHQ+Nc";
  shiro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyYTusgW/GPy8qYBaS4gq71MEGWEY+U+m7rSUzn/xc";
  vpn-proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXJsB3idnONLnk1X/Ga2V0HHCJhjqptMbvdZVJji3F/";
  systems = [ sora shiro vpn-proxy ];

  all = users ++ systems;
in
{
  # Sora
  "sora/backup_password".publicKeys = [ ggg sora ];

  # Shiro
  "shiro/backup_password".publicKeys = [ ggg shiro ];

  # Shiro - Wireguard
  "shiro/wireguard/private_key".publicKeys = [ ggg shiro ];
  "shiro/wireguard/laptop_psk".publicKeys = [ ggg shiro ];
  "shiro/wireguard/phone_psk".publicKeys = [ ggg shiro ];

  # Shiro - Step CA
  "shiro/stepca/intermediate_ca_key".publicKeys = [ ggg shiro ];
  "shiro/stepca/keys_password".publicKeys = [ ggg shiro ];

  # VPN Proxy
  "vpn-proxy/wireguard/private_key".publicKeys = [ ggg vpn-proxy ];
  "vpn-proxy/wireguard/wing_psk".publicKeys = [ ggg vpn-proxy ];
  "vpn-proxy/wireguard/ggg_psk".publicKeys = [ ggg vpn-proxy ];
  "vpn-proxy/wireguard/spar_ios_psk".publicKeys = [ ggg vpn-proxy ];
  "vpn-proxy/wireguard/spar_pc1_psk".publicKeys = [ ggg vpn-proxy ];
}
