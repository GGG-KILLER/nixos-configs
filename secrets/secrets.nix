let
  ggg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIbyyT77P4fzRh4Bfox1GQANs+P5VTrVADu5+k282fn";
  users = [ ggg ];

  sora = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6b2z/jMnPSYXSYYJ6NBY77m0bofpVceoArRzJHQ+Nc";
  shiro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyYTusgW/GPy8qYBaS4gq71MEGWEY+U+m7rSUzn/xc";
  systems = [ sora shiro ];

  all = users ++ systems;
in
{
  # Sora
  "sora/backup_password".publicKeys = [ ggg sora ];

  # Shiro
  "shiro/backup_password".publicKeys = [ ggg shiro ];

  # Shiro - StepCA
  "shiro/stepca/intermediate_ca_key".publicKeys = [ ggg shiro ];
  "shiro/stepca/intermediate_ca.crt".publicKeys = [ ggg shiro ];
  "shiro/stepca/root_ca_key".publicKeys = [ ggg shiro ];
  "shiro/stepca/root_ca.crt".publicKeys = [ ggg shiro ];
}
