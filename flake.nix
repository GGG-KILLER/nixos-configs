{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-crypt-agessh = {
      url = "github:mtoohey31/git-crypt-agessh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/2.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:mic92/nix-index-database";
    pterodactyl-wings-nix = {
      url = "github:ZentriaMC/pterodactyl-wings-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mats-config = {
      url = "github:Myaats/system";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nur.follows = "nur";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur,
    deploy-rs,
    agenix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    nur-no-pkgs = import nur {
      nurpkgs = nixpkgs.legacyPackages.${system};
    };
    mkConfig = host:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit system inputs nur-no-pkgs;
        };

        modules = [
          agenix.nixosModule
          ./common
          ./hosts/${host}/configuration.nix
        ];
      };
  in {
    inherit inputs;

    nixosConfigurations = {
      sora = mkConfig "sora";
      shiro = mkConfig "shiro";
      vpn-proxy = mkConfig "vpn-proxy";
      f-ggg-dev = mkConfig "f.ggg.dev";
    };

    deploy.nodes = {
      shiro = {
        hostname = "shiro.lan";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shiro;
          sshUser = "root";
        };
        confirmTimeout = 300;
      };
      vpn-proxy = {
        hostname = "vpn-proxy.ggg.dev";
        fastConnection = false;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpn-proxy;
          sshOpts = ["-p" "17606"];
          sshUser = "root";
        };
      };
      f-ggg-dev = {
        hostname = "f.ggg.dev";
        fastConnection = false;
        autoRollback = false;
        magicRollback = false;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.f-ggg-dev;
          #sshOpts = ["-p" "17606"];
          sshUser = "root";
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
