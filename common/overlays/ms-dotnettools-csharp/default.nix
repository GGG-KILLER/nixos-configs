{
  lib,
  fetchurl,
  vscode-utils,
  patchelf,
  icu,
  stdenv,
  openssl,
}: let
  vsixInfo =
    {
      x86_64-linux = {
        url = "https://github.com/OmniSharp/omnisharp-vscode/releases/download/v1.25.0/csharp-1.25.0-linux-x64.vsix";
        sha256 = "1cqqjg8q6v56b19aabs9w1kxly457mpm0akbn5mis9nd1mrdmydl";
        binaries = [
          ".debugger/vsdbg-ui"
          ".debugger/vsdbg"
          ".omnisharp/1.39.0-net6.0/OmniSharp"
          ".razor/createdump"
          ".razor/rzls"
        ];
      };
      aarch64-linux = {
        url = "https://github.com/OmniSharp/omnisharp-vscode/releases/download/v1.25.0/csharp-1.25.0-linux-arm64.vsix";
        sha256 = "0nsjgrb7y4w71w1gnrf50ifwbmjidi4vrw2fyfmch7lgjl8ilnhd";
        binaries = [
          ".debugger/vsdbg-ui"
          ".debugger/vsdbg"
          ".omnisharp/1.39.0-net6.0/OmniSharp"
          # Linux aarch64 version has no Razor Language Server
        ];
      };
      x86_64-darwin = {
        url = "https://github.com/OmniSharp/omnisharp-vscode/releases/download/v1.25.0/csharp-1.25.0-darwin-x64.vsix";
        sha256 = "01qn398vmjfi9imzlmzm0qi7y2h214wx6a8la088lfkhyj3gfjh8";
        binaries = [
          ".debugger/x86_64/vsdbg-ui"
          ".debugger/x86_64/vsdbg"
          ".omnisharp/1.39.0-net6.0/OmniSharp"
          ".razor/createdump"
          ".razor/rzls"
        ];
      };
      aarch64-darwin = {
        url = "https://github.com/OmniSharp/omnisharp-vscode/releases/download/v1.25.0/csharp-1.25.0-darwin-arm64.vsix";
        sha256 = "020j451innh7jzarbv1ij57rfmqnlngdxaw6wdgp8sjkgbylr634";
        binaries = [
          ".debugger/arm64/vsdbg-ui"
          ".debugger/arm64/vsdbg"
          ".debugger/x86_64/vsdbg-ui"
          ".debugger/x86_64/vsdbg"
          ".omnisharp/1.39.0-net6.0/OmniSharp"
          ".razor/createdump"
          ".razor/rzls"
        ];
      };
    }
    .${stdenv.targetPlatform.system};
in
  vscode-utils.buildVscodeMarketplaceExtension rec {
    mktplcRef = {
      name = "csharp";
      publisher = "ms-dotnettools";
      version = "1.25.0";
    };

    vsix = fetchurl {
      name = "${mktplcRef.publisher}-${mktplcRef.name}.zip";
      inherit (vsixInfo) url sha256;
    };

    nativeBuildInputs = [
      patchelf
    ];

    postPatch =
      ''
        declare ext_unique_id
        # See below as to why we cannot take the whole basename.
        ext_unique_id="$(basename "$out" | head -c 32)"

        # Fix 'Unable to connect to debuggerEventsPipeName .. exceeds the maximum length 107.' when
        # attempting to launch a specific test in debug mode. The extension attemps to open
        # a pipe in extension dir which would fail anyway. We change to target file path
        # to a path in tmp dir with a short name based on the unique part of the nix store path.
        # This is however a brittle patch as we're working on minified code.
        # Hence the attempt to only hold on stable names.
        # However, this really would better be fixed upstream.
        sed -i \
          -E -e 's/(this\._pipePath=[a-zA-Z0-9_]+\.join\()([a-zA-Z0-9_]+\.getExtensionPath\(\)[^,]*,)/\1require("os").tmpdir(), "'"$ext_unique_id"'"\+/g' \
          "$PWD/dist/extension.js"

        patchelf_add_icu_as_needed() {
          declare elf="''${1?}"
          declare icu_major_v="${
          with builtins; head (splitVersion (parseDrvName icu.name).version)
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
      + builtins.concatStringsSep "\n" (map
        (bin: ''
          chmod +x "${bin}"
          patchelf_common "${bin}"
        '')
        vsixInfo.binaries)
      + lib.optionalString stdenv.isDarwin ''
        substituteInPlace $omnisharp_dir/etc/config \
          --replace "libmono-native-compat.dylib" "libmono-native.dylib"
      '';

    meta = with lib; {
      description = "C# for Visual Studio Code (powered by OmniSharp)";
      homepage = "https://github.com/OmniSharp/omnisharp-vscode";
      license = licenses.mit;
      maintainers = [maintainers.jraygauthier];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
