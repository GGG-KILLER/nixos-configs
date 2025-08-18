{ lib, ... }:
{
  console = {
    keyMap = lib.mkDefault "br-abnt2";
    font = lib.mkDefault "Lat2-Terminus16";
  };
  # I18n Settings
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  i18n.supportedLocales = lib.mkDefault [
    "en_US.UTF-8/UTF-8"
    "pt_BR.UTF-8/UTF-8"
  ];

  # Timezone
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}
