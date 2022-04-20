{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = inputs @ { self, nixpkgs, nur, home-manager, deploy-rs }:
    let
      lib = nixpkgs.lib;
      nurPkgs = system: import nur {
        pkgs = import nixpkgs { inherit system; };
        nurpkgs = import nixpkgs { inherit system; };
      };
      mkNixosDevice = { system ? "x86_64-linux", device }: lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit system inputs nixpkgs home-manager deploy-rs;
          nur = (nurPkgs system);
        };

        modules = [
          ./common
          (./hosts + "/${device}/configuration.nix")
        ];
      };
      mkNixosServer = { system ? "x86_64-linux", server, hostname }: {
        inherit hostname;
        profiles.system = {
          user = "root";
          sshOpts = [ "-A" ];
          path = deploy-rs.lib.x86_64-linux.activate.nixos (lib.nixosSystem {
            inherit system;

            specialArgs = {
              inherit system inputs nixpkgs home-manager deploy-rs;
              nur = (nurPkgs system);
              machineArgs = {
                hostName = server;
              };
            };

            modules = [
              ./common
              (./hosts + "/${server}/configuration.nix")
            ];
          });
        };
      };
    in
    {
      nixosConfigurations = {
        sora = mkNixosDevice { device = "sora"; };
        shiro = mkNixosDevice { device = "shiro"; };
        vpn-proxy = mkNixosDevice { device = "vpn-proxy"; };
      };

      deploy.nodes = {
        shiro = {
          hostname = "shiro.lan";
          profiles.system = {
            sshOpts = [ "-i" ./ops/deploy.privkey ];
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shiro;
          };
        };
        vpn-proxy = {
          hostname = "vpn-proxy.ggg.dev";
          profiles.system = {
            sshOpts = [ "-i" ./ops/deploy.privkey ];
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpn-proxy;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
