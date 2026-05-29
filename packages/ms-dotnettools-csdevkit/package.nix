{
  lib,
  stdenv,
  vscode-utils,
  autoPatchelfHook,
  icu,
  openssl,
  libz,
  glibc,
  libxml2,
  libkrb5,
  patchelf,
}:
let
  extInfo = (
    {
      x86_64-linux = {
        arch = "linux-x64";
        hash = "sha256-TVri8/1qrVKVFiRs/5glg7snJQy5YacCKFS6KSIX+Pc=";
      };
      aarch64-linux = {
        arch = "linux-arm64";
        hash = "sha256-7YtZkjNf16k1Uzq19PLBn7UzR3jndLuhwH00bBdN/Mc=";
      };
      x86_64-darwin = {
        arch = "darwin-x64";
        hash = "sha256-0rsLLFZKTEmkIkzuOi4IRdsSf5vMeuPw2DaY8qk5tOM=";
      };
      aarch64-darwin = {
        arch = "darwin-arm64";
        hash = "sha256-rWnhfDSeqpzFKBxLt6q3V6Lxw3jjUi11APDzEzPVNnE=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
  );
in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "3.20.199";
    inherit (extInfo) hash arch;
  };
  sourceRoot = "extension"; # This has more than one folder.

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    patchelf
  ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib glibc) # libgcc_s.so.1
    (lib.getLib icu) # libicui18n.so libicuuc.so
    (lib.getLib libkrb5) # libgssapi_krb5.so
    (lib.getLib libxml2) # libxml2.so.2
    (lib.getLib libz) # libz.so.1
    (lib.getLib openssl) # libopenssl.so.3
    (lib.getLib stdenv.cc.cc) # libstdc++.so.6
  ];

  postPatch = ''
    declare ext_unique_id
    ext_unique_id="$(basename "$out" | head -c 32)"

    substituteInPlace dist/extension.js \
      --replace-fail 'e.extensionPath,"cache"' 'require("os").tmpdir(),"'"$ext_unique_id"'"' \
      --replace-fail ';await Promise.all(n.map(e=>(0,i.chmod)(e,"0755")))' ""
  '';

  preFixup = ''
    (
      set -euo pipefail
      shopt -s globstar
      shopt -s dotglob

      # Fix all binaries.
      for file in "$out"/**/*; do
        if [[ ! -f "$file" || "$file" == *.so || "$file" == *.a || "$file" == *.dylib ]] ||
            (! isELF "$file" && ! isMachO "$file"); then
            continue
        fi

        echo Making "$file" executable...
        chmod +x "$file"

        ${lib.optionalString stdenv.hostPlatform.isLinux ''
          # Add .NET deps if it is an apphost.
          if grep 'You must install .NET to run this application.' "$file" > /dev/null; then
            echo "Adding .NET needed libraries to: $file"
            patchelf \
              --add-needed libicui18n.so \
              --add-needed libicuuc.so \
              --add-needed libgssapi_krb5.so \
              --add-needed libssl.so \
              "$file"
          fi
        ''}
      done

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        # Add the ICU libraries as needed to the globalization DLLs.
        for file in "$out"/**/{libcoreclr.so,*System.Globalization.Native.so}; do
          echo "Adding ICU libraries to: $file"
          patchelf \
            --add-needed libicui18n.so \
            --add-needed libicuuc.so \
            "$file"
        done

        # Add the Kerberos libraries as needed to the native security DLL.
        for file in "$out"/**/*System.Net.Security.Native.so; do
          echo "Adding Kerberos libraries to: $file"
          patchelf \
            --add-needed libgssapi_krb5.so \
            "$file"
        done

        # Add the OpenSSL libraries as needed to the OpenSSL native security DLL.
        for file in "$out"/**/*System.Security.Cryptography.Native.OpenSsl.so; do
          echo "Adding OpenSSL libraries to: $file"
          patchelf \
            --add-needed libssl.so \
            "$file"
        done

        # Fix libxml2 breakage. See https://github.com/NixOS/nixpkgs/pull/396195#issuecomment-2881757108
        mkdir -p "$out/lib"
        ln -s "${lib.getLib libxml2}/lib/libxml2.so" "$out/lib/libxml2.so.2"
      ''}
    )
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    changelog = "https://marketplace.visualstudio.com/items/ms-dotnettools.csdevkit/changelog";
    description = "Official Visual Studio Code extension for C# from Microsoft";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ggg ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
