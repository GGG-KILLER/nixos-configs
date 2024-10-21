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
      url = "github:GGG-KILLER/git-crypt-agessh";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    packwiz = {
      url = "github:packwiz/packwiz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ipgen-cli.url = "github:ipgen/cli";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    # Inputs needed by others
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
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
      system = "x86_64-linux";
      nur-no-pkgs = import inputs.nur { nurpkgs = nixpkgs.legacyPackages.${system}; };
      mkConfig =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;

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
      inherit inputs;

      nixosConfigurations = {
        sora = mkConfig "sora";
        shiro = mkConfig "shiro";
        vpn-proxy = mkConfig "vpn-proxy";
        f-ggg-dev = mkConfig "f.ggg.dev";
        live-cd-gnome = nixpkgs.lib.nixosSystem {
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
        live-cd-minimal = nixpkgs.lib.nixosSystem {
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
        vpn-proxy = {
          hostname = "vpn-proxy.ggg.dev";
          fastConnection = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpn-proxy;
            sshUser = "root";
          };
        };
        f-ggg-dev = {
          hostname = "f.ggg.dev";
          fastConnection = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.f-ggg-dev;
            sshUser = "root";
          };
        };
      };

      packages =
        let
          forAllSystems =
            function:
            nixpkgs.lib.genAttrs
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
                  }
                )
              );
        in
        forAllSystems (
          pkgs:
          let
            npm = pkgs.callPackage ./common/packages/npm { };
          in
          {
            avalonia-ilspy = pkgs.callPackage ./common/packages/avalonia-ilspy { };
            jackett = pkgs.callPackage ./common/packages/jackett { };
            kemono-dl = pkgs.callPackage ./common/packages/kemono-dl { };
            lm-sensors-exporter = pkgs.callPackage ./common/packages/lm-sensors-exporter { };
            ms-dotnettools-csdevkit = pkgs.callPackage ./common/packages/ms-dotnettools.csdevkit { };
            ms-dotnettools-csharp = pkgs.callPackage ./common/packages/ms-dotnettools.csharp { };
            flood = npm."@jesec/flood";
            # winfonts = pkgs.callPackage ./common/packages/winfonts {};
            discord-email-bridge = pkgs.callPackage ./common/packages/discord-email-bridge.nix { };
            m3u8-dl = pkgs.callPackage ./common/packages/m3u8-dl.nix { };
            mockoon = pkgs.callPackage ./common/packages/mockoon.nix { };
            mega-sync = pkgs.callPackage ./common/packages/mega-sync { };
            genymotion-qemu = pkgs.callPackage ./common/packages/genymotion-qemu.nix { };
            twitch-downloader = pkgs.callPackage ./common/packages/twitch-downloader { };
            livestreamdvr = pkgs.callPackage ./common/packages/livestreamdvr { };
            livestreamdvr-net-backend = pkgs.callPackage ./common/packages/livestreamdvr-net/backend.nix { };
            dotnet-ef = pkgs.callPackage ./common/packages/dotnet-ef { };
          }
        );

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
