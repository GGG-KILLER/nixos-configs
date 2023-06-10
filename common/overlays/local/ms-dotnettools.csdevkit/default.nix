{
  lib,
  fetchurl,
  vscode-utils,
  patchelf,
  icu,
  stdenv,
  openssl,
  coreutils,
}: let
  inherit (stdenv.hostPlatform) system;
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  binaries =
    {
      x86_64-linux = [
        "components/vs-green-server/platforms/linux-x64/node_modules/@microsoft/visualstudio-reliability-monitor.linux-x64/Microsoft.VisualStudio.Reliability.Monitor"
        "components/vs-green-server/platforms/linux-x64/node_modules/@microsoft/visualstudio-server.linux-x64/Microsoft.VisualStudio.Code.Server"
        "components/vs-green-server/platforms/linux-x64/node_modules/@microsoft/visualstudio-code-launcher.linux-x64/Microsoft.VisualStudio.Code.Launcher"
        "components/vs-green-server/platforms/linux-x64/node_modules/@microsoft/visualstudio-code-servicehost.linux-x64/Microsoft.VisualStudio.Code.ServiceHost"
        "components/vs-green-server/platforms/linux-x64/node_modules/@microsoft/servicehub-controller-net60.linux-x64/Microsoft.ServiceHub.Controller"
      ];
    }
    .${system}
    or (throw "Unsupported system: ${system}");
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "csdevkit";
      publisher = "ms-dotnettools";
      version = "0.1.83";
      sha256 = "sha256-aKrmdm4JJ3x/BBr0zGHNaCXNobiKg7+OYGIFZgF5a9o=";
      arch = "linux-x64";
    };
    sourceRoot = "extension"; # This has more than one folder.

    nativeBuildInputs = [
      patchelf
    ];

    postPatch =
      ''
        ls -lAFh components/vs-green-server/platforms/linux-x64/ &1>2

        patchelf_add_icu_as_needed() {
          declare elf="''${1?}"
          declare icu_major_v="${
          lib.head (lib.splitVersion (lib.getVersion icu.name))
        }"

          for icu_lib in icui18n icuuc icudata; do
            patchelf --add-needed "lib''${icu_lib}.so.$icu_major_v" "$elf"
          done
        }

        patchelf_common() {
          declare elf="''${1?}"

          patchelf_add_icu_as_needed "$elf"
          patchelf --add-needed "libssl.so" "$elf"
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath "${lib.makeLibraryPath [stdenv.cc.cc openssl icu.out]}:\$ORIGIN" \
            "$elf"
        }

      ''
      + (lib.concatStringsSep "\n" (map
        (bin: ''
          chmod +x "${bin}"
        '')
        binaries))
      + lib.optionalString stdenv.isLinux (lib.concatStringsSep "\n" (map
        (bin: ''
          patchelf_common "${bin}"
        '')
        binaries));

    meta = {
      description = "Official C# extension from Microsoft";
      license = lib.licenses.unfree;
      maintainers = [];
      platforms = ["x86_64-linux"];
    };
  }
