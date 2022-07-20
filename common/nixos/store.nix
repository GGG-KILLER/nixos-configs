{...}: {
  # Auto Optimise the Store
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
}
