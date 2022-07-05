{ lib, ... }:

with lib;
{
  # users.groups.video = {
  #   gid = mkForce 44;
  # };
  ids.gids.video = mkForce 44;
}
