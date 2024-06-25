{
  lib,
  vscode-utils,
  patchelf,
  icu,
  stdenv,
  openssl,
  coreutils,
}: let
  inherit (stdenv.hostPlatform) system;
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  extInfo = let
    baseBins = [
      ".roslyn/Microsoft.CodeAnalysis.LanguageServer"
      ".razor/rzls"
    ];
    linuxBins =
      baseBins
      ++ [
        ".debugger/vsdbg-ui"
        ".debugger/vsdbg"
      ];
    darwinBins =
      baseBins
      ++ [
        ".debugger/x86_64/vsdbg-ui"
        ".debugger/x86_64/vsdbg"
      ];
  in
    {
      x86_64-linux = {
        arch = "linux-x64";
        # nix hash convert --hash-algo sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csharp/2.35.15/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=linux-x64")
        sha256 = "sha256-Y+Re3tDX8HQrWo045JxdX8Jt4jomm1/C9T+BU2/hE+g=";
        binaries = linuxBins;
      };
      aarch64-linux = {
        arch = "linux-arm64";
        # nix hash convert --hash-algo sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csharp/2.35.15/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=linux-arm64")
        sha256 = "sha256-8FooJmdFHgCAuAeJiVkqX/ugTN5PlLYm6tK9MR5STJY=";
        binaries = linuxBins;
      };
      x86_64-darwin = {
        arch = "darwin-x64";
        # nix hash convert --hash-algo sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csharp/2.35.15/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=darwin-x64")
        sha256 = "sha256-BLOiQVXMZlXn3Hgl4EJ24TU6EjH8Gw73qO5DkZcv3BY=";
        binaries = darwinBins;
      };
      aarch64-darwin = {
        arch = "darwin-arm64";
        # nix hash convert --hash-algo sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csharp/2.35.15/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=darwin-arm64")
        sha256 = "sha256-pNQ7WjqmiPBzzq2QNEd4a3VZqOuoKPtGooy83vgJTPQ=";
        binaries =
          darwinBins
          ++ [
            ".debugger/arm64/vsdbg-ui"
            ".debugger/arm64/vsdbg"
          ];
      };
    }
    .${system}
    or (throw "Unsupported system: ${system}");
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "csharp";
      publisher = "ms-dotnettools";
      version = "2.35.15";
      inherit (extInfo) sha256 arch;
    };

    nativeBuildInputs = [
      patchelf
    ];

    postPatch =
      ''
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

        substituteInPlace dist/extension.js \
          --replace 'uname -m' '${lib.getExe' coreutils "uname"} -m'

      ''
      + (lib.concatStringsSep "\n" (map
        (bin: ''
          chmod +x "${bin}"
        '')
        extInfo.binaries))
      + lib.optionalString stdenv.isLinux (lib.concatStringsSep "\n" (map
        (bin: ''
          patchelf_common "${bin}"
        '')
        extInfo.binaries));

    meta = {
      description = "Official C# support for Visual Studio Code";
      homepage = "https://github.com/dotnet/vscode-csharp";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ggg];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
