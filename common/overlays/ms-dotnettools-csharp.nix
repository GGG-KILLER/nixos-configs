{...}: {
  nixpkgs.overlays = [
    (self: super: {
      vscode-extensions = super.vscode-extensions // {ms-dotnettools.csharp = super.callPackage ./ms-dotnettools-csharp {};};
    })
  ];
}
