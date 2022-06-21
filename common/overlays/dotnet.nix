{ nixpkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super:
      let
        # Use `import <nixpkgs/pkgs/development/compilers/dotnet/build-dotnet.nix>` if you're not using nix flakes.
        buildDotnet = attrs: super.callPackage (import "${nixpkgs}/pkgs/development/compilers/dotnet/build-dotnet.nix" attrs) { };
        buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
        buildNetRuntime = attrs: buildDotnet (attrs // { type = "runtime"; });
        buildNetSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
      in
      {
        dotnetCorePackages = super.dotnetCorePackages // {
          # v7.0 (preview)
          aspnetcore_7_0 = buildAspNetCore {
            icu = super.icu;
            version = "7.0.0-preview.5.22303.8";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/57cfa892-9154-40a2-9643-4b74366115b3/cd04f7b035b3b7b485f422f2584d6da7/aspnetcore-runtime-7.0.0-preview.5.22303.8-linux-x64.tar.gz";
                sha512 = "40809e8687d7b4d3c11b6778830dac364fa61bfcbd362474ee4de77a2bd4fe25a80edaa2e64807cd6daeb8391fced9e4077b02adfe88196a831e4112fd60e48b";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/3eb22afb-6454-4c90-9d32-24d7f9fadd8f/f98c80d32ca3df072fccd3579aff1a13/aspnetcore-runtime-7.0.0-preview.5.22303.8-linux-arm64.tar.gz";
                sha512 = "56db58200270d802e0f3125d3ac055dc2d9b7f33879ddc995920d014434fc33d92a39ed0d32b01592e03bc4ee4a0c684621e1b6c64a6d13253896cca41e48262";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/eb2110ee-7dc1-494f-baa9-e3aabea1a008/d1cbc2de8f0e88882d4faa8759401cf7/aspnetcore-runtime-7.0.0-preview.5.22303.8-osx-x64.tar.gz";
                sha512 = "21848cb14c4808a39e503f8c0f2590dce58734b8e5d2bde70e51b42c99ffcd1a46df7b84a0a433b082197b3bfbaefb4cb4fe81ca76bfae15e95ddd64e78e1425";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/87b70ee5-8e21-4ba6-8576-5045dd1ccb44/7e067f83e35bf8a1c69ebd361727fc30/aspnetcore-runtime-7.0.0-preview.5.22303.8-osx-arm64.tar.gz";
                sha512 = "794ee8831dce488dba840a04c021c7e8ab9a25ce1ff752140fb2b78ba7bc42857b6e0973f7c02fdf4fc99867d2116e8ec3cfc21723af2ce783d3462c56c45ca7";
              };
            };
          };

          runtime_7_0 = buildNetRuntime {
            icu = super.icu;
            version = "7.0.0-preview.5.22301.12";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/c3937a22-27d5-4c37-816f-801efe033301/77bb70ea418386cbb31962f1cb0446cd/dotnet-runtime-7.0.0-preview.5.22301.12-linux-x64.tar.gz";
                sha512 = "faf8450e1387b3329168c43a95f091f6c41a1230cfd0f4df2e5e1a501a8f8f82e41893cbe1f5f10b247c3ae58ce24ac4c18fd5533756307e50e439ec70ce0e4b";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/5ec6c59b-9ee8-4cf0-93b0-7ac4151a2bec/40970cdd60707cc3f21f9ee3766a876c/dotnet-runtime-7.0.0-preview.5.22301.12-linux-arm64.tar.gz";
                sha512 = "0751be17efa3191e6c9dd3bf0b7f1f8fd21028282b9eacf6786c6f61c7898199d15ad4719686e0437e4ecdd0c2d85830344732afb5e2f4579e89aa410f75ee4f";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/35e2b13a-9cb1-446c-906a-1fe08deda59d/5ccd4109c6ffd446809c4a5bb1561fb1/dotnet-runtime-7.0.0-preview.5.22301.12-osx-x64.tar.gz";
                sha512 = "a0f85b0dd51e6c0763316a2e4a797a32e8ba6b35947295c11dcf39f3122cfa9f1e47c3371cc360d967df4ed800679aff2b13e299ed1bac861b27e185f9de5704";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/6ce093c1-acae-47c2-9523-5946773e3a2d/4fc3117587145dee00305dfed13b8f58/dotnet-runtime-7.0.0-preview.5.22301.12-osx-arm64.tar.gz";
                sha512 = "6d25417bc5dfb59d6b59decb49c55737bb00f1803453eec126102c90b9d9be0809724c4cf1a0f321a1eb5daf70e7c6ad33fd50fc79eb94793f61bf816637e00b";
              };
            };
          };

          sdk_7_0 = buildNetSdk {
            icu = super.icu;
            version = "7.0.100-preview.5.22307.18";
            srcs = {
              x86_64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/1c28fb12-c30d-411f-8d63-4dd9835387fe/cfe3d86f5600568ac354f7546f876589/dotnet-sdk-7.0.100-preview.5.22307.18-linux-x64.tar.gz";
                sha512 = "691c0d8917bc9848a08707b7fa22da05228dad0ba6335ff06c6d80f9a95349307572ff45c0b088d9fc199c40a1784ff314e1a8735d0366bd3aa06eb8dfa2b7d5";
              };
              aarch64-linux = {
                url = "https://download.visualstudio.microsoft.com/download/pr/25092f42-500b-43da-9994-7577f6c7734c/507ea02dc7cf86ae94004afd2e916f58/dotnet-sdk-7.0.100-preview.5.22307.18-linux-arm64.tar.gz";
                sha512 = "51f4e3f578cc44ea1b64904183ca0c0dd8ba229055fb70bdc4f94144fee9b2b2cc05d014332c560319da44252df9156caf1d06f91d999bc7de76b5b2d881f69e";
              };
              x86_64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/dd15b5e1-7765-4ddb-8bfb-e3ddb501fad5/d4d7b26819da837fc9df7aeb39caa370/dotnet-sdk-7.0.100-preview.5.22307.18-osx-x64.tar.gz";
                sha512 = "b329f615fad845b6ec49d15d81fb40f27ac078ee871b305e835c0625015f8406b665447c9d8c2a1d30dd57912cb470f6bf2c155307b4920b256c3b80fa800ec0";
              };
              aarch64-darwin = {
                url = "https://download.visualstudio.microsoft.com/download/pr/1264a7ff-d09d-424f-84ed-efab470cb615/9f6bdeb3997f68344a9d561d10cbd9cb/dotnet-sdk-7.0.100-preview.5.22307.18-osx-arm64.tar.gz";
                sha512 = "983128f05d5f2476383b60d9d565349532d4183bffd0a215d74bb26d0a53d40489401d00dbaf8af6a01aca8ec85e7776019cce0e662764ab3017e4659fd3683b";
              };
            };
          };
        };
      })
  ];
}
