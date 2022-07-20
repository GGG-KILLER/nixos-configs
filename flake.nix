{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-stable.url = github:nixos/nixpkgs/nixos-22.05;
    nur.url = github:nix-community/NUR;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = github:serokell/deploy-rs;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-crypt-agessh = {
      url = github:mtoohey31/git-crypt-agessh;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = github:kamadorueda/alejandra/2.0.0;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nur,
    home-manager,
    deploy-rs,
    agenix,
    git-crypt-agessh,
    alejandra,
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    nurPkgs = system:
      import nur {
        pkgs = pkgs;
        nurpkgs = pkgs;
      };
    nurNoPkgs = system:
      import nur {
        nurpkgs = pkgs;
      };
    my-lib = pkgs.callPackage ./lib {};
    mkConfig = host:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit system inputs nixpkgs nixpkgs-stable home-manager deploy-rs my-lib agenix git-crypt-agessh alejandra;
          nur = nurPkgs system;
          nur-no-pkgs = nurNoPkgs system;
        };

        modules = [
          ./common
          (./hosts + "/${host}/configuration.nix")
          agenix.nixosModule
        ];
      };
  in {
    nixosConfigurations = {
      sora = mkConfig "sora";
      shiro = mkConfig "shiro";
      vpn-proxy = mkConfig "vpn-proxy";
    };

    deploy.nodes = {
      shiro = {
        hostname = "shiro.lan";
        fastConnection = false;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shiro;
          sshUser = "root";
          autoRollback = false;
          magicRollback = false;
        };
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
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
