{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    git-crypt-agessh = {
      url = "github:mtoohey31/git-crypt-agessh";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/2.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeCompat.follows = "flake-compat";
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pterodactyl-wings-nix = {
      url = "github:ZentriaMC/pterodactyl-wings-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # mats-config = {
    #   url = "github:Myaats/system";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.nur.follows = "nur";
    #   inputs.home-manager.follows = "home-manager";
    # };
    ipgen-cli = {
      url = "github:ipgen/cli";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.cargo2nix.follows = "cargo2nix";
    };

    # Inputs needed by others
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
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
          agenix.nixosModules.default
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
        autoRollback = false;
        magicRollback = false;
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
