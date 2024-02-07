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

  extInfo = let
    linuxDebuggerBins = [
      ".debugger/vsdbg-ui"
      ".debugger/vsdbg"
    ];
    darwinX86DebuggerBins = [
      ".debugger/x86_64/vsdbg-ui"
      ".debugger/x86_64/vsdbg"
    ];
    darwinAarch64DebuggerBins = [
      ".debugger/arm64/vsdbg-ui"
      ".debugger/arm64/vsdbg"
    ];
    lspBins = [
      ".roslyn/Microsoft.CodeAnalysis.LanguageServer"
    ];
    razorBins = [
      ".razor/createdump"
      ".razor/rzls"
    ];
  in
    {
      x86_64-linux = {
        arch = "linux-x64";
        sha256 = "sha256-s2ZuRpaJq0Gjcw3iDDRy8O9CJADc1QI1xQLBEEjpFGs=";
        binaries = linuxDebuggerBins ++ lspBins ++ razorBins;
      };
      aarch64-linux = linuxDebuggerBins ++ lspBins; # Linux aarch64 version has no Razor Language Server
      x86_64-darwin = darwinX86DebuggerBins ++ lspBins ++ razorBins;
      aarch64-darwin = darwinAarch64DebuggerBins ++ darwinX86DebuggerBins ++ lspBins ++ razorBins;
    }
    .${system}
    or (throw "Unsupported system: ${system}");
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "csharp";
      publisher = "ms-dotnettools";
      version = "2.17.7";
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
      description = "Base language support for C#";
      homepage = "https://github.com/dotnet/vscode-csharp";
      license = lib.licenses.mit;
      maintainers = [lib.maintainers.jraygauthier];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
