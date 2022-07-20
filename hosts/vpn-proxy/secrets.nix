{...}: {
  # config.age.secrets..path
  age.secrets = {
    wireguard-key.file = ../../secrets/vpn-proxy/wireguard/private_key;
    wireguard-wing-psk.file = ../../secrets/vpn-proxy/wireguard/wing_psk;
    wireguard-ggg-psk.file = ../../secrets/vpn-proxy/wireguard/ggg_psk;
    wireguard-spar-ios-psk.file = ../../secrets/vpn-proxy/wireguard/spar_ios_psk;
    wireguard-spar-pc1-psk.file = ../../secrets/vpn-proxy/wireguard/spar_pc1_psk;
  };
}
