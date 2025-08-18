{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inputs.home-manager.follows = "home-manager";
    };
    git-crypt-agessh = {
      url = "github:GGG-KILLER/git-crypt-agessh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ipgen-cli = {
      url = "github:ipgen/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stackpkgs = {
      url = "github:ryze312/stackpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      disko,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      mkConfig =
        file:
        lib.nixosSystem rec {
          specialArgs = {
            inherit self system inputs;
            liveCd = lib.path.hasPrefix ./media file;
          };

          modules = [
            disko.nixosModules.disko
            ./common
            file
            inputs.agenix.nixosModules.default
            inputs.chaotic.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        sora = mkConfig ./hosts/sora/configuration.nix;
        shiro = mkConfig ./hosts/shiro/configuration.nix;
        jibril = mkConfig ./hosts/jibril/configuration.nix;
        # glorp = mkConfig ./hosts/glorp/configuration.nix;
        live-cd-plasma6 = mkConfig ./media/live-cd-plasma6.nix;
        live-cd-minimal = mkConfig ./media/live-cd-minimal.nix;
      };

      nixosModules.pki = import ./modules/common/pki.nix;
      nixosModules.i18n = import ./modules/common/i18n.nix;

      nixosModules.server-profile = import ./modules/server/profile.nix;

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

        jibril = {
          hostname = "jibril.lan";
          fastConnection = true;
          autoRollback = false;
          magicRollback = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.jibril;
            sshUser = "root";
          };
          confirmTimeout = 300;
        };
      };

      packages =
        let
          forAllSystems =
            function:
            lib.genAttrs
              [
                "x86_64-linux"
                "aarch64-linux"
                "x86_64-darwin"
                "aarch64-darwin"
              ]
              (
                system:
                function (
                  import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                    overlays = [
                      (
                        final: prev:
                        prev.lib.packagesFromDirectoryRecursive {
                          inherit (final) callPackage;
                          directory = ./lib;
                        }
                      )
                    ];
                  }
                )
              );
        in
        forAllSystems (
          pkgs:
          let
            packages = pkgs.lib.packagesFromDirectoryRecursive {
              inherit (pkgs) callPackage;
              directory = ./packages;
            };
          in
          (pkgs.lib.filterAttrs (name: value: name != "npm") packages)
          // {
            flood = packages.npm."@jesec/flood";
          }
        );

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
