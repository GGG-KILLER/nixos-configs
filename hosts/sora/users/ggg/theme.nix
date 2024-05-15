{...}: {
  home-manager.users.ggg = {
    gtk = {
      enable = true;
      theme.name = "Flat-Remix-GTK-Blue-Darkest-Solid";
      iconTheme.name = "Flat-Remix-Blue-Dark";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
}
