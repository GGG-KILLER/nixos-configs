{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  openssl,
  mono,
}:
buildDotnetModule rec {
  pname = "jackett";
  version = "0.21.1991";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha512-AIVU5jfKwVzqU+y9kalWEUCoBjn2o6XzN/i5lqQO9V4LXAZxU2R8AO3GBNkkO4pZp5q4R5NMrNFUsgmGCJcdog==";
  };

  projectFile = "src/Jackett.Server/Jackett.Server.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = with dotnetCorePackages; combinePackages [sdk_6_0 sdk_7_0 sdk_8_0];
  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;

  dotnetInstallFlags = ["-p:TargetFramework=net6.0"];

  runtimeDeps = [openssl];

  doCheck = !(stdenv.isDarwin && stdenv.isAarch64); # mono is not available on aarch64-darwin
  nativeCheckInputs = [mono];
  testProjectFile = "src/Jackett.Test/Jackett.Test.csproj";

  postFixup = ''
    # For compatibility
    ln -s $out/bin/jackett $out/bin/Jackett || :
    ln -s $out/bin/Jackett $out/bin/jackett || :
  '';
  passthru.updateScript = ./updater.sh;

  meta = with lib; {
    description = "API Support for your favorite torrent trackers";
    homepage = "https://github.com/Jackett/Jackett/";
    changelog = "https://github.com/Jackett/Jackett/releases/tag/v${version}";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [edwtjo nyanloutre purcell];
  };
}
