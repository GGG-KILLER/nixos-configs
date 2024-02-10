{
  lib,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (self: super: {
      local = let
        inherit (super) fetchFromGitHub callPackage;
        deb = fetchFromGitHub {
          owner = "GGG-KILLER";
          repo = "DiscordEmailBridge";
          rev = "v0.1.0";
          hash = "sha256-/EWpHzxX8EVzudBRBj8wMA+EQq+u9qxD1vn8mWvO5Js=";
        };
        m3u8-dl-source = fetchFromGitHub {
          owner = "GGG-KILLER";
          repo = "m3u8-dl";
          rev = "59b3464a810de311167278a3b4be371ad7741ef7";
          hash = "sha256-G5/i28wlxWG0jskVbvz9AWm6g7Ml/hOXW41RcM0tS8E=";
        };
        zenKernels = callPackage "${inputs.nixpkgs}/pkgs/os-specific/linux/kernel/zen-kernels.nix";
        kernelPatches = callPackage "${inputs.nixpkgs}/pkgs/os-specific/linux/kernel/patches.nix" {};
      in rec {
        avalonia-ilspy = callPackage ./avalonia-ilspy {};
        discord-email-bridge = callPackage deb {};
        m3u8-dl = callPackage m3u8-dl-source {};
        git-credential-manager = callPackage ./git-credential-manager {};
        winfonts = callPackage ./winfonts {};
        npm = callPackage ./npm {inherit (super) nodejs;};
        prometheus-lm-sensors-exporter = callPackage ./lm-sensors-exporter {};
        mockoon = callPackage ./mockoon.nix {};
        csharp-vscode-ext = callPackage ./ms-dotnettools.csharp {};
        csdevkit-vscode-ext = callPackage ./ms-dotnettools.csdevkit {};
        linux_6_6_zen =
          (zenKernels {
            kernelPatches = [
              kernelPatches.bridge_stp_helper
              kernelPatches.request_key_helper
            ];
            argsOverride = let
              version = "6.6.10";
              suffix = "zen1";
            in {
              inherit version;
              modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
              src = fetchFromGitHub {
                owner = "zen-kernel";
                repo = "zen-kernel";
                rev = "v${version}-${suffix}";
                sha256 = "1hhy5jp1s65vpvrw9xylx3xl7mmagzmm5r9bq81hvvr7bhf754ny";
              };
            };
          })
          .zen;
        linuxPackages_6_6_zen = super.linuxPackagesFor linux_6_6_zen;
        linux_6_6_lqx =
          (zenKernels {
            kernelPatches = [
              kernelPatches.bridge_stp_helper
              kernelPatches.request_key_helper
            ];
            argsOverride = let
              version = "6.6.12";
              suffix = "lqx1";
            in {
              inherit version;
              modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
              src = fetchFromGitHub {
                owner = "zen-kernel";
                repo = "zen-kernel";
                rev = "v${version}-${suffix}";
                sha256 = "13wj7w66mrkabf7f03svq8x9dqy7w3dnh9jqpkr2hdkd6l2nf6c3";
              };
            };
          })
          .lqx;
        linuxPackages_6_6_lqx = super.linuxPackagesFor linux_6_6_lqx;
      };
    })
  ];
}
