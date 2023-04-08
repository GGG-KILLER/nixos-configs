{...}: {
  nixpkgs.overlays = [
    (self: super: {
      local = let
        inherit (super) fetchFromGitHub callPackage;
        repo = fetchFromGitHub {
          owner = "GGG-KILLER";
          repo = "DiscordEmailBridge";
          rev = "v0.1.0";
          hash = "sha256-/EWpHzxX8EVzudBRBj8wMA+EQq+u9qxD1vn8mWvO5Js=";
        };
      in {
        discord-email-bridge = callPackage repo {};
        git-credential-manager = callPackage ./git-credential-manager {};
        winfonts = callPackage ./winfonts {};
        npm = callPackage ./npm {inherit (super) nodejs;};
        prometheus-lm-sensors-exporter = callPackage ./lm-sensors-exporter {};
        mockoon = callPackage ./mockoon.nix {};
        csharp-vscode-ext = callPackage ./ms-dotnettools.csharp {};
      };
    })
  ];
}
