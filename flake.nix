{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nur, home-manager, deploy-rs }:
    let
      system = "x86_64-linux";
      nurPkgs = system: import nur {
        pkgs = import nixpkgs { inherit system; };
        nurpkgs = import nixpkgs { inherit system; };
      };
      mkConfig = host: nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit system inputs nixpkgs nixpkgs-stable home-manager deploy-rs;
          nur = (nurPkgs system);
        };

        modules = [
          ./common
          (./hosts + "/${host}/configuration.nix")
        ];
      };
    in
    {
      nixosConfigurations = {
        sora = mkConfig "sora";
        shiro = mkConfig "shiro";
        vpn-proxy = mkConfig "vpn-proxy";
      };

      deploy.nodes = {
        shiro = {
          hostname = "shiro.lan";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shiro;
            sshOpts = [ "-i" "~/.ssh/id_deploy" ];
            sshUser = "root";
            autoRollback = false;
            magicRollback = false;
          };
        };
        vpn-proxy = {
          hostname = "vpn-proxy.ggg.dev";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpn-proxy;
            sshOpts = [ "-i" "~/.ssh/id_deploy" "-p" "17606" ];
            sshUser = "root";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
