{ ... }:
{
  users.users.remotebld = {
    isSystemUser = true;
    group = "remotebld";
    useDefaultShell = true;

    openssh.authorizedKeys.keyFiles = [ ./remotebld.pub ];
  };

  users.groups.remotebld = { };

  nix.settings.trusted-users = [ "remotebld" ];
}
