{
  nixpkgs,
  callPackage,
}: let
  buildDotnet = attrs: callPackage (import "${nixpkgs}/pkgs/development/compilers/dotnet/build-dotnet.nix" attrs) {};
  buildAttrs = {
    buildAspNetCore = attrs: buildDotnet (attrs // {type = "aspnetcore";});
    buildNetRuntime = attrs: buildDotnet (attrs // {type = "runtime";});
    buildNetSdk = attrs: buildDotnet (attrs // {type = "sdk";});
  };

  dotnet_9_0 = import ./9.0.nix buildAttrs;
in
  dotnet_9_0
