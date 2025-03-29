{
  description = "GGG NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stackpkgs = {
      url = "github:ryze312/stackpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      nur-no-pkgs = import inputs.nur { nurpkgs = nixpkgs.legacyPackages.${system}; };
      mkConfig =
        host:
        lib.nixosSystem {
          specialArgs = {
            inherit
              self
              system
              inputs
              nur-no-pkgs
              ;
            liveCd = false;
          };

          modules = [
            inputs.agenix.nixosModules.default
            ./common
            ./hosts/${host}/configuration.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        sora = mkConfig "sora";
        shiro = mkConfig "shiro";
        live-cd-gnome = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit system inputs;
            liveCd = true;
          };

          modules = [
            ./common
            ./media/live-cd-gnome.nix
          ];
        };
        live-cd-minimal = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit system inputs;
            liveCd = true;
          };

          modules = [
            ./common
            ./media/live-cd-minimal.nix
          ];
        };
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
