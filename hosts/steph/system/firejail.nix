{
  lib,
  pkgs,
  ...
}:
{
  # Enable Firejail
  programs.firejail.enable = true;

  programs.firejail.wrappedBinaries =
    let
      mkBin =
        {
          pkg,
          profile,
          bin ? null,
          desktop ? null,
          extraArgs ? [ ],
        }:
        {
          executable = if bin != null then lib.getExe' pkg bin else lib.getExe pkg;
          profile = "${pkgs.firejail}/etc/firejail/${profile}";
          inherit extraArgs;
        }
        // lib.optionalAttrs (desktop != null) {
          desktop = "${pkg}/share/applications/${desktop}";
        };
    in
    {
      discordcanary = mkBin {
        pkg = pkgs.discord-canary;
        profile = "discord-canary.profile";
        desktop = "discord-canary.desktop";
      };
      okular = mkBin {
        pkg = pkgs.kdePackages.okular;
        bin = "okular";
        profile = "okular.profile";
        desktop = "org.kde.okular.desktop";
      };
    };

  environment.etc = {
    "firejail/firejail.config".text = ''
      # Allow DRM in browsers
      browser-allow-drm yes

      # Allow YubiKey access
      browser-disable-u2f no
    '';

    "firejail/okular.local".text = ''
      # Allow Okular to access stuff here
      noblacklist ''${HOME}/Documents
      noblacklist ''${HOME}/Downloads
      noblacklist ''${HOME}/Pictures
    '';
  };
}
