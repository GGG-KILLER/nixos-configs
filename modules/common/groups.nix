{ lib, ... }:
{
  ids.gids.render = lib.mkForce 108;
  ids.gids.video = lib.mkForce 44;
  users.groups.data-members.gid = 1000;
}
