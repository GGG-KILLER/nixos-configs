{...}: {
  imports = [
    ./dotnet-7.0.nix
    ./dotnet-combine.nix
    ./local.nix
    ./omnisharp-roslyn.nix
    ./rclone.nix
    ./virt-v2v.nix
  ];
}
