{ config, ... }:
{
  age.secrets.ggg-hashed-password.file = ../../secrets/ggg_hashed_password.age;
  users.users.ggg.hashedPasswordFile = config.age.secrets.ggg-hashed-password.path;
}
