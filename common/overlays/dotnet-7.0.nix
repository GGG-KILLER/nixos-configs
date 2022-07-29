{inputs, ...}: {
  nixpkgs.overlays = [
    (self: super: let
      # Use `import <nixpkgs/pkgs/development/compilers/dotnet/build-dotnet.nix>` if you're not using nix flakes.
      buildDotnet = attrs: super.callPackage (import "${inputs.nixpkgs}/pkgs/development/compilers/dotnet/build-dotnet.nix" attrs) {};
      buildAspNetCore = attrs: buildDotnet (attrs // {type = "aspnetcore";});
      buildNetRuntime = attrs: buildDotnet (attrs // {type = "runtime";});
      buildNetSdk = attrs: buildDotnet (attrs // {type = "sdk";});
    in {
      dotnetCorePackages =
        super.dotnetCorePackages
        // {
          # v7.0 (preview)
          aspnetcore_7_0 = buildAspNetCore {
            icu = super.icu;
            version = "7.0.0-preview.6.22330.3";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/36278471-be55-4637-94d8-ead9a528c2f0/88208d9ca97c99007b04b59cb6a3facb/aspnetcore-runtime-7.0.0-preview.6.22330.3-linux-x64.tar.gz";
                sha512 = "a7aa5f3b788645a39957fa27cce84ca1e7dcfcf7a334d52097e891d3b26b8c8ba981c1f3bbab17831110339e1e62a74e6a54eee15311b8294a2d2c845a07cdbd";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/a027c7f2-01c7-4c7b-b2bf-ebdd33fa4f6b/7ae2e710aef6a9e109cd6f491c5eb6f1/aspnetcore-runtime-7.0.0-preview.6.22330.3-linux-arm64.tar.gz";
                sha512 = "877979a4d9e9d4c6f167590d3f132583aca655bac8d2ddb022aeb2a2e6b09ecbfd6c251345fbb894a0493feab9f2219f9ce6656b0566a777b93c79ff784c26a6";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/6c7308da-3b72-4abd-8ee8-80793166bd5b/0be54db8f84be48cd7e9a2c22530d398/aspnetcore-runtime-7.0.0-preview.6.22330.3-osx-x64.tar.gz";
                sha512 = "1063103d449c0663a108ab2332520640ccbdbd47ad7faa94c4c4ff8805c278259ed27da8c4f3025171863772b6b0b714ab080ffa904efd86a1f83e3eadeda246";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/fb2138b8-db47-4ea1-a3f8-48b5ea7f711d/c972c6fef6565bbe78aba5b339d3033a/aspnetcore-runtime-7.0.0-preview.6.22330.3-osx-arm64.tar.gz";
                sha512 = "4e41ca850287e87e43251850bac30b967c5556f87637bc06169f39f9c6da053f6d1d77c8397256b3eaaac6993dfa2d757a86f407b4d4384ff5e5bb082043eb3b";
              };
            };
          };

          runtime_7_0 = buildNetRuntime {
            icu = super.icu;
            version = "7.0.0-preview.6.22324.4";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/b235cc0f-1827-47f6-b3e9-f8ff9e2cc638/83a0c9c6e956f54bf6ad2fa4adbae5b1/dotnet-runtime-7.0.0-preview.6.22324.4-linux-x64.tar.gz";
                sha512 = "304b509b478fbed7e5ec97d9c75821249b933fb5c814c4f14078611d17cd8f95ccdf6c48049c02ed2f033ece61acc17e0a23a59c2a6aca9d191892d0224af45d";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/31bcf5ed-d9dc-4682-89af-99ba3382bc8d/5b5d810460212aa931dab3a6cdedb040/dotnet-runtime-7.0.0-preview.6.22324.4-linux-arm64.tar.gz";
                sha512 = "3a1302724135514933c1c06e5373a785bfd18bc0b3f759c488023f4495c272841cbccbd320721a67fb40ac7bbdd48b366279ece3d4ce0f5bf9e520e2e93c46b9";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/bd9eb4fd-eb78-4aef-97dc-223c9d72ea26/4457d1b7f2fa1e1153820d1b6f5dddbc/dotnet-runtime-7.0.0-preview.6.22324.4-osx-x64.tar.gz";
                sha512 = "ddc42d28564b196479c62bf3083516b236dbcbf6429cc5c0e2866d61bc0d500612cdd0224e45c154e1df07e414da1763a0334dd55d95ddf304e2e8dac67dfac7";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/4ecf88e0-d9e8-43eb-a719-b5c1beff046e/be2555036dccaeca2842b0e7760d61d6/dotnet-runtime-7.0.0-preview.6.22324.4-osx-arm64.tar.gz";
                sha512 = "5b48dc99e90bd593c9decb65e71f398207d4cc5456edec35db9f48556d1c0f4de26c0d27f981bc2f0e909a2f0eb18071c483b7766f45d69e1f71519f74df5679";
              };
            };
          };

          sdk_7_0 = buildNetSdk {
            icu = super.icu;
            version = "7.0.100-preview.6.22352.1";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/9762c43b-6de2-44aa-928d-61bec028a330/ba4d124e5384ae5c5a4599afbc41b1bf/dotnet-sdk-7.0.100-preview.6.22352.1-linux-x64.tar.gz";
                sha512 = "e49a2119021e4069f1193898536cc59628336e656f2f7e49d454a593a330d8e437acf2f4efb70925bc16a9c900c2e49f4a6c2fb5f69e696b09a91ebccd2c9307";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/27b08d18-c7cc-4f83-9343-0d16dec83709/afa9f6f1896ebdcc2b19bafe3cbd7d6c/dotnet-sdk-7.0.100-preview.6.22352.1-linux-arm64.tar.gz";
                sha512 = "e1812dc0f4ae06a6abd375ca975e2f23e510f683b09ae0a32cddd0f6293f515f2316ce94b170e680d83e1450be27da7506e393a92dd89a9a5fa1b9e4f198a0a4";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/e9c70049-5fd3-4a11-945d-332572b2d09a/83e98d612504f66066f6752cc9d7ae44/dotnet-sdk-7.0.100-preview.6.22352.1-osx-x64.tar.gz";
                sha512 = "beac6336874af9552c06c0434e89406b10f3bce8cde3f63e9c044dc66e5b5ad548c9dbfde3cba1880e7b23cc272f5a4e448a052aefa011da1fc7b600eea3f147";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/202fe3a0-4c4d-4bd0-bf0c-164c700c6e47/77a3a7cb1d94674db2152b9c1655711c/dotnet-sdk-7.0.100-preview.6.22352.1-osx-arm64.tar.gz";
                sha512 = "a76eef95f7062856eb5343b0da1192679821fe45d5fcbcd2ad7c32f1fd0293118f2395215cf23187af8d9662b8dbae5e9154be0431d50584ef73aafe8a580a70";
              };
            };
          };
        };
    })
  ];
}
