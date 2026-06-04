{ lib, ... }:
{
  console = {
    keyMap = lib.mkDefault "br-abnt2";
    font = lib.mkDefault "Lat2-Terminus16";
  };
  # I18n Settings
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocales = lib.mkDefault [ "pt_BR.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = lib.listToAttrs (
    lib.map (name: lib.nameValuePair name "pt_BR.UTF-8") [ "LC_ADDRESS" "LC_MEASUREMENT" "LC_NAME" "LC_PAPER" "LC_TELEPHONE" "LC_TIME" ]
  );

  # Timezone
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}
