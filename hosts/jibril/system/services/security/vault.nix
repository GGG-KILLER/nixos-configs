{ pkgs, config, ... }:
{
  jibril.dynamic-ports = [
    "bao"
    "bao-cluster" # unused but requried
  ];

  # # Yubikey as HSM
  # services.pcscd.enable = true;

  # Openbac
  services.openbao.enable = true;
  services.openbao.settings = {
    ui = true;

    api_addr = "https://vault.jibril.lan";
    cluster_addr = "http://127.0.0.1:${toString config.jibril.ports.bao-cluster}";

    storage.raft.path = "/var/lib/openbao";

    listener.default = {
      type = "tcp";
      tls_disable = "true";
      address = "127.0.0.1:${toString config.jibril.ports.bao}";
      x_forwarded_for_authorized_addrs = "127.0.0.1";
    };

    # TODO: Enable
    # Ref: https://openbao.org/docs/configuration/seal/pkcs11/
    # Ref: https://github.com/numinit/nixpkcs
    # Ref: https://developers.yubico.com/PIV/Introduction/Admin_access.html
    # Ref: https://developers.yubico.com/PIV/Introduction/Certificate_slots.html
    # Ref: https://developers.yubico.com/yubico-piv-tool/YKCS11/#_key_mapping
    # seal.default = {
    #   type = "pkcs11";
    #   lib = "${pkgs.yubico-piv-tool}/lib/libykcs11.so";
    #   token_label = "YubiKey PIV #20567751";
    #   key_label = "Public key for Key Management";
    #   key_id = "0x03";
    # };
  };
  environment.systemPackages = [ pkgs.openbao ];

  services.caddy.virtualHosts."vault.jibril.lan".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.jibril.ports.bao}
  '';
}
