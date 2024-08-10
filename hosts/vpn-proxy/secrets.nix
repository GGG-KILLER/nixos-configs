{ ... }:
{
  age.secrets = {
    wireguard-key.file = ../../secrets/vpn-proxy/wireguard/private_key.age;
    wireguard-wing-psk.file = ../../secrets/vpn-proxy/wireguard/wing_psk.age;
    wireguard-ggg-psk.file = ../../secrets/vpn-proxy/wireguard/ggg_psk.age;
    wireguard-spar-ios-psk.file = ../../secrets/vpn-proxy/wireguard/spar_ios_psk.age;
    wireguard-spar-pc1-psk.file = ../../secrets/vpn-proxy/wireguard/spar_pc1_psk.age;
  };
}
