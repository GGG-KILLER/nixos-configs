{ ... }:

{
  # Limit to 10 cores so I don't have a totally unresponsive system.
  nix.settings = {
    cores = 10;
    max-jobs = 10;
  };
}
