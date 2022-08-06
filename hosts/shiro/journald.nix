{...}: {
  services.journald.extraConfig = ''
    Storage=persistent
    Compress=true
    SplitMode=uid

    SystemMaxUse=10G
    SystemKeepFree=500G
    SystemMaxFileSize=250M

    MaxFileSec=1day
  '';
}
